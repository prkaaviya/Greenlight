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
    private var tripsData: [String: (routeId: String, directionId: Int)] = [:]  // Maps trip_id to route_id and direction_id
    private var stopTimesData: [String: [(stopId: String, stopSequence: Int)]] = [:]  // Maps trip_id to list of stops

    private init() {
        loadStopData()
        loadTripsData()
        loadStopTimesData()
    }

    
    private func loadTripsData() {
        guard let filePath = Bundle.main.path(forResource: "trips", ofType: "txt") else {
            print("trips.txt file not found.")
            return
        }
        
        do {
            let content = try String(contentsOfFile: filePath)
            let lines = content.components(separatedBy: .newlines)
            
            for line in lines.dropFirst() {  // Skip the header line
                let fields = line.split(separator: ",", omittingEmptySubsequences: false)
                
                if fields.count >= 3 {
                    let tripId = fields[2].trimmingCharacters(in: .whitespacesAndNewlines)
                    let routeId = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let directionId = Int(fields[5].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
                    
                    tripsData[tripId] = (routeId: routeId, directionId: directionId)
                }
            }
            print("DEBUG - Loaded \(tripsData.count) trips.")
        } catch {
            print("Error reading trips.txt file: \(error)")
        }
    }

    private func loadStopTimesData() {
        guard let filePath = Bundle.main.path(forResource: "stop_times", ofType: "txt") else {
            print("stop_times.txt file not found.")
            return
        }
        
        do {
            let content = try String(contentsOfFile: filePath)
            let lines = content.components(separatedBy: .newlines)
            
            for line in lines.dropFirst() {  // Skip the header line
                let fields = line.split(separator: ",", omittingEmptySubsequences: false)
                
                if fields.count >= 4 {
                    let tripId = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let stopId = fields[3].trimmingCharacters(in: .whitespacesAndNewlines)
                    let stopSequence = Int(fields[4].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
                    
                    if stopTimesData[tripId] != nil {
                        stopTimesData[tripId]?.append((stopId: stopId, stopSequence: stopSequence))
                    } else {
                        stopTimesData[tripId] = [(stopId: stopId, stopSequence: stopSequence)]
                    }
                }
            }
            print("DEBUG - Loaded \(stopTimesData.count) stop times.")
        } catch {
            print("Error reading stop_times.txt file: \(error)")
        }
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
                } else {
                    print("DEBUG: Invalid line format in stops.txt: \(line)")
                }
            }
            print("DEBUG: Loaded \(stopData.count) stops with coordinates.")
        } catch {
            print("Error reading stops.txt file: \(error)")
        }
        if stopData.isEmpty {
            print("DEBUG: Warning - stopData is empty. Ensure stops.txt is correctly formatted and loaded.")
        }
    }
    
    func getLastStopName(for routeId: String, directionId: Int) -> String {
        // Find trips for the given routeId and directionId
        let tripsForRoute = tripsData.filter { $0.value.routeId == routeId && $0.value.directionId == directionId }
        
        // Find the trip with the highest stop sequence
        for (tripId, _) in tripsForRoute {
            if let stops = stopTimesData[tripId] {
                let lastStop = stops.max(by: { $0.stopSequence < $1.stopSequence })
                if let stopId = lastStop?.stopId, let stopInfo = stopData[stopId] {
                    return stopInfo.name
                }
            }
        }
        return "Unknown Destination"
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
                    
                    print("DEBUG: Found \(entities.count) entities")
                    var index = 0

                    let busLocations: [BusLocation] = entities.compactMap { (entity: [String: Any]) -> BusLocation? in
                        guard let tripUpdate = entity["trip_update"] as? [String: Any] else {
                            print("DEBUG: Skipping entity due to missing `trip_update`")
                            return nil
                        }

                        guard let trip = tripUpdate["trip"] as? [String: Any] else {
                            print("DEBUG: Skipping entity due to missing `trip` in `trip_update`")
                            return nil
                        }

                        guard let entityRouteId = trip["route_id"] as? String else {
                            print("DEBUG: Skipping entity due to missing `route_id` in `trip`")
                            return nil
                        }

                        if entityRouteId != routeId {
                            print("DEBUG: Skipping entity due to mismatched `route_id`: \(entityRouteId), expected: \(routeId)")
                            return nil
                        }

                        guard let stopTimeUpdates = tripUpdate["stop_time_update"] as? [[String: Any]], !stopTimeUpdates.isEmpty else {
                            print("DEBUG: Skipping entity due to missing or empty `stop_time_update`")
                            return nil
                        }

                        let directionId = trip["direction_id"] as? Int
                        let vehicle = tripUpdate["vehicle"] as? [String: Any]
                        let vehicleId = vehicle?["id"] as? String
                        let timestamp = tripUpdate["timestamp"] as? TimeInterval

                        for stopTimeUpdate in stopTimeUpdates {
                            guard let stopId = stopTimeUpdate["stop_id"] as? String else {
                                print("DEBUG: Skipping `stop_time_update` due to missing `stop_id`")
                                continue
                            }

                            guard let stopInfo = self.stopData[stopId] else {
                                print("DEBUG: `stop_id` \(stopId) not found in `stopData`")
                                continue
                            }

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
                            
                            let destinationStopName = self.getLastStopName(for: entityRouteId, directionId: directionId ?? -1)

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
                                longitude: longitude,
                                destinationStopName: destinationStopName
                            )

                            index += 1
                            return busLocation
                        }

                        return nil
                    }

                    print("DEBUG: Parsed \(busLocations.count) bus locations")
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
