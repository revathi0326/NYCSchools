//
//  SchoolDataManager.swift
//  20210712-Revathithangavelu-NYCSchools
//
//  Created by Revathi on 12/07/21.
//

import UIKit

protocol SchoolDataManagerDelegate : NSObjectProtocol{
   
    func didUpdateSchoolList(schoolList: [School])
    func didFailWithError(_ error: Error)
    func didUpdateSchoolSATScoreDetails(school: School)
}


struct SchoolDataManager {
    let schoolListURL = "https://data.cityofnewyork.us/resource/s3k6-pzi2.json?$$app_token=\(K.appToken)"
    
    weak var delegate: SchoolDataManagerDelegate?
    
    
    func fetchNYCHighSchoolList()  {
        //performRequest(urlString: schoolListURL)
        fetchNYCHighSchoolListFrom(index: "0")
    }
    
    func fetchNYCHighSchoolListFrom(index offset:String)  {
//        let urlString = "\(schoolListURL)&$limit=20&$offset=\(offset)"
 //       let urlString = "\(schoolListURL)&$offset=\(offset)&$order=school_name ASC"
        let urlString = "\(schoolListURL)&$order=school_name ASC"
        let escapedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        performRequest(urlString: escapedURLString ??  "\(schoolListURL)&$offset=\(offset)")
    }
    
    func fetchSATScoreDetailsForSchool(_ school:School)  {
        let satScoreURLString = "https://data.cityofnewyork.us/resource/f9bf-2cp4.json?dbn=\(school.dbn)&$$app_token=\(K.appToken)"
        
       print("sat sscore url... \(satScoreURLString)")
        if let url = URL(string: satScoreURLString)  {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                
                if let actualData = data {
                    if let schoolWithSATDetails = self.parseJSONForSATScore(with: actualData, for: school){
                        self.delegate?.didUpdateSchoolSATScoreDetails(school: schoolWithSATDetails)
                    }
                }
            }
            task.resume()
        }
    }
    
    
    func performRequest(urlString : String)  {
        if let url = URL(string: urlString)  {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                
                if let actualData = data {
                    if let schoolListArray = self.parseJSON(with: actualData){
                        self.delegate?.didUpdateSchoolList(schoolList:schoolListArray)
                    }
                }
            }
            task.resume()
        }else {
            print("error forming url")
        }
    }
    
    
    func parseJSON(with data : Data) -> [School]?{
        let decoder = JSONDecoder()
        do {
           let decodedData = try decoder.decode([SchoolData].self, from: data)
            var schoolList:[School] = []
            var schoolIndex = 0
            
            for _ in decodedData {
//                let schoolName = decodedData[schoolIndex].school_name
//                let dbn = decodedData[schoolIndex].dbn
//                let overview = decodedData[schoolIndex].overview_paragraph
//                let phone = decodedData[schoolIndex].phone_number
                //let email = decodedData[schoolIndex].school_email
                
                let schoolName = decodedData[schoolIndex].schoolName ?? ""
                let dbn = decodedData[schoolIndex].dbn ?? ""
                let overview = decodedData[schoolIndex].overview ?? ""
                let phone = decodedData[schoolIndex].phoneNumber ?? ""
                let website = decodedData[schoolIndex].website ?? ""
                let email = decodedData[schoolIndex].schoolEmail ?? ""
                
                let school = School(schoolName: schoolName, overview: overview, dbn: dbn, phoneNumber: phone, email:email ,website: website, testTakersCount: "", reading_avg_score: "",math_avg_score: "",writing_avg_score: "")
                schoolList.append(school)
                schoolIndex+=1
            }
            return schoolList
        } catch  {
            print(error)
            return nil
        }
    }
    
    func parseJSONForSATScore(with data : Data, for school:School) -> School?{
        let decoder = JSONDecoder()
        do {
           let decodedData = try decoder.decode([SATScore].self, from: data)
                var schoolWithSATDetails = school
            
//                let schoolName = decodedData[0].school_name
//                let dbn = decodedData[0].dbn
//                let readingScore = decodedData[0].sat_critical_reading_avg_score
//                let mathScore = decodedData[0].sat_math_avg_score
//                let writingScore = decodedData[0].sat_writing_avg_score
//                let numberOfStudents = decodedData[0].num_of_sat_test_takers
                
                
//                let school = School(schoolName: schoolName, overview: "", dbn: dbn, testTakersCount: numberOfStudents, reading_avg_score: readingScore, math_avg_score: mathScore, writing_avg_score: writingScore)
            print("decoded data...\(decodedData)")
            
            if decodedData.count > 0 {
                schoolWithSATDetails.reading_avg_score = decodedData[0].sat_critical_reading_avg_score
                schoolWithSATDetails.math_avg_score = decodedData[0].sat_math_avg_score
                schoolWithSATDetails.writing_avg_score = decodedData[0].sat_writing_avg_score
                schoolWithSATDetails.testTakersCount = decodedData[0].num_of_sat_test_takers
                  
            }
        
            return schoolWithSATDetails
        } catch  {
            print(error)
            return nil
        }
    }

   
}

