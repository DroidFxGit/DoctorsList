//
//  DoctorsListViewModel.swift
//  DoctorsList
//
//  Created by Carlos Vazquez on 15/03/26.
//

import Foundation
import Combine

@MainActor
final class DoctorsListViewModel: ObservableObject {
    @Published private(set) var doctors: [Doctor] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: NetworkError?
    
    private let doctorService: DoctorServiceProtocol
    
    init(doctorService: DoctorServiceProtocol) {
        self.doctorService = doctorService
    }
    
    func loadDoctors() async {
        isLoading = true
        error = nil
        
        do {
            doctors = try await doctorService.fetchDoctors()
        } catch let networkError as NetworkError {
            self.error = networkError
        } catch {
            self.error = .unknown
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadDoctors()
    }
    
    func retry() async {
        await loadDoctors()
    }
    
    var hasError: Bool {
        error != nil
    }
    
    var isEmpty: Bool {
        !isLoading && doctors.isEmpty && !hasError
    }
}
