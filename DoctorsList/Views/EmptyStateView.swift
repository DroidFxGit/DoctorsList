//
//  EmptyStateView.swift
//  DoctorsList
//
//  Created by Carlos Vazquez on 15/03/26.
//

import SwiftUI

struct EmptyStateView: View {
    let message: String
    let systemImage: String
    
    init(
        message: String = "No doctors found",
        systemImage: String = "person.2.slash"
    ) {
        self.message = message
        self.systemImage = systemImage
    }
    
    var body: some View {
        VStack(spacing: Constants.UI.standardPadding) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text(message)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Constants.UI.standardPadding)
    }
}

#Preview {
    EmptyStateView()
}
