//
//  GreenlightApp.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 17/10/24.
//

import SwiftUI
import Firebase

@main
struct GreenlightApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var locationManager = LocationManager()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(locationManager)
        }
    }
}
