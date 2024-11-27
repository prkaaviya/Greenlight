//
//  ChooseRouteView.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 27/11/24.
//

import SwiftUI

struct ChooseRouteView: View {
    var body: some View {
        ZStack {
            Color("PrimaryAccentColor").edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Select a bus route.")
                    .font(.largeTitle)
                    .foregroundColor(Color("TextColor"))
                    .padding()
                
                Spacer()
                
                // Placeholder for the route selection UI
                Text("Route selection options will appear here.")
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
    ChooseRouteView()
}
