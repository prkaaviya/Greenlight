//
//  RoutePreference.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 07/11/24.
//

import Foundation

struct RoutePreference {
    
    // Save favorite route details (routeId and routeName) to UserDefaults
    static func saveFavoriteRoute(routeId: String, routeName: String) {
        UserDefaults.standard.set(routeId, forKey: "FavoriteRouteID")
        UserDefaults.standard.set(routeName, forKey: "FavoriteRouteName")
    }
    
    // Retrieve favorite route details from UserDefaults
    static func getFavoriteRoute() -> (routeId: String, routeName: String)? {
        guard let routeId = UserDefaults.standard.string(forKey: "FavoriteRouteID"),
              let routeName = UserDefaults.standard.string(forKey: "FavoriteRouteName") else {
            return nil
        }
        return (routeId, routeName)
    }
}
