//
//  BusLocation.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 27/11/24.
//

import Foundation
import CoreLocation

struct BusLocation: Identifiable, Hashable {
    let id: String                // Unique identifier
    let stopId: String            // Stop ID where the bus is currently located
    let stopName: String          // Name of the stop
    let arrivalDelay: Int?        // Arrival delay in seconds (optional)
    let departureDelay: Int?      // Departure delay in seconds (optional)
    let directionId: Int?         // Direction of the bus (0 or 1, optional)
    let vehicleId: String?        // Vehicle identifier (optional)
    let timestamp: TimeInterval?  // Timestamp of the location update (optional)
    let latitude: Double          // Latitude of the bus's location
    let longitude: Double         // Longitude of the bus's location
    let destinationStopName: String // Final destination stop name for this direction

    // Location object for distance calculations
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // Conformance to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(stopId)
    }

    // Equatable conformance
    static func == (lhs: BusLocation, rhs: BusLocation) -> Bool {
        lhs.id == rhs.id && lhs.stopId == rhs.stopId
    }

    // Calculate the distance from a given user location
    func distance(from location: CLLocation) -> CLLocationDistance {
        self.location.distance(from: location) // Distance in meters
    }
}
