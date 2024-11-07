//
//  RouteService.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 07/11/24.
//

import Foundation

class RouteService {
    static let shared = RouteService()  // Singleton instance
    
    private let baseURL = "https://api.nationaltransport.ie/gtfsr/v2/gtfsr"
    private let apiKey = "f0fcf8c0531c4937a68a02023e01a3d3"
    
    private init() {}
    
    func fetchRouteData(for route: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Construct the URL with format query parameter
        guard let url = URL(string: "\(baseURL)?format=json") else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Configure the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        
        // Create the data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected response code"])
                completion(.failure(statusError))
                return
            }
            
            guard let data = data else {
                let dataError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(dataError))
                return
            }
            
            // Success: Pass the data back via the completion handler
            completion(.success(data))
        }
        
        // Start the data task
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
