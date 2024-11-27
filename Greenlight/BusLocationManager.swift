//
//  BusLocationManager.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 27/11/24.
//

import Foundation
import CoreLocation
import FirebaseDatabase

class BusLocationManager: ObservableObject {
    @Published var busLocations: [BusLocation] = []
    @Published var direction0Locations: [BusLocation] = []
    @Published var direction1Locations: [BusLocation] = []
    
    private var timer: Timer?
    private var ref: DatabaseReference!  // Firebase Database reference
    
    init() {
        let db = Database.database(url: "https://greenlight-ffaa2-default-rtdb.europe-west1.firebasedatabase.app/")
        ref = db.reference()
    }
    
    // Starts periodic updates for the specified route
    func startUpdatingBusLocations(for routeId: String, userLocation: CLLocation) {
        stopUpdatingBusLocations()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.fetchBusLocations(for: routeId, userLocation: userLocation)
        }
    }
    
    // Stops periodic updates
    func stopUpdatingBusLocations() {
        timer?.invalidate()
        timer = nil
    }
    
    // Fetch bus locations for the given route
    private func fetchBusLocations(for routeId: String, userLocation: CLLocation) {
        RouteService.shared.fetchBusLocations(for: routeId) { result in
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    switch result {
                    case .success(let locations):
                        self.processBusLocations(locations, for: routeId, userLocation: userLocation)
                    case .failure(let error):
                        print("ERROR: Failed to fetch bus locations: \(error)")
                    }
                }
            }
        }
    }
    
    // Process bus locations and enrich with static data
    private func processBusLocations(_ locations: [BusLocation], for routeId: String, userLocation: CLLocation) {
        // Fetch static data from SQLite
        let enrichedLocations = locations.compactMap { location -> BusLocation? in
            guard let stopDetails = SQLDatabaseManager.shared.getStop(by: location.stopId),
                  let tripDetails = SQLDatabaseManager.shared.getTrips(by: routeId).first(where: { $0.tripId == location.stopId }) else {
                print("ERROR: Missing static data for stopId \(location.stopId)")
                return nil
            }
            
            return BusLocation(
                id: location.id,
                stopId: location.stopId,
                stopName: stopDetails.name,
                arrivalDelay: location.arrivalDelay,
                departureDelay: location.departureDelay,
                directionId: tripDetails.directionId,
                vehicleId: location.vehicleId,
                timestamp: location.timestamp,
                latitude: location.latitude,
                longitude: location.longitude,
                destinationStopName: SQLDatabaseManager.shared.getStop(by: tripDetails.tripId)?.name ?? "Unknown"
            )
        }
        
        // Group by direction
        let sortedLocations = enrichedLocations.sorted {
            $0.directionId ?? 0 < $1.directionId ?? 0 ||
            $0.location.distance(from: userLocation) < $1.location.distance(from: userLocation)
        }
        self.direction0Locations = sortedLocations.filter { $0.directionId == 0 }
        self.direction1Locations = sortedLocations.filter { $0.directionId == 1 }
        self.busLocations = sortedLocations
        
        // Upload enriched data to Firebase
        uploadBusDataToFirebase(locations: sortedLocations)
    }
    
    // Upload bus locations to Firebase
    private func uploadBusDataToFirebase(locations: [BusLocation]) {
        for location in locations {
            let busData: [String: Any] = [
                "stopId": location.stopId,
                "stopName": location.stopName,
                "arrivalDelay": location.arrivalDelay ?? 0,
                "departureDelay": location.departureDelay ?? 0,
                "directionId": location.directionId ?? -1,
                "vehicleId": location.vehicleId ?? "Unknown",
                "timestamp": location.timestamp ?? 0,
                "latitude": location.latitude,
                "longitude": location.longitude
            ]
            
            // Upload each bus location to Firebase
            ref.child("busData").childByAutoId().setValue(busData) { error, _ in
                if let error = error {
                    print("ERROR: Failed to upload bus data: \(error.localizedDescription)")
                } else {
                    print("SUCCESS: Uploaded bus data for stop \(location.stopName)")
                }
            }
        }
    }
}
