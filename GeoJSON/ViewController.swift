//
//  ViewController.swift
//  GeoJSON
//
//  Created by Johnnie Walker on 03.03.2024.
//

import Foundation
import MapKit
import UIKit

final class ViewController: UIViewController {

    // MARK: - UI components

    lazy var mapView: MKMapView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsUserLocation = true
        $0.delegate = self
        return $0
    }(MKMapView())

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupCameraPosition()
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let result = try await parseGeoJSON()
                mapView.addOverlays(result.overlays)
                mapView.addAnnotations(result.annotations)
            } catch {
                print("Error parsing GeoJSON: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Setup

    // geo.2
    func setupMapView() {
        view.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    // geo.3
    func setupCameraPosition() {
        let location = CLLocation(latitude: 0.5, longitude: 102.0)
        let radius: CLLocationDistance = 1_000_000
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

// MARK: - Private

private extension ViewController {
    
    func parseGeoJSON() async throws -> (overlays: [MKOverlay], annotations: [MKPointAnnotation]) {
        guard let url = Bundle.main.url(forResource: "geo", withExtension: "json") else {
            throw GeoJSONError.urlNotFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            return try decodeGeoJSON(data: data)
        } catch {
            throw GeoJSONError.parsingFailed(error)
        }
    }

    private func decodeGeoJSON(data: Data) throws -> ([MKOverlay], [MKPointAnnotation]) {
        let geoJSONs = try MKGeoJSONDecoder().decode(data)
        var overlays: [MKOverlay] = []
        var annotations: [MKPointAnnotation] = []
        
        for geoJSON in geoJSONs {
            processGeoJSON(geoJSON, overlays: &overlays, annotations: &annotations)
        }
        
        return (overlays, annotations)
    }

    private func processGeoJSON(_ geoJSON: MKGeoJSONObject, overlays: inout [MKOverlay], annotations: inout [MKPointAnnotation]) {
        if let feature = geoJSON as? MKGeoJSONFeature {
            for geo in feature.geometry {
                if let overlay = geo as? MKOverlay {
                    overlays.append(overlay)
                } else if let point = geo as? MKPointAnnotation {
                    point.title = "SUPER DUPER PLACE"
                    annotations.append(point)
                }
            }
        }
    }
}

// MARK: - MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polygon = overlay as? MKPolygon {
            return configureRenderer(for: polygon)
        } else if let polyline = overlay as? MKPolyline {
            return configureRenderer(for: polyline)
        } else if let multiPolygon = overlay as? MKMultiPolygon {
            return configureRenderer(for: multiPolygon)
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

// MARK: - Renderer

private extension ViewController {
    func configureRenderer(for polygon: MKPolygon) -> MKPolygonRenderer {
        let renderer = MKPolygonRenderer(polygon: polygon)
        renderer.fillColor = UIColor(hex: "#ff40ff", alpha: 0.3)
        renderer.strokeColor = UIColor(hex: "#ff40ff")
        renderer.strokeStart = 0.5
        renderer.lineWidth = 2.0
        return renderer
    }
    
    func configureRenderer(for polyline: MKPolyline) -> MKPolylineRenderer {
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor(hex: "#ff40ff")
        renderer.lineWidth = 20.0
        renderer.lineCap = .round
        return renderer
    }
    
    func configureRenderer(for multiPolygon: MKMultiPolygon) -> MKMultiPolygonRenderer {
        let renderer = MKMultiPolygonRenderer(multiPolygon: multiPolygon)
        renderer.fillColor = UIColor(hex: "#ff40ff", alpha: 0.3)
        renderer.strokeColor = UIColor(hex: "#ff40ff")
        renderer.lineWidth = 2.0
        return renderer
    }
}
