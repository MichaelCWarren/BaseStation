//
//  DataProcessing.swift
//  BaseStation
//
//  Created by Michael Warren on 12/1/22.
//

import Foundation
import SwiftUI

class DataStore : NSObject {
    private var droneData: [DroneDataPoint] = []
    private var range = 30000
    private var startDroneTime = UInt32.max
    private var startTime = Date.now
    
    @Published var altitudeDataPoints: [DataPoint<Int32>] = []
    @Published var gyroDataPoints: [DataPoint<Int16>] = []
    @Published var speedDataPoints: [DataPoint<Int16>] = []
    @Published var accelDataPoints: [DataPoint<Int16>] = []
    
    var dataRange: ClosedRange<Int> {
        if(!droneData.isEmpty) {
            let first = Float(droneData.first!.onTime) / 1000.0
            let last = Float(droneData.last!.onTime) / 1000.0
            return  Int(first)...Int(max(last, 30))
        } else {
            return 0...30
        }
    }
    
    func add(data: DroneDataPoint) {
        if data.onTime < startDroneTime {
            startDroneTime = data.onTime
            startTime = Date.now
            altitudeDataPoints.removeAll()
            gyroDataPoints.removeAll()
            speedDataPoints.removeAll()
            accelDataPoints.removeAll()
        }
        var _data = data
        
        _data.onTime = data.onTime - startDroneTime
        let earlyLimit = max(0, Int(_data.onTime) - range)
        
        droneData.append(_data)
        droneData.removeAll { dp in
            dp.onTime < earlyLimit
        }
        
        altitudeDataPoints.append(_data.gpsAltitudeDataPoint)
        altitudeDataPoints.append(_data.baroAltitudeDataPoint)
        clamp(array: &altitudeDataPoints, earlyLimit: earlyLimit)
        
        gyroDataPoints.append(_data.gyroXDataPoint)
        gyroDataPoints.append(_data.gyroYDataPoint)
        gyroDataPoints.append(_data.gyroZDataPoint)
        clamp(array: &gyroDataPoints, earlyLimit: earlyLimit)
        
        speedDataPoints.append(_data.speedDataPoint)
        clamp(array: &speedDataPoints, earlyLimit: earlyLimit)
        
        accelDataPoints.append(_data.accelXDataPoint)
        accelDataPoints.append(_data.accelYDataPoint)
        accelDataPoints.append(_data.accelZDataPoint)
        clamp(array: &accelDataPoints, earlyLimit: earlyLimit)
        
    }
    
    func clamp<T>(array: inout [DataPoint<T>], earlyLimit: Int) {
        array.removeAll { dp in
            dp.time < earlyLimit
        }
    }
}
