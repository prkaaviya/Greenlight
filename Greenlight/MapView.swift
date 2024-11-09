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
        let cameraOptions = CameraOptions(center: coordinate, zoom: 14.0)
        uiView.mapboxMap.setCamera(to: cameraOptions)
    }
    
    private func updateBusAnnotations(mapView: MapView) {
        print("DEBUG in func updateBusAnnotations")
        // Ensure the annotation manager is available
        guard let manager = annotationManager else { return }
        
        // Clear existing annotations
        manager.annotations = []

        // Check if the custom image is already in the style, and add it if not
        if let image = UIImage(named: "bus_stop.png") {
            do {
                if !mapView.mapboxMap.style.imageExists(withId: "bus_stop_image") {
                    try mapView.mapboxMap.style.addImage(image, id: "bus_stop_image")
                }
            } catch {
                print("Failed to add bus stop image to style: \(error)")
            }
        }
        
        // Create new annotations based on bus locations
        let annotations = busLocations.map { location -> PointAnnotation in
            var lat : Double = 53.36001449
            var long : Double = -6.262791289
            var annotation = PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long))
            lat = lat + 0.5
            long = long + 0.5
            
            // Set the annotation image
            annotation.iconImage = "bus_stop_image"
            return annotation
        }
        
        // Update the annotation manager with the new annotations
        manager.annotations = annotations
    }
    
    // Observe changes to `busLocations` and trigger annotation update
    func updateAnnotationsIfNeeded() -> some View {
        self.onChange(of: busLocations) { _ in
            if let mapView = UIApplication.shared.windows.first?.rootViewController?.view.subviews.compactMap({ $0 as? MapView }).first {
                updateBusAnnotations(mapView: mapView)
            }
        }
    }
}
