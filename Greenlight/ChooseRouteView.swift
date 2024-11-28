//
//  ChooseRouteView.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 27/11/24.
//

import SwiftUI
import CoreLocation

struct ChooseRouteView: View {
    @State private var routes: [String] = ["46A", "39A", "C1", "C2", "145", "155"] // Predefined routes
    @State private var selectedRouteId: String? // Selected route ID
    @State private var selectedRouteName: String? // Selected route name
    @State private var isBusListViewActive = false // Navigation state

    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationView {
            ZStack {
                Color("PrimaryAccentColor").edgesIgnoringSafeArea(.all)

                VStack {
                    Text("Select a bus route.")
                        .font(.largeTitle)
                        .foregroundColor(Color("TextColor"))
                        .padding()

                    if routes.isEmpty {
                        Text("Loading routes...")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ScrollView {
                            ForEach(routes, id: \.self) { routeName in
                                Button(action: {
                                    selectedRouteId = RouteService.shared.getRouteId(for: routeName) // Get route ID dynamically
                                    selectedRouteName = routeName
                                    isBusListViewActive = true
                                }) {
                                    Text(routeName)
                                        .font(.headline)
                                        .foregroundColor(Color("PrimaryAccentColor"))
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color("TextColor"))
                                        .cornerRadius(10)
                                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 4)
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 10)
                            }
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Routes")
            .navigationBarTitleDisplayMode(.inline)
            NavigationLink(
                destination: BusListView(
                    busLocationManager: BusLocationManager(),
                    userLocation: locationManager.currentLocation ?? CLLocation(latitude: 0, longitude: 0), // Safe fallback
                    favoriteRoute: selectedRouteId ?? "", // Route ID
                    favoriteRouteName: selectedRouteName ?? "" // Route Name
                ),
                isActive: $isBusListViewActive
            ) {
                EmptyView()
            }
        }
    }
}

#Preview {
    ChooseRouteView()
}
