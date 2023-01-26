//
//  DroneData.swift
//  BaseStation
//
//  Created by Michael Warren on 12/1/22.
//

import Foundation
import SwiftUI
import MapKit

struct DataPoint<T> : Identifiable {
    var id: UUID = UUID()
    var time: Double
    var name: String
    var value: T
}

struct DroneDataPoint : Identifiable
{
    var id: UInt32 = 0
    var onTime: UInt32 = 0
    var armingStatus: UInt16 = 0
    var status: UInt8 = 0
    var batteryPercentage: UInt8 = 0
    var home_distance: UInt16 = 0
    var home_direction: Int16 = 0
    
    var gps_number_satellites: UInt8 = 0
    var roll: Int16 = 0
    var pitch: Int16 = 0
    var yaw: Int16 = 0
    var acc_x: Int16 = 0
    var acc_y: Int16 = 0
    var acc_z: Int16 = 0
    var gyro_x: Int16 = 0
    var gyro_y: Int16 = 0
    var gyro_z: Int16 = 0
    var mag_x: Int16 = 0
    var mag_y: Int16 = 0
    var mag_z: Int16 = 0
    var gps_latitude: Int32 = 0
    var gps_longitude: Int32 = 0
    var gps_groundCourse: Int16 = 0
    var gps_groundSpeed: Int16 = 0
    var gps_altitude_meters: Int16 = 0
    var baro_altitude_meters: Int32 = 0
    var inav_z_position: Int32 = 0
    var inav_z_velocity: Int16 = 0
    var rx_roll: Int16 = 0
    var rx_pitch: Int16 = 0
    var rx_yaw: Int16 = 0
    var rx_throttle: Int16 = 0
    var home_latitude: Int32 = 0
    var home_longitude: Int32 = 0
    var home_altitude_meters: Int32 = 0
    var lora_rssi: Int8 = 0
    var flight_mode: UInt16 = 0
    var transmitter_rssi: uint8 = 0
    
    var armingStatusText: (String, Color) {
        if armingStatus & (1 << 15) > 0 {
            return ("HARDWARE", Color.red)
        } else if armingStatus & (1 << 2) > 0 {
            return ("ARMED", Color.purple)
        } else if armingStatus & (1 << 8) > 0 {
            return ("NOT LEVEL", Color.red)
        } else if armingStatus & (1 << 11) > 0 {
            return ("NAV UNSAFE", Color.red)
        } else {
            return ("READY", Color.green)
        }
    }
    
    var flightModeText: String {
        var modes: [String] = []
        
        var flightMode = Int(flight_mode)
        var tenThousands: Int = flightMode / 10000
        flightMode -= tenThousands * 10000
        var thousands: Int = flightMode / 1000
        flightMode -= thousands * 1000
        var hundreds: Int = flightMode / 100
        flightMode -= hundreds * 100
        var tens: Int = flightMode / 10
        
//        // ten thousands column
//        if (FLIGHT_MODE(FLAPERON))
//            tmpi += 10000;
//        if (FLIGHT_MODE(FAILSAFE_MODE))
//            tmpi += 40000;
//        else if (FLIGHT_MODE(AUTO_TUNE)) // intentionally reverse order and 'else-if' to prevent 16-bit overflow
//            tmpi += 20000;
        if(tenThousands >= 4) { modes.append("FAILSAFE"); tenThousands -= 4; }
        if(tenThousands >= 2) { modes.append("AUTO_TUNE"); tenThousands -= 2; }
        if(tenThousands == 1) { modes.append("FLAPERON") }
        
        // thousands column
//        if (FLIGHT_MODE(NAV_RTH_MODE))
//            tmpi += 1000;
//        if (FLIGHT_MODE(NAV_COURSE_HOLD_MODE)) // intentionally out of order and 'else-ifs' to prevent column overflow
//            tmpi += 8000;
//        else if (FLIGHT_MODE(NAV_WP_MODE))
//            tmpi += 2000;
//        else if (FLIGHT_MODE(HEADFREE_MODE))
//            tmpi += 4000;
        
        if(thousands >= 8) { modes.append("NAV_COURSE_HOLD"); thousands -= 8; }
        if(thousands >= 4) { modes.append("HEADFREE"); thousands -= 4;  }
        if(thousands >= 2) { modes.append("NAV_WP"); thousands -= 2; }
        if(thousands == 1) { modes.append("NAV_RTH"); }
        
        // hundreds column
//        if (FLIGHT_MODE(HEADING_MODE))
//            tmpi += 100;
//        if (FLIGHT_MODE(NAV_ALTHOLD_MODE))
//            tmpi += 200;
//        if (FLIGHT_MODE(NAV_POSHOLD_MODE))
//            tmpi += 400;

        if(hundreds >= 4) { modes.append("NAV_POS_HOLD"); hundreds -= 4; }
        if(hundreds >= 2) { modes.append("NAV_ALT_HOLD"); hundreds -= 2; }
        if(hundreds == 1) { modes.append("HEADING"); }
        
        // tens column
//        if (FLIGHT_MODE(ANGLE_MODE))
//            tmpi += 10;
//        if (FLIGHT_MODE(HORIZON_MODE))
//            tmpi += 20;
//        if (FLIGHT_MODE(MANUAL_MODE))
//            tmpi += 40;

        if(tens >= 4) { modes.append("MANUAL"); tens -= 4; }
        if(tens >= 2) { modes.append("HORIZON"); tens -= 2; }
        if(tens == 1) { modes.append("ANGLE"); }
    
        return modes.joined(separator: "/")
    }
    
