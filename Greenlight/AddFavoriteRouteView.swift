//
//  AddFavoriteRouteView.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 07/11/24.
//

import SwiftUI

struct AddFavoriteRouteView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = false
    @Binding var favoriteRoute: String
    @Binding var favoriteRouteName: String
    @Binding var showAlert: Bool  // Binding to show alert in GPSView
    @Binding var isBusListViewActive: Bool
    
    // Example list of routes - implementing only 39A for now.
    let routeNamesList = ["46A", "39A", "C1", "C2", "145", "155"]

    var body: some View {
        VStack {
            Text("Select Favorite Route.")
                .font(.title2)
                .foregroundColor(Color("PrimaryAccentColor"))
                .fontWeight(.bold)
                .padding(.top, 60)
            
            Spacer()
            
            ForEach(routeNamesList, id: \.self) { routeName in
                routeButton(for: routeName)
            }
            
            Spacer()
            
            if isLoading {
                ProgressView("Loading route data...")
            }
        }
        .padding(.bottom, 20)
        .background(Color("TextColor"))
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Success"),
                message: Text("\(favoriteRouteName) saved as Favorite."),
                dismissButton: .default(Text("OK")) {
                    // Dismiss view after alert is acknowledged
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func routeButton(for routeName: String) -> some View {
        Group {
            if routeName == "39A" {
                Button(action: {
                    print("\(routeName) selected")
                    isLoading = true

                    // Save the selected route to UserDefaults
                    if let routeId = RouteService.shared.getRouteId(for: routeName) {
                        RoutePreference.saveFavoriteRoute(routeId: routeId, routeName: routeName)
                        favoriteRoute = routeId
                        favoriteRouteName = routeName
                        isLoading = false
                        showAlert = true  // Trigger alert
                        isBusListViewActive = true
                    }
                }) {
                    Text("Route \(routeName)")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("PrimaryAccentColor"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            } else {
                HStack {
                    Text("Route \(routeName)")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("WIP")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color("PrimaryAccentColor").opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
    }
}

extension Text {
    func routeButtonStyle(primary: Bool) -> some View {
        self.font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(primary ? Color("PrimaryAccentColor") : Color("PrimaryAccentColor").opacity(0.2))
            .cornerRadius(10)
            .foregroundColor(primary ? .white : .gray)
    }
}

#Preview {
    AddFavoriteRouteView(favoriteRoute: .constant(""), favoriteRouteName: .constant(""), showAlert: .constant(false), isBusListViewActive: .constant(false)
)
}
