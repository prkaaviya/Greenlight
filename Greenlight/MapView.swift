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
    
    // Keep track of the annotations
    @State private var addedAnnotations: [PointAnnotation] = []
    
    func makeUIView(context: Context) -> MapView {
        let resourceOptions = ResourceOptions(accessToken: "your-access-token-here")
        let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions, styleURI: .streets)
        
        let mapView = MapView(frame: .zero, mapInitOptions: mapInitOptions)
        
        mapView.location.options.puckType = .puck2D() // User location marker
        let cameraOptions = CameraOptions(center: coordinate, zoom: 14.0)
        mapView.mapboxMap.setCamera(to: cameraOptions)

        return mapView
    }
    
    func updateUIView(_ uiView: MapView, context: Context) {
        let cameraOptions = CameraOptions(center: coordinate, zoom: 14.0)
        uiView.mapboxMap.setCamera(to: cameraOptions)
    }
}
