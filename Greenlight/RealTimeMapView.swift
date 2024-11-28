//
//  RealTimeMapView.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 27/11/24.
//

import SwiftUI

struct RealTimeMapView: View {
    var body: some View {
        ZStack {
            Color("PrimaryAccentColor").edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Real-Time Map")
                    .font(.largeTitle)
                    .foregroundColor(Color("TextColor"))
                    .padding()
                
                Spacer()
                
                // Placeholder for the map integration
                Text("Map will be displayed here.")
                    .foregroundColor(Color("TextColor"))
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .background(Color("TextColor").opacity(0.2))
                    .cornerRadius(10)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    RealTimeMapView()
}
