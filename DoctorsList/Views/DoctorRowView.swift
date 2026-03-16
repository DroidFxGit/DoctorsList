//
//  DoctorRowView.swift
//  DoctorsList
//
//  Created by Carlos Vazquez on 15/03/26.
//

import SwiftUI

struct DoctorRowView: View {
    let doctor: Doctor
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            doctorImage
            
            VStack(alignment: .leading, spacing: 6) {
                Text(doctor.fullName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(doctor.specialty)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text(doctor.locationString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: Constants.UI.smallPadding) {
                    if doctor.acceptingNewPatients {
                        Label("Accepting patients", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(Constants.UI.standardPadding)
        .background(Color(.systemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var doctorImage: some View {
        Circle()
            .fill(Color.blue.gradient)
            .frame(width: Constants.UI.imageSize, height: Constants.UI.imageSize)
            .overlay(
                Image(systemName: "stethoscope")
                    .foregroundStyle(.white)
                    .font(.title3)
            )
    }
}

#Preview {
    DoctorRowView(doctor: .preview)
        .padding()
}
