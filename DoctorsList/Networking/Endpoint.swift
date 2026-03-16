//
//  Endpoint.swift
//  DoctorsList
//
//  Created by Carlos Vazquez on 15/03/26.
//

import Foundation

enum Endpoint {
    case doctorsFeed
    
    var path: String {
        switch self {
        case .doctorsFeed:
            return "/5bb09ab0-8d6d-4d85-8284-b6a467299353"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .doctorsFeed:
            return .get
        }
    }
    
    func url(baseURL: String) throws -> URL {
        guard let url = URL(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }
        return url
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
