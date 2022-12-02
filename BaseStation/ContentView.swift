//
//  ContentView.swift
//  BaseStation
//
//  Created by Michael Warren on 12/1/22.
//

import SwiftUI
import Charts
import MapKit

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        GeometryReader { metrics in
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                GridRow {
                    VStack {
                        Text("Altitude").font(.title)
                        Chart(viewModel.altitudeDataPoints) { dp in
                            AreaMark(
                                x: .value("Time", Float(dp.time) / 1000.0),
                                y: .value("Altitude", dp.value)
                            ).foregroundStyle(by: .value("Source", dp.name))
                        }.chartXScale(domain: viewModel.dataRange, type: ScaleType.linear)
                        
                    }
                    
                    VStack {
                        Text("Speed").font(.title)
                        Chart(viewModel.speedDataPoints) { dp in
                            LineMark(
                                x: .value("Time", Float(dp.time) / 1000.0) ,
                                y: .value("m/s", dp.value)
                            )
                        }.chartXScale(domain: viewModel.dataRange, type: ScaleType.linear)
                    }
                    
                    VStack {
                        Text("Gyroscope").font(.title)
                        Chart(viewModel.gyroDataPoints) { dp in
                            LineMark(
                                x: .value("Time", Float(dp.time) / 1000.0) ,
                                y: .value("Value", dp.value)
                            ).foregroundStyle(by: .value("Axis", dp.name))
                        }.chartXScale(domain: viewModel.dataRange, type: ScaleType.linear)
                    }
                    
                    VStack {
                        Text("Accelerometer").font(.title)
                        Chart(viewModel.accelDataPoints) { dp in
                            LineMark(
                                x: .value("Time", Float(dp.time) / 1000.0),
                                y: .value("Value", Float(dp.value) / 512.0)
                            ).foregroundStyle(by: .value("Axis", dp.name))
                        }.chartXScale(domain: viewModel.dataRange, type: ScaleType.linear)
                    }
                }.frame(height: metrics.size.height * 0.35)
                
                GridRow {
                    VStack {
                        Spacer()
                        VStack {
                            Text("Joysticks").font(.title)
                            HStack {
                                Spacer()
                                Joystick(width: 200, x: viewModel.yaw, y: 1 - viewModel.throttle)
                                Spacer()
                                Joystick(width: 200, x: viewModel.roll, y: 1 - viewModel.pitch)
                                Spacer()
                            }
                        }
                        Spacer()
                        VStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.armingStatusColor.opacity(0.5))
                                .overlay {
                                    Text(viewModel.armingStatus)
                                        .foregroundColor(Color.white)
                                        .font(.title)
                                }.frame(minWidth: 1, maxWidth: 410, maxHeight: 50)
                                
                            Spacer()
                            HStack {
                                Image(systemName: "location.viewfinder")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(viewModel.isGPSActive ? Color.green : Color.gray)
                                    .padding(10)
                                
                                Image(systemName: "gyroscope")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(viewModel.isGyroActive ? Color.green : Color.gray)
                                    .padding(10)
                                
                                Image(systemName: "barometer")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(viewModel.isBaroActive ? Color.green : Color.gray)
                                    .padding(10)
                                
                                Image(systemName: "move.3d")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(viewModel.isAccelActive ? Color.green : Color.gray)
                                    .padding(10)
                                
                                Image(systemName: "safari")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(viewModel.isCompassActive ? Color.green : Color.gray)
                                    .padding(10)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    ZStack {
                        Map(coordinateRegion: $viewModel.region, annotationItems: [viewModel.droneAnnotation]) { drone in
                            MapMarker(coordinate: drone.location)
                        }
                        VStack {
                            HStack {
                                Button("Reset Mins") {
                                    viewModel.resetMins()
                                }
                                Spacer()
                                Button("Toggle Updates") {
                                    viewModel.toggleRegionUpdates()
                                }
                            }.padding(10)
                            Spacer()
                        }
                        
                    }.gridCellColumns(2)
                    VStack {
                        Text("Raw Data").font(.title)
                        if let droneDataPoint =  viewModel.currentDroneDataPoint {
                            HStack {
                                Text("On-time")
                                Spacer()
                                Text(droneDataPoint.formattedOnTime)
                            }
                            
                            HStack {
                                Text("Attitude")
                                Spacer()
                                Text("\(droneDataPoint.roll), \(droneDataPoint.pitch), \(droneDataPoint.yaw)")
                            }
                            
                            HStack {
                                Text("Gyro")
                                Spacer()
                                Text("X: \(droneDataPoint.gyro_x) Y: \(droneDataPoint.gyro_y) Z: \(droneDataPoint.gyro_z)")
                            }
                            
                            HStack {
                                Text("Accelerometer")
                                Spacer()
                                Text("X: \(droneDataPoint.acc_x ) Y: \(droneDataPoint.acc_y) Z: \(droneDataPoint.acc_z)")
                            }
                            
                            HStack {
                                Text("Magnetometer")
                                Spacer()
                                Text("X: \(droneDataPoint.mag_x ) Y: \(droneDataPoint.mag_y) Z: \(droneDataPoint.mag_z)")
                            }
                            
                            HStack {
                                Text("Altitude")
                                Spacer()
                                Text("Baro - \(droneDataPoint.baro_altitude_meters) m, GPS - \(droneDataPoint.gps_altitude_meters) m")
                            }
                            
                            HStack {
                                Text("GPS")
                                Spacer()
                                Text("\(droneDataPoint.gps_latitude), \(droneDataPoint.gps_longitude), \(droneDataPoint.gps_groundSpeed) m/s")
                            }
                            
                            HStack {
                                Text("Battery")
                                Spacer()
                                Text("\(droneDataPoint.batteryPercentage) %")
                            }
                            
                            HStack {
                                Text("Home")
                                Spacer()
                                Text("\(droneDataPoint.distanceToHome)m @ \(droneDataPoint.directionToHome)")
                            }
                            
                            HStack {
                                Text("RSSI")
                                Spacer()
                                Text("\(droneDataPoint.rssi)")
                            }
                        } else {
                            Spacer()
                            Text("No Data").font(.title)
                            Spacer()
                        }
                        
                        Spacer()
                    }.font(.title).padding(15)
                }
            }.padding(10)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
