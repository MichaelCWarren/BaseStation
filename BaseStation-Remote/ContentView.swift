//
//  ContentView.swift
//  DroneStatus
//
//  Created by Michael Warren on 11/18/22.
//

import SwiftUI
import MapKit


struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true,  annotationItems: [viewModel.droneAnnotation]) { drone in
                MapMarker(coordinate: drone.location)
            }
            .edgesIgnoringSafeArea(.all)
            
            if let dataPoint = viewModel.currentDroneDataPoint {
                VStack {
                    HStack {
                        Button("Reset Map") {
                            viewModel.resetMins()
                        }
                        Spacer()
                        Button("Toggle Updates") {
                            viewModel.toggleRegionUpdates()
                        }
                    }.padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
                    HStack {
                        Grid {
                            GridRow {
                                Text("RSSI:").font(.title2).gridColumnAlignment(.trailing)
                                Text("\(dataPoint.rssi)").font(.title2).gridColumnAlignment(.leading)
                            }
                        }
                        
                        Spacer()
                        Grid {
                            GridRow {
                                Text("Altitude:").font(.title2).gridColumnAlignment(.trailing)
                                Text("\(dataPoint.gps_altitude_meters)").font(.title2).gridColumnAlignment(.leading)
                            }
                            GridRow {
                                Text("Speed:").font(.title2).gridColumnAlignment(.trailing)
                                Text("\(dataPoint.gps_groundSpeed) m/s").font(.title2).gridColumnAlignment(.leading)
                            }
                        }
                        VStack {
                            
                        }
                    }.padding(EdgeInsets(top: 10, leading: 30, bottom: 0, trailing: 30))
                    
                    Spacer()
                    HStack {
                        Grid {
                            GridRow {
                                Text("Roll:").font(.title2).gridColumnAlignment(.trailing)
                                Text("\(dataPoint.roll)").font(.title2).gridColumnAlignment(.leading)
                            }
                            GridRow {
                                Text("Pitch:").font(.title2).gridColumnAlignment(.trailing)
                                Text("\(dataPoint.pitch)").font(.title2).gridColumnAlignment(.leading)
                            }
                            GridRow {
                                Text("Yaw:").font(.title2).gridColumnAlignment(.trailing)
                                Text("\(dataPoint.yaw)").font(.title2).gridColumnAlignment(.leading)
                            }
                        }
                        Spacer()
                        Grid {
                            GridRow {
                                Text("Distance To Home:").font(.title2).gridColumnAlignment(.trailing)
                                Text("\(dataPoint.distanceToHome) m").font(.title2).gridColumnAlignment(.leading)
                            }
                            GridRow {
                                Text("Direction To Home:").font(.title2).gridColumnAlignment(.trailing)
                                Text("\(dataPoint.directionToHome)").font(.title2).gridColumnAlignment(.leading)
                            }
                            
                        }
                    }.padding(30)
                }
            }
           
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
