//
//  BLEViewModel.swift
//  DroneStatus
//
//  Created by Michael Warren on 11/18/22.
//

import Foundation
import CoreBluetooth
import MapKit
import SwiftUI

struct Drone : Identifiable {
    let id = UUID()
    let name: String
    var location: CLLocationCoordinate2D
}

class ViewModel : DataStore, ObservableObject {
    private var centralManager: CBCentralManager?
    private var drone: CBPeripheral?
    private var locationManager = CLLocationManager()
    private var userLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    private var userAltitude: Double = 0
    
    @Published var latitude: Double = 0
    @Published var longitude: Double = 0
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0))
    @Published var droneAnnotation: Drone = Drone(name: "drone", location: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    @Published var throttle: CGFloat = 0
    @Published var yaw: CGFloat = 0.5
    @Published var pitch: CGFloat = 0.5
    @Published var roll: CGFloat = 0.5
    
    @Published var armingStatus = "UNKNOWN"
    @Published var armingStatusColor = Color.blue
    
    @Published var isAccelActive = false
    @Published var isGyroActive = false
    @Published var isBaroActive = false
    @Published var isGPSActive = false
    @Published var isCompassActive = false
    
    @Published var currentDroneDataPoint: DroneDataPoint? = DroneDataPoint()
    
    var minX: Double?
    var minY: Double?
    var maxW: Double?
    var maxH: Double?
    
    var updateRegion: Bool = true
    
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func resetMins() {
        minX = nil
        minY = nil
        maxW = nil
        maxH = nil
    }
    
    func toggleRegionUpdates() {
        updateRegion = !updateRegion
        resetMins();
    }
    
    private var _data: Data?
    private var data: Data? {
        get {
            return _data;
        }
        
        set {
            self._data = newValue
            let array = [UInt8](self._data!)
            
            DispatchQueue.main.async {
                withAnimation {
                    let droneDataPoint = DroneDataPoint(data: array)
                    self.add(data: droneDataPoint)
                    
                    self.currentDroneDataPoint = droneDataPoint
                    
                    self.throttle = CGFloat((Float(droneDataPoint.rx_throttle) - 1000.0) / 1000.0)
                    self.yaw = CGFloat((Float(droneDataPoint.rx_yaw) - 1000.0) / 1000.0)
                    self.pitch = CGFloat((Float(droneDataPoint.rx_pitch) - 1000.0) / 1000.0)
                    self.roll = CGFloat((Float(droneDataPoint.rx_roll) - 1000.0) / 1000.0)
                    
                    self.latitude = Double(droneDataPoint.gps_latitude) / Double(10000000)
                    self.longitude = Double(droneDataPoint.gps_longitude) / Double(10000000)

                    self.droneAnnotation.location.latitude = self.latitude
                    self.droneAnnotation.location.longitude = self.longitude

                    let (text, color) = droneDataPoint.armingStatusText
                    self.armingStatus = text
                    self.armingStatusColor = color
                    
                    self.isGPSActive = droneDataPoint.status & (1 << 2) > 0
                    self.isBaroActive = droneDataPoint.status & (1 << 3) > 0
                    self.isCompassActive = droneDataPoint.status & (1 << 4) > 0
                    self.isAccelActive = droneDataPoint.status & (1 << 5) > 0
                    self.isGyroActive = droneDataPoint.status & (1 << 6) > 0
                    
                    if(self.updateRegion) {
                        self.region = self.getRegion(coord1: self.droneAnnotation.location, coord2: self.userLocation)
                    }
                }
            }
        }
    }
    
    func getRegion(coord1: CLLocationCoordinate2D, coord2: CLLocationCoordinate2D) -> MKCoordinateRegion {
        let p1 = MKMapPoint(coord1)
        let p2 = MKMapPoint(coord2)
        let fudge = 0.6
        
        let currentX = fmin(p1.x,p2.x) - fudge
        let currentY = fmin(p1.y,p2.y) - fudge
        let currentW = fabs(p1.x-p2.x) + fudge
        let currentH = fabs(p1.y-p2.y) + fudge
        
        minX = minX != nil ? fmin(minX!, currentX) : currentX
        minY = minY != nil ? fmin(minY!, currentY) : currentY
        maxW = maxW != nil ? fmax(maxW!, currentW) : currentW
        maxH = maxH != nil ? fmax(maxH!, currentH) : currentH
        
        let mapRect = MKMapRect(x: minX!, y: minY!, width: maxW!, height: maxH!)
        return MKCoordinateRegion(mapRect)
    }
}

extension ViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch(manager.authorizationStatus) {
        case .notDetermined:
            break
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.userLocation = location.coordinate
            self.userAltitude = location.altitude
        }
    }
}

extension ViewModel: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .poweredOff:
            print("Is Powered Off.")
        case .poweredOn:
            print("Is Powered On.")
            startScanning()
        case .unsupported:
            print("Is Unsupported.")
        case .unauthorized:
            print("Is Unauthorized.")
        case .unknown:
            print("Unknown")
        case .resetting:
            print("Resetting")
        @unknown default:
            print("Error")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        drone = peripheral
        drone!.delegate = self
        centralManager?.stopScan()
        centralManager?.connect(drone!, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        drone?.discoverServices([CBUUID(string: "112f3c4e-6dc1-4113-855d-74e4979d514a")]);
    }
    
    func startScanning() -> Void {
        centralManager?.scanForPeripherals(withServices: [CBUUID(string: "112f3c4e-6dc1-4113-855d-74e4979d514a")])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        central.connect(peripheral)
    }
}

extension ViewModel : CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let service = peripheral.services?.first
        if let service = service {
            peripheral.discoverCharacteristics([CBUUID(string: "2065f2fe-f580-4303-b12b-ed67fe43e4b3")], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let characteristic = service.characteristics?.first
        if let characteristic = characteristic {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        self.data = characteristic.value
    }
    
}

