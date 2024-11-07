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
                // Navigate to GPS screen after the loading
                GPSView()
            } else {
                VStack {
                    Image("GreenLightLogo")
                        .resizable()
                        .frame(width: 400, height: 400)
                        .aspectRatio(contentMode: .fit)
                    
                    Text("Greenlight")
                        .font(.custom("Soulmeh", size: 40))
                        .foregroundColor(Color("PrimaryAccentColor"))

                    Color("TextColor")
                        .edgesIgnoringSafeArea(.all)
                }
                .onAppear {
                    // Simulate loading for 3 seconds, then transition
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
        .padding()
    }
}
