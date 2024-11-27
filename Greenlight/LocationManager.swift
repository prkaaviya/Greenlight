//
//  MapView.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 17/10/24.
//

import CoreLocation
import FirebaseDatabase

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    var ref: DatabaseReference!
    
    // Default coordinates for Dublin - 53.3498° N, 6.2603° W
    @Published var userLatitude: Double = 53.3498
    @Published var userLongitude: Double = 6.2603
    @Published var locationName: String = "Fetching location..."

    override init() {
        super.init()
        
        let db = Database.database(url: "https://greenlight-ffaa2-default-rtdb.europe-west1.firebasedatabase.app/")
        ref = db.reference()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // Update every 100 meters
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.userLatitude = location.coordinate.latitude
                self.userLongitude = location.coordinate.longitude
                
                // Optionally reverse geocode
                self.reverseGeocode(location: location)
            }
        }
    }

    // Reverse geocoding for location name
    private func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    self.locationName = placemark.locality ?? "Unknown"
                    print("In reverseGeocode \(self.locationName)")
                    
                    // Upload to Firebase only after we have the proper location name
                    self.uploadGPSDataToFirebase(latitude: self.userLatitude, longitude: self.userLongitude, locationName: self.locationName)
                }
            } else {
                print("Error in reverse geocoding: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    // Upload GPS data to Firebase
    func uploadGPSDataToFirebase(latitude: Double, longitude: Double, locationName: String) {
        print("In uploadGPSDataToFirebase \(locationName)")
        let gpsData: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude,
            "locationName": locationName,
            "timestamp": Date().timeIntervalSince1970
        ]
        ref.child("gpsData").childByAutoId().setValue(gpsData) { error, _ in
            if let error = error {
                print("Failed to upload GPS data: \(error.localizedDescription)")
            } else {
                print("GPS data uploaded successfully!")
            }
        }
    }

    // Called when there's an error with location services
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
