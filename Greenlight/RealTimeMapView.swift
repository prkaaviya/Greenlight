//
//  RealTimeMapView.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 27/11/24.
//

import SwiftUI
import MapboxMaps
import CoreLocation

struct RealTimeMapView: View {
    let busLocations: [BusLocation]
    let userLocation: CLLocation
    
    var body: some View {
        ZStack {
            Color("PrimaryAccentColor").edgesIgnoringSafeArea(.all)
            
            MapboxUIView(coordinate: userLocation.coordinate, busLocations: .constant(busLocations))
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Real-Time Map")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
                    .padding(.top, 50)
                
                Spacer()
            }
        }
    }
}

