//
//  DoctorsListView.swift
//  DoctorsList
//
//  Created by Carlos Vazquez on 15/03/26.
//

import SwiftUI

struct DoctorsListView: View {
    @StateObject private var viewModel: DoctorsListViewModel
    
    init(viewModel: DoctorsListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.hasError, let error = viewModel.error {
                    ErrorView(error: error) {
                        await viewModel.retry()
                    }
                } else if viewModel.isEmpty {
                    EmptyStateView()
                } else {
                    doctorsList
                }
            }
            .navigationTitle("Doctors")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadDoctors()
            }
        }
    }
    
    private var doctorsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.doctors) { doctor in
                    NavigationLink(value: doctor) {
                        DoctorRowView(doctor: doctor)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(Constants.UI.standardPadding)
            .navigationDestination(for: Doctor.self) { doctor in
                DoctorDetailView(
                    viewModel: DoctorDetailViewModel(
                        doctor: doctor,
                        doctorService: DoctorService(
                            apiClient: APIClient(baseURL: Constants.API.baseURL)
                        ),
                        locationService: LocationService()
                    )
                )
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

#Preview {
    DoctorsListView(
        viewModel: DoctorsListViewModel(
            doctorService: DoctorService(
                apiClient: APIClient(baseURL: Constants.API.baseURL)
            )
        )
    )
}
