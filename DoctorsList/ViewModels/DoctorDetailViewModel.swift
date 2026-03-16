//
//  DoctorDetailViewModel.swift
//  DoctorsList
//
//  Created by Carlos Vazquez on 15/03/26.
//

import Foundation
import Combine
import CoreLocation

@MainActor
final class DoctorDetailViewModel: ObservableObject {
    @Published private(set) var doctor: Doctor?
    @Published private(set) var isLoading = false
    @Published private(set) var error: NetworkError?
    @Published private(set) var coordinate: CLLocationCoordinate2D?
    @Published private(set) var isLoadingLocation = false
    
    private let doctorService: DoctorServiceProtocol
    private let locationService: LocationServiceProtocol
    private let doctorId: Int
    
    init(doctorId: Int, doctorService: DoctorServiceProtocol, locationService: LocationServiceProtocol) {
        self.doctorId = doctorId
        self.doctorService = doctorService
        self.locationService = locationService
    }
    
    init(doctor: Doctor, doctorService: DoctorServiceProtocol, locationService: LocationServiceProtocol) {
        self.doctor = doctor
        self.doctorId = doctor.id
        self.doctorService = doctorService
        self.locationService = locationService
    }
    
    func loadDoctorDetail() async {
        guard doctor == nil else { return }
        
        isLoading = true
        self.error = nil
        
        do {
            doctor = try await doctorService.fetchDoctorDetail(id: String(doctorId))
        } catch let networkError as NetworkError {
            self.error = networkError
        } catch {
            self.error = .unknown
        }
        
        isLoading = false
    }
    
    func retry() async {
        await loadDoctorDetail()
    }
    
    func loadLocation() async {
        guard let doctor = doctor else { return }
        
        isLoadingLocation = true
        
        do {
            coordinate = try await locationService.geocodeAddress(
                city: doctor.location.city,
                state: doctor.location.state
            )
        } catch {
            print("Geocoding failed: \(error.localizedDescription)")
            coordinate = nil
        }
        
        isLoadingLocation = false
    }
    
    var hasError: Bool {
        error != nil
    }
}
