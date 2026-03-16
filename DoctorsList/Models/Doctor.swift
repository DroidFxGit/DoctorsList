//
//  Doctor.swift
//  DoctorsList
//
//  Created by Carlos Vazquez on 15/03/26.
//

import Foundation

struct Doctor: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let firstName: String
    let lastName: String
    let suffix: String
    let specialty: String
    let npi: String
    let location: Location
    let salaryRange: String
    let acceptingNewPatients: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case suffix
        case specialty
        case npi
        case location
        case salaryRange = "salary_range"
        case acceptingNewPatients = "accepting_new_patients"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName) ?? ""
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName) ?? ""
        suffix = try container.decodeIfPresent(String.self, forKey: .suffix) ?? ""
        specialty = try container.decodeIfPresent(String.self, forKey: .specialty) ?? ""
        npi = try container.decodeIfPresent(String.self, forKey: .npi) ?? ""
        location = try container.decodeIfPresent(Location.self, forKey: .location) ?? Location(city: "", state: "")
        salaryRange = try container.decodeIfPresent(String.self, forKey: .salaryRange) ?? ""
        acceptingNewPatients = try container.decodeIfPresent(Bool.self, forKey: .acceptingNewPatients) ?? false
    }
    
    init(
        id: Int,
        firstName: String,
        lastName: String,
        suffix: String,
        specialty: String,
        npi: String,
        location: Location,
        salaryRange: String,
        acceptingNewPatients: Bool
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.suffix = suffix
        self.specialty = specialty
        self.npi = npi
        self.location = location
        self.salaryRange = salaryRange
        self.acceptingNewPatients = acceptingNewPatients
    }
    
    var fullName: String {
        "\(firstName) \(lastName), \(suffix)"
    }
    
    var locationString: String {
        "\(location.city), \(location.state)"
    }
}

struct Location: Codable, Equatable, Hashable {
    let city: String
    let state: String
    
    init(city: String, state: String) {
        self.city = city
        self.state = state
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        city = try container.decodeIfPresent(String.self, forKey: .city) ?? ""
        state = try container.decodeIfPresent(String.self, forKey: .state) ?? ""
    }
}

extension Doctor {
    static var preview: Doctor {
        Doctor(
            id: 1,
            firstName: "Sarah",
            lastName: "Johnson",
            suffix: "MD",
            specialty: "Cardiology",
            npi: "1234567890",
            location: Location(city: "Houston", state: "TX"),
            salaryRange: "$480,000 - $620,000",
            acceptingNewPatients: true
        )
    }
}
