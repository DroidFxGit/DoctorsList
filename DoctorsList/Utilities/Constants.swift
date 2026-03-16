//
//  Constants.swift
//  DoctorsList
//
//  Created by Carlos Vazquez on 15/03/26.
//

import Foundation

enum Constants {
    enum API {
        static let baseURL = "https://mocki.io/v1"
        static let timeoutInterval: TimeInterval = 30
    }
    
    enum UI {
        static let cornerRadius: CGFloat = 12
        static let standardPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let imageSize: CGFloat = 60
        static let ratingStarSize: CGFloat = 16
    }
    
    enum Animation {
        static let standardDuration: Double = 0.3
        static let springResponse: Double = 0.5
        static let springDamping: Double = 0.7
    }
}
