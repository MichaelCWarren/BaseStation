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
    
    var updateFrequencyFormatted: String {
        return viewModel.updateFrequency.formatted(.number.precision(.fractionLength(2)))
    }
    
    var updatePeriodFormatted: String {
        let period = Int(viewModel.updatePeriod * 1000)
        return "\(period) ms"
    }
    
    var body: some View {
        GeometryReader { metrics in
            Grid(horizontalSpacing: 20, verticalSpacing: 20) {
                GridRow {
                    VStack {
                        Text("Altitude").font(.title)
                        Chart(viewModel.altitudeDataPoints) { dp in
                            LineMark(
                                x: .value("Time", dp.time),
                                y: .value("Altitude", dp.value)
                            ).foregroundStyle(by: .value("Source", dp.name))
                        }.chartXScale(domain: viewModel.dataRange, type: ScaleType.linear)
                            .chartXAxisLabel("Time (seconds)")
                            .chartYScale(domain: -5...200, type: ScaleType.linear)
                            .chartYAxisLabel("Altitude (meters)")
                    }
                    VStack {
                        Text("Speed").font(.title)
                        Chart(viewModel.speedDataPoints) { dp in
                            LineMark(
                                x: .value("Time", dp.time) ,
                                y: .value("m/s", dp.value)
                            )
                        }.chartXScale(domain: viewModel.dataRange, type: ScaleType.linear)
                            .chartXAxisLabel("Time (seconds)")
                            .chartYScale(domain: 0...25, type: ScaleType.linear)
                            .chartYAxisLabel("Speed (m/s)")
                    }
                    
                    VStack {
                        Text("Gyroscope").font(.title)
                        Chart(viewModel.gyroDataPoints) { dp in
                            LineMark(
                                x: .value("Time", dp.time) ,
                                y: .value("Value", dp.value)
                            ).foregroundStyle(by: .value("Axis", dp.name))
                        }.chartXScale(domain: viewModel.dataRange, type: ScaleType.linear)
                            .chartXAxisLabel("Time (seconds)")
                            .chartYScale(domain: -720...720, type: ScaleType.linear)
                            .chartYAxisLabel("Angular Velocity (deg/sec)")
                    }
                    
                    VStack {
                        Text("Accelerometer").font(.title)
                        Chart(viewModel.accelDataPoints) { dp in
                            LineMark(
                                x: .value("Time", dp.time),
                                y: .value("Value", Float(dp.value) / 512.0)
                            ).foregroundStyle(by: .value("Axis", dp.name))
                        }.chartXScale(domain: viewModel.dataRange, type: ScaleType.linear)
                            .chartXAxisLabel("Time (seconds)")
                            .chartYScale(domain: -1...1, type: ScaleType.linear)
                            .chartYAxisLabel("Acceleration (g)")
                    }
                }.frame(height: metrics.size.height * 0.35)
                
                GridRow {
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
                
                        ArtificialHorizon(width: 275, height: 275, roll: viewModel.attitudeRoll, pitch: viewModel.attitudePitch)
                        
                        Spacer()
                        HStack {
                            Spacer()
                            Joystick(width: 200, x: viewModel.yaw, y: 1 - viewModel.throttle)
                            Spacer()
                            Joystick(width: 200, x: viewModel.roll, y: 1 - viewModel.pitch)
                            Spacer()
                        }
                        Spacer()
                    }
                    DroneMapView(viewModel: viewModel)
                        .gridCellColumns(2)
                    VStack {
                        Text("Raw Data").font(.title)
                        Spacer()
                        if let droneDataPoint =  viewModel.currentDroneDataPoint {
                            Group {
                                HStack {
                                    Text("On-time")
                                    Spacer()
                                    Text(droneDataPoint.formattedOnTime)
                                }
                                Divider()
                                HStack {
                                    Text("Attitude")
                                    Spacer()
                                    Grid {
                                        GridRow {
                                            Text("Roll").gridColumnAlignment(.trailing)
                                            Text("\(droneDataPoint.roll / 10)").gridColumnAlignment(.trailing)
                                        }
                                        GridRow {
                                            Text("Pitch").gridColumnAlignment(.trailing)
                                            Text("\(droneDataPoint.pitch / 10)").gridColumnAlignment(.trailing)
                                        }
                                        GridRow {
                                            Text("Heading").gridColumnAlignment(.trailing)
                                            Text("\(droneDataPoint.yaw)").gridColumnAlignment(.trailing)
                                        }
                                    }
                                    
                                }
                                Divider()
                                HStack {
                                    Text("Gyroscope")
                                    Spacer()
                                    Grid {
                                        GridRow {
                                            Text("X").gridColumnAlignment(.trailing)
                                            Text("\(droneDataPoint.gyro_x)").gridColumnAlignment(.trailing)
                                        }
                                        GridRow {
                                            Text("Y").gridColumnAlignment(.trailing)
                                            Text("\(droneDataPoint.gyro_y)").gridColumnAlignment(.trailing)
                                        }
                                        GridRow {
                                            Text("Z").gridColumnAlignment(.trailing)
                                            Text("\(droneDataPoint.gyro_z)").gridColumnAlignment(.trailing)
                                        }
                                    }
                                    
                                }
                                Divider()
                                HStack {
                                    Text("Accelerometer")
                                    Spacer()
                                    Grid {
                                        GridRow {
                                            Text("X").gridColumnAlignment(.trailing)
                                            Text("\(Double(droneDataPoint.acc_x)/512.0 )").gridColumnAlignment(.trailing)
                                        }
                                        GridRow {
                                            Text("Y").gridColumnAlignment(.trailing)
                                            Text("\(Double(droneDataPoint.acc_y)/512.0)").gridColumnAlignment(.trailing)
                                        }
                                        GridRow {
                                            Text("Z").gridColumnAlignment(.trailing)
                                            Text("\(Double(droneDataPoint.acc_x)/512.0)").gridColumnAlignment(.trailing)
                                        }
                                    }
                                    
                                }
                                Divider()
                            }
                            Group {
                                HStack {
                                    Text("Magnetometer")
                                    Spacer()
                                    Grid {
                                        GridRow {
                                            Text("X").gridColumnAlignment(.trailing)
                                            Text("\(droneDataPoint.mag_x )").gridColumnAlignment(.trailing)
                                        }
                                        GridRow {
                                            Text("Y").gridColumnAlignment(.trailing)
                                            Text("\(droneDataPoint.mag_y)").gridColumnAlignment(.trailing)
                                        }
                                        GridRow {
                                            Text("Z").gridColumnAlignment(.trailing)
                                            Text("\(droneDataPoint.mag_z)").gridColumnAlignment(.trailing)
                                        }
                                    }
                                    
                                }
                                Divider()
                                HStack {
                                    Text("Altitude")
                                    Spacer()
                                    Grid {
                                        GridRow {
                                            Text("Barometer").gridColumnAlignment(.trailing)
                                            Text("\(droneDataPoint.baro_altitude_meters) m").gridColumnAlignment(.trailing)
                                        }
                                        GridRow {
                                            Text("GPS").gridColumnAlignment(.trailing)
                                            Text("\(droneDataPoint.gps_altitude_meters) m").gridColumnAlignment(.trailing)
                                        }
                                        GridRow {
                                            Text("iNav").gridColumnAlignment(.trailing)
                                            Text("\(droneDataPoint.inav_z_position) m").gridColumnAlignment(.trailing)
                                        }
                                    }
                                }
                                Divider()
                                HStack {
                                    Text("GPS")
                                    Spacer()
                                    Grid {
                                        GridRow {
                                            Text("Lat/Long").gridColumnAlignment(.trailing)
                                            Text("\(viewModel.droneLatitude), \(viewModel.droneLongitude)").gridColumnAlignment(.trailing)
                                        }
                                        GridRow {
                                            Text("Speed").gridColumnAlignment(.trailing)
                                            Text("\(droneDataPoint.gps_groundSpeed) m/s").gridColumnAlignment(.trailing)
                                        }
                                        GridRow {
                                            Text("Satellites").gridColumnAlignment(.trailing)
                                            Text("\(droneDataPoint.gps_number_satellites)").gridColumnAlignment(.trailing)
                                        }
                                    }
                                }
                                
                            }
                            Group {
                                Divider()
                                HStack {
                                    Text("Battery")
                                    Spacer()
                                    Text("\(droneDataPoint.batteryPercentage) %")
                                }
                                Divider()
                                HStack {
                                    Text("Home")
                                    Spacer()
                                    Grid {
                                        GridRow {
                                            Text("Lat/Long").gridColumnAlignment(.trailing)
                                            Text("\(viewModel.homeLatitude), \(viewModel.homeLongitude)").gridColumnAlignment(.trailing)
                                        }
                                        GridRow {
                                            Text("Altitude").gridColumnAlignment(.trailing)
                                            Text("\(droneDataPoint.home_altitude_meters) m").gridColumnAlignment(.trailing)
                                        }
                                        GridRow {
                                            Text("∆").gridColumnAlignment(.trailing)
                                            Text("\(droneDataPoint.home_distance)m @ \(droneDataPoint.home_direction)").gridColumnAlignment(.trailing)
                                        }
                                    }
                                }
                                Divider()
                                HStack {
                                    Text("Flight Mode")
                                    Spacer()
                                    Text(droneDataPoint.flightModeText)
                                }
                                Divider()
                                HStack {
                                    Text("Update Statistics")
                                    Spacer()
                                    Grid {
                                        GridRow {
                                            Text("Frequency").gridColumnAlignment(.trailing)
                                            Text("\(updateFrequencyFormatted) Hz").gridColumnAlignment(.trailing)
                                        }
                                        GridRow {
                                            Text("Period").gridColumnAlignment(.trailing)
                                            Text(updatePeriodFormatted).gridColumnAlignment(.trailing)
                                        }
                                        GridRow {
                                            Text("Latency").gridColumnAlignment(.trailing)
                                            Text("\(viewModel.latency) ms").gridColumnAlignment(.trailing)
                                        }
                                    }
                                }
                                Divider()
                                HStack {
                                    Text("RSSI")
                                    Spacer()
                                    Grid {
                                        GridRow {
                                            Text("LoRa").gridColumnAlignment(.trailing)
                                            Text("\(droneDataPoint.lora_rssi)").gridColumnAlignment(.trailing)
                                        }
                                        GridRow {
                                            Text("TX").gridColumnAlignment(.trailing)
                                            Text("\(droneDataPoint.transmitter_rssi)").gridColumnAlignment(.trailing)
                                        }
                                    }
                                }
                                
                                
                            }
                        } else {
                            Spacer()
                            Text("No Data").font(.title)
                            Spacer()
                        }
                        
                        Spacer()
                    }.font(Font.caption).padding(15)
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
