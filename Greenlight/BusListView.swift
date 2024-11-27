//
//  BusListView.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 07/11/24.
//

import SwiftUI
import CoreLocation

struct BusListView: View {
    @ObservedObject var busLocationManager: BusLocationManager
    let userLocation: CLLocation  // Accepts user location
    let favoriteRoute: String
    let favoriteRouteName: String // Favorite route name for display
    @State private var isMapViewActive = false  // State to control navigation to map view
    
    var body: some View {
        VStack {
            Text("Bus timings for \(favoriteRouteName)")
                .font(.title)
                .padding()
            
            if !busLocationManager.direction0Locations.isEmpty {
                Section(header: Text("Towards \(busLocationManager.direction0Locations.first?.destinationStopName ?? "Unknown")")) {
                    List(busLocationManager.direction0Locations, id: \.id) { location in
                        BusLocationRow(location: location, userLocation: userLocation)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }

            if !busLocationManager.direction1Locations.isEmpty {
                Section(header: Text("Towards \(busLocationManager.direction1Locations.first?.destinationStopName ?? "Unknown")")) {
                    List(busLocationManager.direction1Locations, id: \.id) { location in
                        BusLocationRow(location: location, userLocation: userLocation)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            
            if busLocationManager.direction0Locations.isEmpty && busLocationManager.direction1Locations.isEmpty {
                Text("No bus locations available for the selected route. Please refresh.")
                    .foregroundColor(.gray)
                    .padding()
                Button(action: {
                                print("DEBUG: Manual refresh triggered")
                                busLocationManager.startUpdatingBusLocations(for: favoriteRoute, userLocation: userLocation)
                            }) {
                                Text("Refresh")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            .padding(.bottom, 10)
                            
            }
            
            // "Show on Map" button
            Button(action: {
                isMapViewActive = true
            }) {
                Text("Show on Map")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            
            // Navigation link to the Map View
            NavigationLink(
                destination: RealTimeMapView(
                    busLocations: busLocationManager.busLocations,
                    userLocation: userLocation
                ),
                isActive: $isMapViewActive
            ) {
                EmptyView()
            }
        }
        .onAppear {
            busLocationManager.startUpdatingBusLocations(for: favoriteRoute, userLocation: userLocation)
        }
        .padding()
    }
}

struct BusLocationRow: View {
    let location: BusLocation
    let userLocation: CLLocation
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(location.stopName)
                .font(.headline)
            Text("Arrival Delay: \(location.arrivalDelay != nil ? "\(location.arrivalDelay! / 60) min" : "N/A")")
            Text("Departure Delay: \(location.departureDelay != nil ? "\(location.departureDelay! / 60) min" : "N/A")")
            Text("Distance from user: \(location.distance(from: userLocation) / 1000, specifier: "%.2f") km")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}
