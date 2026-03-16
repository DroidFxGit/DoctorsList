//
//  LocationService.swift
//  DoctorsList
//
//  Created by Carlos Vazquez on 16/03/26.
//

import Foundation
import CoreLocation

protocol LocationServiceProtocol {
    func geocodeAddress(city: String, state: String) async throws -> CLLocationCoordinate2D
}

final class LocationService: LocationServiceProtocol {
    private let geocoder: CLGeocoder
    
    init(geocoder: CLGeocoder = CLGeocoder()) {
        self.geocoder = geocoder
    }
    
    func geocodeAddress(city: String, state: String) async throws -> CLLocationCoordinate2D {
        let address = "\(city), \(state)"
        
        let placemarks = try await geocoder.geocodeAddressString(address)
        
        guard let location = placemarks.first?.location else {
            throw LocationError.noLocationFound
        }
        
        return location.coordinate
    }
}

enum LocationError: LocalizedError {
    case noLocationFound
    
    var errorDescription: String? {
        switch self {
        case .noLocationFound:
            return "Unable to find location coordinates"
        }
    }
}
