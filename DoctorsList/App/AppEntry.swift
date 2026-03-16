//
//  AppEntry.swift
//  DoctorsList
//
//  Created by Carlos Vazquez on 15/03/26.
//

import SwiftUI

@main
struct DoctorsListApp: App {
    private let apiClient: APIClientProtocol
    private let doctorService: DoctorServiceProtocol
    
    init() {
        self.apiClient = APIClient(baseURL: Constants.API.baseURL)
        self.doctorService = DoctorService(apiClient: apiClient)
    }
    
    var body: some Scene {
        WindowGroup {
            DoctorsListView(
                viewModel: DoctorsListViewModel(doctorService: doctorService)
            )
        }
    }
}
