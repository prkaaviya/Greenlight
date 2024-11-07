//
//  GPSView.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 17/10/24.
//

import SwiftUI
import CoreLocation
import MapboxMaps

struct GPSView: View {
    @StateObject var locationManager = LocationManager()
    @State private var isShowingAddRouteView = false
    @State private var favoriteRoute: String = ""
    @State private var favoriteRouteName: String = ""
    @State private var showAlert = false  // Alert state variable

    var body: some View {
        NavigationView {
            ZStack {
                Color("PrimaryAccentColor").edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Dashboard at the top
                    HStack {
                        Image(systemName: "line.horizontal.3")
                            .font(.system(size: 30))
                            .padding(.leading, 10)
                        Spacer()
                        Text("Greenlight")
                            .font(.custom("Soulmeh", size: 30))
                        Spacer()
                    }
                    .padding()
                    .background(Color("TextColor"))
                    .foregroundColor(Color("PrimaryAccentColor"))
                    .cornerRadius(10)
                    
                    HStack {
                        Text("You are located in \(locationManager.locationName).")
                            .font(.custom("MonofontoRegular", size: 20))
                    }
                    .foregroundColor(Color("TextColor"))
                    .padding()
                    
                    VStack {
                        Text("Latitude: \(locationManager.userLatitude)")
                            .font(.custom("MonofontoRegular", size: 15))
                            .foregroundColor(.white)
                        Text("Longitude: \(locationManager.userLongitude)")
                            .font(.custom("MonofontoRegular", size: 15))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 10)
                    
                    // Pass stops to MapboxUIView if available
                    MapboxUIView(
                        coordinate: CLLocationCoordinate2D(latitude: locationManager.userLatitude, longitude: locationManager.userLongitude)
                    )
                    .frame(height: 500)
                    .cornerRadius(10)
                    .padding()
                    
                    Spacer()
                    
                    NavigationLink(destination: AddFavoriteRouteView(favoriteRoute: $favoriteRoute, favoriteRouteName: $favoriteRouteName, showAlert: $showAlert)) {
                        Text("Add Favorite Route")
                            .font(.headline)
                            .foregroundColor(Color("PrimaryAccentColor"))
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color("TextColor"))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                .cornerRadius(10)
                .onAppear {
                    loadFavoriteRoute()
                }
            }
            .cornerRadius(10)
        }
        .cornerRadius(10)
    }
    
    private func loadFavoriteRoute() {
        if let savedRoute = RoutePreference.getFavoriteRoute() {
            favoriteRoute = savedRoute.routeId
            favoriteRouteName = savedRoute.routeName
            print("DEBUG Saved favourite route: \(favoriteRouteName) - \(favoriteRoute)")
        }
    }
}
