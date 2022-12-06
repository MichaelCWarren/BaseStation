//
//  DroneMapView.swift
//  BaseStation
//
//  Created by Michael Warren on 12/4/22.
//

import SwiftUI
import MapKit


struct DroneMapView: View {
    @StateObject var viewModel: ViewModel
        
    var body: some View {
        ZStack {
            BaseMapView(coordinateRegion: $viewModel.region, annotationItems: $viewModel.annotationItems, path: $viewModel.history)

            VStack {
                Spacer()
                HStack {
                    Button("Reset Mins") {
                        viewModel.resetMins()
                    }
                    Spacer()
                    Button("Toggle Updates") {
                        viewModel.toggleRegionUpdates()
                    }
                }.padding(30).foregroundColor(.white)
            }
        }
    }
}
