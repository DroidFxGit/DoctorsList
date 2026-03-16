//
//  MockLocationService.swift
//  DoctorsListTests
//
//  Created by Carlos Vazquez on 16/03/26.
//

import Foundation
import CoreLocation
@testable import DoctorsList

final class MockLocationService: LocationServiceProtocol {
    var mockCoordinate: CLLocationCoordinate2D?
    var mockError: Error?
    var geocodeCallCount = 0
    var shouldThrowError = false
    var delay: UInt64 = 0
    
    func geocodeAddress(city: String, state: String) async throws -> CLLocationCoordinate2D {
        geocodeCallCount += 1
        
        if delay > 0 {
            try? await Task.sleep(nanoseconds: delay)
        }
        
        if shouldThrowError, let error = mockError {
            throw error
        }
        
        guard let coordinate = mockCoordinate else {
            throw LocationError.noLocationFound
        }
        
        return coordinate
    }
    
    func reset() {
        mockCoordinate = nil
        mockError = nil
        geocodeCallCount = 0
        shouldThrowError = false
        delay = 0
    }
}
