//
//  ContentView.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 15/10/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            LoadingView()
        }
        .background(Color("TextColor").edgesIgnoringSafeArea(.all))
    }
}
    
#Preview {
    ContentView()
}
