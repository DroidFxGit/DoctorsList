//
//  DoctorDetailView.swift
//  DoctorsList
//
//  Created by Carlos Vazquez on 15/03/26.
//

import SwiftUI
import MapKit

struct DoctorDetailView: View {
    @StateObject private var viewModel: DoctorDetailViewModel
    
    init(viewModel: DoctorDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.hasError, let error = viewModel.error {
                ErrorView(error: error) {
                    await viewModel.retry()
                }
            } else if let doctor = viewModel.doctor {
                doctorDetailContent(doctor: doctor)
            }
        }
        .navigationTitle("Doctor Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadDoctorDetail()
            await viewModel.loadLocation()
        }
    }
    
    private func doctorDetailContent(doctor: Doctor) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection(doctor: doctor)
                
                Divider()
                
                infoSection(doctor: doctor)
                
                Divider()
                
                locationSection(doctor: doctor)
                
                Divider()
                
                salarySection(doctor: doctor)
            }
            .padding(Constants.UI.standardPadding)
        }
    }
    
    private func headerSection(doctor: Doctor) -> some View {
        VStack(spacing: 16) {
            Circle()
                .fill(Color.blue.gradient)
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "stethoscope")
                        .foregroundStyle(.white)
                        .font(.system(size: 40))
                )
            
            VStack(spacing: 4) {
                Text(doctor.fullName)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(doctor.specialty)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func infoSection(doctor: Doctor) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Information")
                .font(.headline)
            
            InfoRow(icon: "number", title: "NPI", value: doctor.npi)
            
            InfoRow(
                icon: doctor.acceptingNewPatients ? "checkmark.circle.fill" : "xmark.circle.fill",
                title: "New Patients",
                value: doctor.acceptingNewPatients ? "Accepting" : "Not accepting",
                valueColor: doctor.acceptingNewPatients ? .green : .red
            )
        }
    }
    
    private func locationSection(doctor: Doctor) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.headline)
            
            InfoRow(icon: "mappin.circle.fill", title: "Address", value: doctor.locationString)
            
            if let coordinate = viewModel.coordinate {
                Map(position: .constant(.region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                ))) {
                    Marker(doctor.fullName, systemImage: "cross.case.fill", coordinate: coordinate)
                        .tint(.blue)
                }
                .frame(height: 250)
                .cornerRadius(12)
                .disabled(true)
            } else if viewModel.isLoadingLocation {
                HStack {
                    ProgressView()
                        .padding(.trailing, 8)
                    Text("Loading map...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 250)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
    
    private func salarySection(doctor: Doctor) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Compensation")
                .font(.headline)
            
            InfoRow(icon: "dollarsign.circle.fill", title: "Salary Range", value: doctor.salaryRange)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.body)
                    .foregroundStyle(valueColor)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        DoctorDetailView(
            viewModel: DoctorDetailViewModel(
                doctor: .preview,
                doctorService: DoctorService(
                    apiClient: APIClient(baseURL: Constants.API.baseURL)
                ),
                locationService: LocationService()
            )
        )
    }
}
