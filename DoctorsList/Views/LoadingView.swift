//
//  LoadingView.swift
//  DoctorsList
//
//  Created by Carlos Vazquez on 15/03/26.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: Constants.UI.standardPadding) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingView()
}
