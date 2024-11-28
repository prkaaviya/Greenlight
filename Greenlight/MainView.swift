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
    @EnvironmentObject var locationManager: LocationManager
    
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
                    
                    Text("Hello \(authManager.userName ?? "Guest")!")
                        .font(.custom("MonofontoRegular", size: 18))
                        .foregroundColor(Color("TextColor"))
                        .multilineTextAlignment(.center) // Center-align text
                        .padding(.bottom, 50)
                                        
                    if let address = locationManager.userAddress {
                        Text("You are currently located at \(address).")
                            .font(.custom("MonofontoRegular", size: 20))
                            .foregroundColor(Color("TextColor"))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                    } else if let error = locationManager.locationError {
                        Text("Location Error: \(error)")
                            .font(.custom("MonofontoRegular", size: 20))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                    } else {
                        Text("Fetching your address...")
                            .font(.custom("MonofontoRegular", size: 20))
                            .foregroundColor(Color("TextColor"))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                    }

                    Spacer()
                    
                    NavigationLink(destination: ChooseRouteView()) {
                        Text("Choose Bus Route")
                            .font(.custom("MonofontoRegular", size: 18))
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
                            .font(.custom("MonofontoRegular", size: 18))
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
        print("DEBUG: User logged out.") // Debugging Feedback
    }
}

#Preview {
    MainView()
}
