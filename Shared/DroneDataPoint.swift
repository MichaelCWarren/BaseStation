//
//  DroneData.swift
//  BaseStation
//
//  Created by Michael Warren on 12/1/22.
//

import Foundation
import SwiftUI

struct DataPoint<T> : Identifiable {
    var id: UUID = UUID()
    var time: UInt32
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
    var distanceToHome: UInt16 = 0
    var directionToHome: Int16 = 0
    var gps_fix_type: UInt8 = 0
    var gps_number_satellites: UInt8 = 0
    var inav_mode: UInt8 = 0
    var inav_state: UInt8 = 0
    var inav_wp_action: UInt8 = 0
    var inav_wp_number: UInt8 = 0
    var inav_heading_target: Int16 = 0
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
    var throttlePercent: Int8 = 0
    var rssi: Int8 = 0
    
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
    
    var formattedOnTime: String {
        let formatter = DateComponentsFormatter()
        let interval: TimeInterval = Double(onTime) / 1000.0
        return formatter.string(from: interval)!
    }
    
    var gpsAltitudeDataPoint: DataPoint<Int32> {
        return DataPoint(time: onTime, name: "GPS", value: Int32(gps_altitude_meters))
    }
    
    var baroAltitudeDataPoint: DataPoint<Int32> {
        return DataPoint(time: onTime, name: "Barometer", value: baro_altitude_meters)
    }
    
    var gyroXDataPoint: DataPoint<Int16> {
        return DataPoint(time: onTime, name: "X", value: gyro_x)
    }
    
    var gyroYDataPoint: DataPoint<Int16> {
        return DataPoint(time: onTime, name: "Y", value: gyro_y)
    }
    
    var gyroZDataPoint: DataPoint<Int16> {
        return DataPoint(time: onTime, name: "Z", value: gyro_z)
    }
    
    var speedDataPoint: DataPoint<Int16> {
        return DataPoint(time: onTime, name: "Speed", value: gps_groundSpeed)
    }
    
    var accelXDataPoint: DataPoint<Int16> {
        return DataPoint(time: onTime, name: "X", value: acc_x)
    }
    
    var accelYDataPoint: DataPoint<Int16> {
        return DataPoint(time: onTime, name: "Y", value: acc_y)
    }
    
    var accelZDataPoint: DataPoint<Int16> {
        return DataPoint(time: onTime, name: "Z", value: acc_z)
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
        read(val: &distanceToHome, data: data, index: &index)
        read(val: &directionToHome, data: data, index: &index)
        read(val: &gps_fix_type, data: data, index: &index)
        read(val: &gps_number_satellites, data: data, index: &index)
        read(val: &inav_mode, data: data, index: &index)
        read(val: &inav_state, data: data, index: &index)
        read(val: &inav_wp_action, data: data, index: &index)
        read(val: &inav_wp_number, data: data, index: &index)
        read(val: &inav_heading_target, data: data, index: &index)
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
        read(val: &throttlePercent, data: data, index: &index)
        read(val: &rssi, data: data, index: &index)
    }
   
    
    func read(val: inout UInt32, data: [UInt8], index: inout Int) {
        val = UInt32(data[index++]) << 24 | UInt32(data[index++]) << 16 | UInt32(data[index++]) << 8 | UInt32(data[index++])
    }
    
    func read(val: inout Int32, data: [UInt8], index: inout Int) {
        val = Int32(data[index++]) << 24 | Int32(data[index++]) << 16 | Int32(data[index++]) << 8 | Int32(data[index++])
    }
    
    func read(val: inout Int16, data: [UInt8], index: inout Int) {
        val = Int16(data[index++]) << 8 | Int16(data[index++])
    }
    
    func read(val: inout UInt16, data: [UInt8], index: inout Int) {
        val = UInt16(data[index++]) << 8 | UInt16(data[index++])
    }
    
    func read(val: inout Int8, data: [UInt8], index: inout Int) {
        val = Int8(bitPattern: data[index++])
    }
    
    func read(val: inout UInt8, data: [UInt8], index: inout Int) {
        val = data[index++]
    }
}
