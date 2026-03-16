//
//  MockAPIClient.swift
//  DoctorsListTests
//
//  Created by Carlos Vazquez on 15/03/26.
//

import Foundation
@testable import DoctorsList

final class MockAPIClient: APIClientProtocol {
    var mockData: Any?
    var mockError: NetworkError?
    var fetchCallCount = 0
    
    func fetch<T: Decodable>(endpoint: Endpoint) async throws -> T {
        fetchCallCount += 1
        
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData else {
            throw NetworkError.unknown
        }
        
        guard let typedData = data as? T else {
            throw NetworkError.decodingError(NSError(domain: "MockError", code: -1))
        }
        
        return typedData
    }
    
    func reset() {
        mockData = nil
        mockError = nil
        fetchCallCount = 0
    }
}

extension Doctor {
    static var mockDoctors: [Doctor] {
        [
            Doctor(
                id: 1,
                firstName: "Sarah",
                lastName: "Johnson",
                suffix: "MD",
                specialty: "Cardiology",
                npi: "1234567890",
                location: Location(city: "Houston", state: "TX"),
                salaryRange: "$480,000 - $620,000",
                acceptingNewPatients: true
            ),
            Doctor(
                id: 2,
                firstName: "Michael",
                lastName: "Chen",
                suffix: "DO",
                specialty: "Pediatrics",
                npi: "2345678901",
                location: Location(city: "Austin", state: "TX"),
                salaryRange: "$340,000 - $480,000",
                acceptingNewPatients: true
            ),
            Doctor(
                id: 3,
                firstName: "Emily",
                lastName: "Rodriguez",
                suffix: "MD",
                specialty: "Dermatology",
                npi: "3456789012",
                location: Location(city: "Dallas", state: "TX"),
                salaryRange: "$420,000 - $560,000",
                acceptingNewPatients: false
            )
        ]
    }
}