    var formattedOnTime: String {
        let formatter = DateComponentsFormatter()
        let interval: TimeInterval = Double(onTime) / 1000.0
        return formatter.string(from: interval)!
    }
    
    var gpsAltitudeDataPoint: DataPoint<Int32> {
        return DataPoint(time: Double(onTime) / 1000.0, name: "GPS", value: Int32(gps_altitude_meters) - Int32(home_altitude_meters))
    }
    
    var baroAltitudeDataPoint: DataPoint<Int32> {
        return DataPoint(time: Double(onTime) / 1000.0, name: "Barometer", value: baro_altitude_meters)
    }
    
    var calculatedAltitudeDataPoint: DataPoint<Int32> {
        return DataPoint(time: Double(onTime) / 1000.0, name: "iNav", value: inav_z_position)
    }
    
    var gyroXDataPoint: DataPoint<Int16> {
        return DataPoint(time: Double(onTime) / 1000.0, name: "X", value: gyro_x)
    }
    
    var gyroYDataPoint: DataPoint<Int16> {
        return DataPoint(time: Double(onTime) / 1000.0, name: "Y", value: gyro_y)
    }
    
    var gyroZDataPoint: DataPoint<Int16> {
        return DataPoint(time: Double(onTime) / 1000.0, name: "Z", value: gyro_z)
    }
    
    var speedDataPoint: DataPoint<Int16> {
        return DataPoint(time: Double(onTime) / 1000.0, name: "Speed", value: gps_groundSpeed)
    }
    
    var accelXDataPoint: DataPoint<Double> {
        return DataPoint(time: Double(onTime) / 1000.0, name: "X", value: Double(acc_x) / 512.0)
    }
    
    var accelYDataPoint: DataPoint<Double> {
        return DataPoint(time: Double(onTime) / 1000.0, name: "Y", value: Double(acc_y) / 512.0)
    }
    
    var accelZDataPoint: DataPoint<Double> {
        return DataPoint(time: Double(onTime) / 1000.0, name: "Z", value: Double(acc_z) / 512.0)
    }
    
    var gpsLocation: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(gps_latitude) / Double(10000000), longitude: Double(gps_longitude) / Double(10000000))
    }
    
    init() {
        
    }
    
    init(from: String) {
        let data = Data(hex: from)
        self.init(data: [UInt8](data!))
    }
    
    init(data: [UInt8]) {
        var index: Int = 0
        id = 0
        read(val: &onTime, data: data, index: &index)
        id = onTime
        read(val: &armingStatus, data: data, index: &index)
        read(val: &status, data: data, index: &index)
        read(val: &batteryPercentage, data: data, index: &index)
        read(val: &home_distance, data: data, index: &index)
        read(val: &home_direction, data: data, index: &index)
        read(val: &gps_number_satellites, data: data, index: &index)
        read(val: &roll, data: data, index: &index)
        read(val: &pitch, data: data, index: &index)
        read(val: &yaw, data: data, index: &index)
        read(val: &acc_x, data: data, index: &index)
        read(val: &acc_y, data: data, index: &index)
        read(val: &acc_z, data: data, index: &index)
        read(val: &gyro_x, data: data, index: &index)
        read(val: &gyro_y, data: data, index: &index)
        read(val: &gyro_z, data: data, index: &index)
        read(val: &mag_x, data: data, index: &index)
        read(val: &mag_y, data: data, index: &index)
        read(val: &mag_z, data: data, index: &index)
        read(val: &gps_latitude, data: data, index: &index)
        read(val: &gps_longitude, data: data, index: &index)
        read(val: &gps_groundCourse, data: data, index: &index)
        read(val: &gps_groundSpeed, data: data, index: &index)
        read(val: &gps_altitude_meters, data: data, index: &index)
        read(val: &baro_altitude_meters, data: data, index: &index)
        read(val: &inav_z_position, data: data, index: &index)
        read(val: &inav_z_velocity, data: data, index: &index)
        read(val: &rx_roll, data: data, index: &index)
        read(val: &rx_pitch, data: data, index: &index)
        read(val: &rx_yaw, data: data, index: &index)
        read(val: &rx_throttle, data: data, index: &index)
        read(val: &home_latitude, data: data, index: &index)
        read(val: &home_longitude, data: data, index: &index)
        read(val: &home_altitude_meters, data: data, index: &index)
        read(val: &lora_rssi, data: data, index: &index)
        read(val: &flight_mode, data: data, index: &index)
        read(val: &transmitter_rssi, data: data, index: &index)
    }
   
    func read(val: inout UInt32, data: [UInt8], index: inout Int) {
        val = UInt32(data[index++]) |  UInt32(data[index++]) << 8 | UInt32(data[index++]) << 16 | UInt32(data[index++]) << 24
    }
    
    func read(val: inout Int32, data: [UInt8], index: inout Int) {
        val = Int32(data[index++]) | Int32(data[index++]) << 8 | Int32(data[index++]) << 16 | Int32(data[index++]) << 24
    }
    
    func read(val: inout Int16, data: [UInt8], index: inout Int) {
        val = Int16(data[index++]) | Int16(data[index++]) << 8
    }
    
    func read(val: inout UInt16, data: [UInt8], index: inout Int) {
        val = UInt16(data[index++]) | UInt16(data[index++]) << 8
    }
    
    func read(val: inout Int8, data: [UInt8], index: inout Int) {
        val = Int8(bitPattern: data[index++])
    }
    
    func read(val: inout UInt8, data: [UInt8], index: inout Int) {
        val = data[index++]
    }
}
