//
//  LoadingView.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 17/10/24.
//

import SwiftUI

struct LoadingView: View {
    @State private var isActive = false
    
    var body: some View {
        VStack {
            if isActive {
                NavigationView {
                    LoginView()
                }
            } else {
                VStack {
                    Image("GreenLightLogo")
                        .resizable()
                        .frame(width: 400, height: 400)
                        .aspectRatio(contentMode: .fit)
                    
                    Text("Greenlight")
                        .font(.custom("Soulmeh", size: 40))
                        .foregroundColor(Color("PrimaryAccentColor"))
                }
                .padding()
                .background(Color("TextColor").edgesIgnoringSafeArea(.all))
                .onAppear {
                    // Simulate loading for 2 seconds, then transition
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            print("DEBUG: LOADING VIEW")
                            self.isActive = true
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color("TextColor").edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    LoadingView()
}
