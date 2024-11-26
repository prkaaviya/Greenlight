//
//  RouteService.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 07/11/24.
//

import Foundation
import CoreLocation

class RouteService {
    static let shared = RouteService()  // Singleton instance
    
    private let baseURL = "https://api.nationaltransport.ie/gtfsr/v2/gtfsr"
    private let apiKey = "f0fcf8c0531c4937a68a02023e01a3d3"
    
    private var stopData: [String: (name: String, latitude: Double, longitude: Double)] = [:]  // Store stop data with coordinates

    private init() {
        loadStopData()  // Load stop data on initialization
    }
    
    // Load stops.txt to get stop data including latitude and longitude
    private func loadStopData() {
        guard let filePath = Bundle.main.path(forResource: "stops", ofType: "txt") else {
            print("stops.txt file not found.")
            return
        }
        
        do {
            let content = try String(contentsOfFile: filePath)
            let lines = content.components(separatedBy: .newlines)
            
            for line in lines.dropFirst() {  // Skip the header line
                let fields = line.split(separator: ",", omittingEmptySubsequences: false)
                
                if fields.count >= 5 {
                    let stopId = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let stopName = fields[2].trimmingCharacters(in: .whitespacesAndNewlines)
                    let latitude = Double(fields[4].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
                    let longitude = Double(fields[5].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
                    
                    stopData[stopId] = (name: stopName, latitude: latitude, longitude: longitude)
                }
            }
            print("DEBUG - Loaded \(stopData.count) stops with coordinates.")
        } catch {
            print("Error reading stops.txt file: \(error)")
        }
    }

    func fetchBusLocations(for routeId: String, completion: @escaping (Result<[BusLocation], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)?format=json") else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                print("DEBUG - Raw data: \(String(data: data, encoding: .utf8) ?? "No data")")

                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let entities = jsonObject["entity"] as? [[String: Any]] {
                    
                    var index = 0
                    
                    let busLocations: [BusLocation] = entities.compactMap { (entity: [String: Any]) -> BusLocation? in
                        guard let tripUpdate = entity["trip_update"] as? [String: Any],
                              let trip = tripUpdate["trip"] as? [String: Any],
                              let entityRouteId = trip["route_id"] as? String, entityRouteId == routeId,
                              let stopTimeUpdates = tripUpdate["stop_time_update"] as? [[String: Any]] else {
                            return nil
                        }
                        
                        // Extract additional information
                        let directionId = trip["direction_id"] as? Int
                        let vehicle = tripUpdate["vehicle"] as? [String: Any]
                        let vehicleId = vehicle?["id"] as? String
                        let timestamp = tripUpdate["timestamp"] as? TimeInterval

                        for stopTimeUpdate in stopTimeUpdates {
                            if let stopId = stopTimeUpdate["stop_id"] as? String,
                               let stopInfo = self.stopData[stopId] {  // Retrieve stop info with coordinates
                                
                                let stopName = stopInfo.name
                                let latitude = stopInfo.latitude
                                let longitude = stopInfo.longitude
                                
                                let arrivalDelay = (stopTimeUpdate["arrival"] as? [String: Any])?["delay"] as? Int
                                let departureDelay = (stopTimeUpdate["departure"] as? [String: Any])?["delay"] as? Int
                                
                                let arrivalMinutes = (arrivalDelay ?? 0) / 60
                                let departureMinutes = (departureDelay ?? 0) / 60
                                let direction = directionId ?? -1
                                let vehicle = vehicleId ?? "Unknown"
                                let time = timestamp ?? 0
                                
                                print("DEBUG - Found stop: \(stopName) (ID: \(stopId)) for route: \(routeId) at index \(index), Arrival Delay: \(arrivalMinutes) minutes, Departure Delay: \(departureMinutes) minutes, Direction: \(direction), Vehicle: \(vehicle), Timestamp: \(time)")
                                
                                let busLocation = BusLocation(
                                    id: String(index),
                                    stopId: stopId,
                                    stopName: stopName,
                                    arrivalDelay: arrivalDelay,
                                    departureDelay: departureDelay,
                                    directionId: directionId,
                                    vehicleId: vehicleId,
                                    timestamp: timestamp,
                                    latitude: latitude,
                                    longitude: longitude
                                )
                                
                                index += 1
                                return busLocation
                            }
                        }
                        return nil  // Return nil if no stop_id is found in stop_time_update
                    }
                    
                    completion(.success(busLocations))
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"])))
                }
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }



    // Function to get route ID by short name
    func getRouteId(for routeName: String) -> String? {
        guard let filePath = Bundle.main.path(forResource: "routes", ofType: "txt") else {
            print("routes.txt file not found.")
            return nil
        }
        
        do {
            // Read file contents
            let content = try String(contentsOfFile: filePath)
            
            // Split content into lines
            let lines = content.components(separatedBy: .newlines)
            
            // Parse each line (assuming the first line is the header)
            for line in lines.dropFirst() {
                let fields = line.split(separator: ",", omittingEmptySubsequences: false)
                
                if fields.count >= 3 {
                    let routeShortName = fields[2].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Check if the route short name matches the given route name
                    if routeShortName == routeName {
                        return fields[0].trimmingCharacters(in: .whitespacesAndNewlines) // Return route_id
                    }
                }
            }
        } catch {
            print("Error reading routes.txt file: \(error)")
        }
        
        return nil // Return nil if no match found
    }
}
