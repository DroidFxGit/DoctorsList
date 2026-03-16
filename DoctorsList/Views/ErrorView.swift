//
//  ErrorView.swift
//  DoctorsList
//
//  Created by Carlos Vazquez on 15/03/26.
//

import SwiftUI

struct ErrorView: View {
    let error: NetworkError
    let retryAction: () async -> Void
    
    var body: some View {
        VStack(spacing: Constants.UI.standardPadding) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.red)
            
            Text("Something went wrong")
                .font(.title2)
                .fontWeight(.semibold)
            
            if let errorDescription = error.errorDescription {
                Text(errorDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.UI.standardPadding)
            }
            
            Button(action: {
                Task {
                    await retryAction()
                }
            }) {
                Label("Retry", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(Constants.UI.cornerRadius)
            }
            .padding(.top, Constants.UI.smallPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Constants.UI.standardPadding)
    }
}

#Preview {
    ErrorView(error: .networkError(URLError(.notConnectedToInternet))) {
        print("Retry tapped")
    }
}
