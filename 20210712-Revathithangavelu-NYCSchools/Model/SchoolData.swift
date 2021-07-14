//
//  SchoolData.swift
//  20210712-Revathithangavelu-NYCSchools
//
//  Created by Revathi on 12/07/21.
//

import Foundation

struct SchoolData: Codable {
    //TODO: remove unused fields
    let dbn, schoolName: String?
    let buildingCode, location, phoneNumber, faxNumber: String?
    let schoolEmail, website, subway: String?
    let bus, totalStudents: String?
    let latitude, longitude: String?
    let overview: String?
    
    enum CodingKeys: String, CodingKey {
        case schoolName = "school_name"
        case dbn
        case buildingCode = "building_code"
        case location
        case phoneNumber = "phone_number"
        case faxNumber = "fax_number"
        case schoolEmail = "school_email"
        case website, subway, bus
        case totalStudents = "total_students"
        case latitude, longitude
        case overview = "overview_paragraph"
    }
}





