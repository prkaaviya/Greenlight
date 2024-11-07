//
//  GreenlightApp.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 17/10/24.
//

import SwiftUI
import Firebase
import MapboxMaps

@main
struct GreenlightApp: App {
    
    // Initialize Firebase when the app starts
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
