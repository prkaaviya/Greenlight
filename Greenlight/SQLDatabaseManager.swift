//
//  SQLDatabaseManager.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 27/11/24.
//

import SQLite

class DatabaseManager {
    static let shared = DatabaseManager() // Singleton instance

    private var db: Connection!

    init() {
        // Load the database file from the app bundle
        do {
            if let dbPath = Bundle.main.path(forResource: "static_data", ofType: "db") {
                db = try Connection(dbPath)
                print("DEBUG: Database loaded successfully.")
            } else {
                print("ERROR: Database file not found.")
            }
        } catch {
            print("ERROR: Failed to connect to database: \(error)")
        }
    }

    // Fetch stops by stop ID
    func getStop(by stopId: String) -> (name: String, latitude: Double, longitude: Double)? {
        let stopsTable = Table("stops")
        let stopIdColumn = Expression<String>("stop_id")
        let stopNameColumn = Expression<String>("stop_name")
        let latitudeColumn = Expression<Double>("latitude")
        let longitudeColumn = Expression<Double>("longitude")

        do {
            if let stop = try db.pluck(stopsTable.filter(stopIdColumn == stopId)) {
                let name = stop[stopNameColumn]
                let latitude = stop[latitudeColumn]
                let longitude = stop[longitudeColumn]
                return (name, latitude, longitude)
            }
        } catch {
            print("ERROR: Failed to fetch stop: \(error)")
        }

        return nil
    }

    // Fetch trips by route ID
    func getTrips(by routeId: String) -> [(tripId: String, directionId: Int)] {
        var trips: [(tripId: String, directionId: Int)] = []
        let tripsTable = Table("trips")
        let tripIdColumn = Expression<String>("trip_id")
        let routeIdColumn = Expression<String>("route_id")
        let directionIdColumn = Expression<Int>("direction_id")

        do {
            for trip in try db.prepare(tripsTable.filter(routeIdColumn == routeId)) {
                let tripId = trip[tripIdColumn]
                let directionId = trip[directionIdColumn]
                trips.append((tripId, directionId))
            }
        } catch {
            print("ERROR: Failed to fetch trips: \(error)")
        }

        return trips
    }

    // Fetch stop times by trip ID
    func getStopTimes(by tripId: String) -> [(stopId: String, stopSequence: Int)] {
        var stopTimes: [(stopId: String, stopSequence: Int)] = []
        let stopTimesTable = Table("stop_times")
        let tripIdColumn = Expression<String>("trip_id")
        let stopIdColumn = Expression<String>("stop_id")
        let stopSequenceColumn = Expression<Int>("stop_sequence")

        do {
            for stopTime in try db.prepare(stopTimesTable.filter(tripIdColumn == tripId)) {
                let stopId = stopTime[stopIdColumn]
                let stopSequence = stopTime[stopSequenceColumn]
                stopTimes.append((stopId, stopSequence))
            }
        } catch {
            print("ERROR: Failed to fetch stop times: \(error)")
        }

        return stopTimes
    }
}
