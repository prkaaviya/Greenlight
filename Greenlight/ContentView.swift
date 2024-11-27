//
//  ContentView.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 27/11/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                LoadingView()
                    .onAppear {
                        // Simulate loading delay and determine authentication state
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isLoading = false
                        }
                    }
            } else {
                if authManager.isAuthenticated {
                    MainView()
                } else {
                    NavigationView {
                        LoginView()
                    }
                }
            }
        }
    }
}
