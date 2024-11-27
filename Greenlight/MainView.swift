//
//  MainView.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 27/11/24.
//

import SwiftUI
import CoreLocation

struct MainView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("PrimaryAccentColor").edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Text("Greenlight")
                            .font(.custom("Soulmeh", size: 30))
                        Spacer()
                    }
                    .padding()
                    .background(Color("TextColor"))
                    .foregroundColor(Color("PrimaryAccentColor"))
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    NavigationLink(destination: RealTimeMapView()) {
                        Text("Show Real-Time Map")
                            .font(.headline)
                            .foregroundColor(Color("PrimaryAccentColor"))
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color("TextColor"))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
                    
                    NavigationLink(destination: ChooseRouteView()) {
                        Text("Choose Bus Route")
                            .font(.headline)
                            .foregroundColor(Color("PrimaryAccentColor"))
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color("TextColor"))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
                    
                    Button(action: logout) {
                        Text("Logout")
                            .font(.headline)
                            .foregroundColor(Color("PrimaryAccentColor"))
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color("TextColor"))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 150)
                }
            }
        }
    }
    
    func logout() {
        authManager.logout()
    }
}

#Preview {
    MainView()
}
