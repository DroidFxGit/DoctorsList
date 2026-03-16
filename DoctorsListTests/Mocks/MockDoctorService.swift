//
//  MockDoctorService.swift
//  DoctorsListTests
//
//  Created by Carlos Vazquez on 15/03/26.
//

import Foundation
@testable import DoctorsList

final class MockDoctorService: DoctorServiceProtocol {
    var mockDoctors: [Doctor] = []
    var mockError: NetworkError?
    var fetchDoctorsCallCount = 0
    var fetchDoctorDetailCallCount = 0
    var shouldThrowError = false
    
    /// Simulates network latency by adding a delay (in nanoseconds) before returning results.
    /// This is essential for testing loading state transitions, as without it the mock
    /// completes instantly and tests cannot observe intermediate loading states.
    var delay: UInt64 = 0
    
    func fetchDoctors() async throws -> [Doctor] {
        fetchDoctorsCallCount += 1
        
        if delay > 0 {
            try? await Task.sleep(nanoseconds: delay)
        }
        
        if shouldThrowError, let error = mockError {
            throw error
        }
        
        return mockDoctors
    }
    
    func fetchDoctorDetail(id: String) async throws -> Doctor {
        fetchDoctorDetailCallCount += 1
        
        if delay > 0 {
            try? await Task.sleep(nanoseconds: delay)
        }
        
        if shouldThrowError, let error = mockError {
            throw error
        }
        
        guard let doctor = mockDoctors.first(where: { $0.id == Int(id) }) else {
            throw NetworkError.unknown
        }
        
        return doctor
    }
    
    func reset() {
        mockDoctors = []
        mockError = nil
        fetchDoctorsCallCount = 0
        fetchDoctorDetailCallCount = 0
        shouldThrowError = false
        delay = 0
    }
}
