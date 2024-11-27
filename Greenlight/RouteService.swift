//
//  RouteService.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 27/11/24.
//

import SQLite
import Foundation
import CoreLocation

class RouteService {
    static let shared = RouteService() // Singleton instance

    private let baseURL = "https://api.nationaltransport.ie/gtfsr/v2/gtfsr"
    private let apiKey = "f0fcf8c0531c4937a68a02023e01a3d3"

    private init() {}

    func getAvailableRoutes() -> [String] {
        var routes: [String] = ["46A", "39A", "C1", "C2", "145", "155"] // Supported routes
        return routes
    }
    
    // Function to get route ID by short name
    func getRouteId(for routeName: String) -> String? {
        guard let db = SQLDatabaseManager.shared.getDatabaseConnection() else {
            print("ERROR: Database connection not available.")
            return nil
        }
        let routesTable = Table("routes")
        let routeShortNameColumn = Expression<String>("route_short_name")
        let routeIdColumn = Expression<String>("route_id")

        do {
            if let row = try db.pluck(routesTable.filter(routeShortNameColumn == routeName)) {
                let routeId = row[routeIdColumn]
                print("DEBUG: Found Route ID \(routeId) for Route Name \(routeName)")
                return routeId
            } else {
                print("DEBUG: No Route ID found for Route Name \(routeName)")
            }
        } catch {
            print("ERROR: Failed to fetch route ID from database: \(error)")
        }

        return nil
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
}
