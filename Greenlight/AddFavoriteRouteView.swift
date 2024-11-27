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
    @Binding var isBusListViewActive: Bool
    
    let routeNamesList = ["46A", "39A", "C1", "C2", "145", "155"]

    var body: some View {
        VStack {
            Text("Choose a bus route.")
                .font(.title2)
                .foregroundColor(Color("PrimaryAccentColor"))
                .fontWeight(.bold)
                .padding(.top, 30)
            
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
    }
    
    private func routeButton(for routeName: String) -> some View {
        Group {
            Button(action: {
                print("\(routeName) selected")
                isLoading = true

                // Save the selected route to UserDefaults
                if let routeId = RouteService.shared.getRouteId(for: routeName) {
                    RoutePreference.saveFavoriteRoute(routeId: routeId, routeName: routeName)
                    favoriteRoute = routeId
                    favoriteRouteName = routeName
                    isLoading = false
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
    AddFavoriteRouteView(favoriteRoute: .constant(""), favoriteRouteName: .constant(""), isBusListViewActive: .constant(false)
)
}
