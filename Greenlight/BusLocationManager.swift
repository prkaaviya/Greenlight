import Foundation
import MapboxMaps
import CoreLocation
import FirebaseDatabase

struct BusLocation: Equatable, Hashable {
    let id: String
    let stopId: String
    let stopName: String
    let arrivalDelay: Int?
    let departureDelay: Int?
    let directionId: Int?
    let vehicleId: String?
    let timestamp: TimeInterval?
    let latitude: Double
    let longitude: Double

    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // Conformance to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(stopId)
    }
    
    // Method to calculate distance from a given location
    func distance(from location: CLLocation) -> CLLocationDistance {
        return location.distance(from: self.location)
    }
}

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

    func startUpdatingBusLocations(for routeId: String, userLocation: CLLocation) {
        stopUpdatingBusLocations()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.fetchBusLocations(for: routeId, userLocation: userLocation)
        }
    }

    func stopUpdatingBusLocations() {
        timer?.invalidate()
        timer = nil
    }

    private func fetchBusLocations(for routeId: String, userLocation: CLLocation) {
        RouteService.shared.fetchBusLocations(for: routeId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let locations):
                    let uniqueLocations = Array(Set(locations))
                    let sortedLocations = uniqueLocations.sorted {
                        $0.directionId ?? 0 < $1.directionId ?? 0 ||
                        $0.location.distance(from: userLocation) < $1.location.distance(from: userLocation)
                    }
                    
                    self.direction0Locations = sortedLocations.filter { $0.directionId == 0 }
                    self.direction1Locations = sortedLocations.filter { $0.directionId == 1 }
                    self.busLocations = sortedLocations
                    
                    // Upload bus data to Firebase
                    self.uploadBusDataToFirebase(locations: sortedLocations)
                    
                case .failure(let error):
                    print("Failed to fetch bus locations: \(error)")
                }
            }
        }
    }
    
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
            
            // Upload each bus location to a unique document under "busData" collection
            ref.child("busData").childByAutoId().setValue(busData) { error, _ in
                if let error = error {
                    print("Error uploading bus data: \(error.localizedDescription)")
                } else {
                    print("Bus data uploaded successfully for stop: \(location.stopName)")
                }
            }
        }
    }
}
