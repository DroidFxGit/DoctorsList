//
//  DoctorService.swift
//  DoctorsList
//
//  Created by Carlos Vazquez on 15/03/26.
//

import Foundation

protocol DoctorServiceProtocol {
    func fetchDoctors() async throws -> [Doctor]
    func fetchDoctorDetail(id: String) async throws -> Doctor
}

final class DoctorService: DoctorServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func fetchDoctors() async throws -> [Doctor] {
        return try await apiClient.fetch(endpoint: .doctorsFeed)
    }
    
    func fetchDoctorDetail(id: String) async throws -> Doctor {
        let doctors: [Doctor] = try await apiClient.fetch(endpoint: .doctorsFeed)
        guard let doctor = doctors.first(where: { $0.id == Int(id) }) else {
            throw NetworkError.unknown
        }
        return doctor
    }
}
