//
//  DataProcessing.swift
//  BaseStation
//
//  Created by Michael Warren on 12/1/22.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

class DataStore : NSObject {
    private var droneData: [DroneDataPoint] = []
    private var range = 30000
    private var startDroneTime = UInt32.max
    private var startTime = Date.now
    private var lastUpdateTime = Date.now
    private var expectedTimeDelta: TimeInterval?
    
    @Published var altitudeDataPoints: [DataPoint<Int32>] = []
    @Published var gyroDataPoints: [DataPoint<Int16>] = []
    @Published var speedDataPoints: [DataPoint<Int16>] = []
    @Published var accelDataPoints: [DataPoint<Double>] = []
    @Published var fromTime = 0
    @Published var toTime = 0
    @Published var history: [CLLocationCoordinate2D] = []
    @Published var updateFrequency: Double = 0
    @Published var updatePeriod: Double = 0
    @Published var latency: Int = 0
    
    var dataRange: ClosedRange<Int> {
        return  Int(Double(fromTime) / 1000.0)...Int(max(30, Int(Double(toTime) / 1000.0)))
    }
    
    func add(data: DroneDataPoint) {
        if data.onTime < startDroneTime {
            startDroneTime = data.onTime
            startTime = Date.now
            altitudeDataPoints.removeAll()
            gyroDataPoints.removeAll()
            speedDataPoints.removeAll()
            accelDataPoints.removeAll()
            droneData = []
            history = []
            lastUpdateTime = Date.now
            updatePeriod = 0
            updateFrequency = 0
            expectedTimeDelta = nil
        }
        
        let runningTime = Int(startTime.distance(to: Date.now) * 1000.0)
        let droneRunningTime = Int(data.onTime - startDroneTime)
        latency = abs(runningTime - droneRunningTime)
        
        self.updatePeriod = lastUpdateTime.distance(to: Date.now)
        self.updateFrequency = self.updatePeriod != 0 ? 1.0 / self.updatePeriod : 0
        self.lastUpdateTime = Date.now
        
        var _data = data
        
        if let lastPoint = history.last {
            let first = CLLocation(latitude: lastPoint.latitude, longitude: lastPoint.longitude)
            let second = CLLocation(latitude: data.gpsLocation.latitude, longitude: data.gpsLocation.longitude)
            
            if first.distance(from: second) > 2 {
                history.append(data.gpsLocation)
            }
        }
        
        _data.onTime = data.onTime - startDroneTime
        let earlyLimit = max(0, Int(_data.onTime) - range)
        
        droneData.append(_data)
        toTime = Int(_data.onTime)
        
        if earlyLimit == 0 {
            fromTime = 0
        } else {
            let last = droneData.last { dp in
                dp.onTime < earlyLimit
            }
            
            if let last = last {
                fromTime = Int(last.onTime)
            } else {
                fromTime = toTime
            }
        }
        
        altitudeDataPoints.append(contentsOf: [_data.gpsAltitudeDataPoint, _data.baroAltitudeDataPoint, _data.calculatedAltitudeDataPoint])
        clamp(array: &altitudeDataPoints, earlyLimit: earlyLimit)
        
        gyroDataPoints.append(contentsOf: [_data.gyroXDataPoint, _data.gyroYDataPoint, _data.gyroZDataPoint])
        clamp(array: &gyroDataPoints, earlyLimit: earlyLimit)
        
        speedDataPoints.append(_data.speedDataPoint)
        clamp(array: &speedDataPoints, earlyLimit: earlyLimit)
        
        accelDataPoints.append(contentsOf: [_data.accelXDataPoint, _data.accelYDataPoint, _data.accelZDataPoint] )
        clamp(array: &accelDataPoints, earlyLimit: earlyLimit)
    }
    
    func clamp<T>(array: inout [DataPoint<T>], earlyLimit: Int) {
        array.removeAll { dp in
            dp.time < (Double(earlyLimit) / 1000.0)
        }
    }
}
