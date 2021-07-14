//
//  Constants.swift
//  20210712-Revathithangavelu-NYCSchools
//
//  Created by Revathi on 12/07/21.
//

import Foundation

struct K {
    static let appName = "NYC Schools"
    static let cellIdentifier = "ReusableCell"
    static let cellNibName = "SchoolListTableViewCell"
    static let appToken = "TpXpMjh83hKelKE0SIPpFpTPr"
    static let showDetailsSegue = "SchoolDetailSegue"
    static let favoriteSchoolDetailSegue = "FavoriteSchoolDetailSegue"
    
    
    struct DBStore {
        static let entityName = "SchoolDetails"
        static let schoolName = "schoolName"
        static let schoolOverview = "overview"
        static let dbn = "dbn"
        static let phoneNumber = "phoneNumber"
        static let emailID = "email"
        static let website = "website"
        static let testTakersCount = "testTakersCount"
        static let reading_avg_score = "avgReadingScore"
        static let math_avg_score = "avgMathScore"
        static let writing_avg_score = "avgWritingScore"
        static let favorite = "favorite"
    }
    
    
}
