//
//  LocationService.swift
//  GeoJSON
//
//  Created by Johnnie Walker on 03.03.2024.
//

import CoreLocation
import Foundation

final class LocationService: NSObject {

    static let shared = LocationService()

    private let locationManager = CLLocationManager()
    private var completion: ((CLLocation) -> Void)?

    func getUserLocation(completion: @escaping ((CLLocation) -> Void)) {
        self.completion = completion
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        completion?(location)
        locationManager.stopUpdatingLocation()
    }
} 
