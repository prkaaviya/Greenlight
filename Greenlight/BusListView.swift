//
//  BusListView.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 27/11/24.
//

import SwiftUI
import CoreLocation

struct BusListView: View {
    @ObservedObject var busLocationManager: BusLocationManager // Manages bus locations
    let userLocation: CLLocation // User's current location
    let favoriteRoute: String // Selected route ID
    let favoriteRouteName: String // Selected route name

    @State private var isMapViewActive = false // Controls navigation to Map View

    var body: some View {
        VStack {
            Text("Bus timings for \(favoriteRouteName)")
                .font(.title)
                .padding()

            // Display buses for direction 0
            if !busLocationManager.direction0Locations.isEmpty {
                Section(header: Text("Towards \(busLocationManager.direction0Locations.first?.destinationStopName ?? "Unknown")")) {
                    List(busLocationManager.direction0Locations, id: \.id) { location in
                        BusLocationRow(location: location, userLocation: userLocation)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }

            // Display buses for direction 1
            if !busLocationManager.direction1Locations.isEmpty {
                Section(header: Text("Towards \(busLocationManager.direction1Locations.first?.destinationStopName ?? "Unknown")")) {
                    List(busLocationManager.direction1Locations, id: \.id) { location in
                        BusLocationRow(location: location, userLocation: userLocation)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }

            // If no buses are available, show a message
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

            NavigationLink(
                destination: RealTimeMapView(
//                    busLocations: busLocationManager.busLocations,
//                    userLocation: userLocation
                ),
                isActive: $isMapViewActive
            ) {
                EmptyView()
            }
        }
        .onAppear {
            // Start fetching bus locations for the selected route
            busLocationManager.startUpdatingBusLocations(for: favoriteRoute, userLocation: userLocation)
        }
        .padding()
    }
}

// Row view for displaying bus location details
struct BusLocationRow: View {
    let location: BusLocation
    let userLocation: CLLocation

    var body: some View {
        VStack(alignment: .leading) {
            Text(location.stopName)
                .font(.headline)
            Text("Arrival Delay: \(location.arrivalDelay != nil ? "\(location.arrivalDelay! / 60) min" : "N/A")")
            Text("Departure Delay: \(location.departureDelay != nil ? "\(location.departureDelay! / 60) min" : "N/A")")
            Text("Distance from you: \(location.distance(from: userLocation) / 1000, specifier: "%.2f") km")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    BusListView(
        busLocationManager: BusLocationManager(),
        userLocation: CLLocation(latitude: 53.3498, longitude: -6.2603), // Example: Dublin coordinates
        favoriteRoute: "46A",
        favoriteRouteName: "Route 46A"
    )
}
