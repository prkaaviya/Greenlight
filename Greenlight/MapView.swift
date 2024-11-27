//
//  MapView.swift
//  Greenlight
//
//  Created by Kaaviya Ramkumar on 17/10/24.
//

import SwiftUI
import MapboxMaps

struct MapboxUIView: UIViewRepresentable {
    var coordinate: CLLocationCoordinate2D
    @Binding var busLocations: [BusLocation]

    // Keep track of the annotations
    @State private var annotationManager: PointAnnotationManager?

    func makeUIView(context: Context) -> MapView {
        let resourceOptions = ResourceOptions(accessToken: "sk.eyJ1IjoicHJrYWF2aXlhMTciLCJhIjoiY20zN294NWI1MGZ2eDJrcXdoOG43djJtZSJ9.BLMVAaUd4hQ_O8QE_tESGg")
        let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions, styleURI: .streets)
        
        let mapView = MapView(frame: .zero, mapInitOptions: mapInitOptions)
        mapView.location.options.puckType = .puck2D() // User location marker

        let cameraOptions = CameraOptions(center: coordinate, zoom: 14.0)
        mapView.mapboxMap.setCamera(to: cameraOptions)
        
        // Create the annotation manager for bus locations
        let manager = mapView.annotations.makePointAnnotationManager()
        self.annotationManager = manager

        return mapView
    }
    
    func updateUIView(_ uiView: MapView, context: Context) {
        // Update camera position
        let cameraOptions = CameraOptions(center: coordinate, zoom: 14.0)
        uiView.mapboxMap.setCamera(to: cameraOptions)
        
        do {

            // Add custom icon for bus stops
            if let busIcon = UIImage(named: "BusIcon")?.resize(to: CGSize(width: 30, height: 30)) {
                try uiView.mapboxMap.style.addImage(busIcon, id: "BusIcon")
            }
        } catch {
            print("Error adding style images: \(error.localizedDescription)")
        }

        // Create or use an existing PointAnnotationManager for annotations
        let annotationManager = uiView.annotations.makePointAnnotationManager()

        // Clear existing annotations
        annotationManager.annotations = []

        // Add user location annotation
        var userLocationAnnotation = PointAnnotation(coordinate: coordinate)
        userLocationAnnotation.textField = "You are here."
        userLocationAnnotation.textOffset = [0, 2]
        userLocationAnnotation.textColor = StyleColor(.black)
        userLocationAnnotation.iconImage = "PrimaryAccentColor"
        annotationManager.annotations.append(userLocationAnnotation)

        // Add bus stop annotations with direction-based color coding
        let busStopAnnotations = busLocations.map { location -> PointAnnotation in
            var annotation = PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
            annotation.textField = "\(location.stopName) (\(location.directionId ?? -1))"
            
            let directionColor: UIColor = location.directionId == 0 ? .red : .green
            annotation.textColor = StyleColor(directionColor)
            annotation.textOffset = [0, 2]
            annotation.iconImage = "BusIcon"
            return annotation
        }
        annotationManager.annotations.append(contentsOf: busStopAnnotations)
    }

}

extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
