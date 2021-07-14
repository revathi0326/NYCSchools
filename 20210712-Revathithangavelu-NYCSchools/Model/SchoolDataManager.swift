//
//  SchoolDataManager.swift
//  20210712-Revathithangavelu-NYCSchools
//
//  Created by Revathi on 12/07/21.
//

// This class handles all the network request and calls appropriate delegates to take action
//TODO: - #Handle paging for best user experience #App token should never be stored in the code base #Nice to have authentication feature


import UIKit

// Protocols to delagate the handling of fetched school data
protocol SchoolDataManagerDelegate : NSObjectProtocol{
    func didUpdateSchoolList(schoolList: [School])
    func didFailWithError(_ error: Error)
    func didUpdateSchoolSATScoreDetails(school: School)
}

struct SchoolDataManager {
    let schoolListURL = "https://data.cityofnewyork.us/resource/s3k6-pzi2.json?$$app_token=\(K.appToken)"
    
    weak var delegate: SchoolDataManagerDelegate?
    
    func fetchNYCHighSchoolList()  {
        fetchNYCHighSchoolListFrom(index: "0")
    }
    
    // function fetching the school list details
    
    func fetchNYCHighSchoolListFrom(index offset:String)  {
        //        let urlString = "\(schoolListURL)&$limit=20&$offset=\(offset)" // query for paging
        //       let urlString = "\(schoolListURL)&$offset=\(offset)&$order=school_name ASC"
        let urlString = "\(schoolListURL)&$order=school_name ASC" // return results sorted by school name
        let escapedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        performRequest(urlString: escapedURLString ??  "\(schoolListURL)&$offset=\(offset)")
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
            //TODO: - #Need to display some user friendly info
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
                let schoolName = decodedData[schoolIndex].schoolName ?? ""
                let dbn = decodedData[schoolIndex].dbn ?? ""
                let overview = decodedData[schoolIndex].overview ?? ""
                let phone = decodedData[schoolIndex].phoneNumber ?? ""
                let website = decodedData[schoolIndex].website ?? ""
                let email = decodedData[schoolIndex].schoolEmail ?? ""
                let latitude = decodedData[schoolIndex].latitude ?? ""
                let longitude = decodedData[schoolIndex].longitude ?? ""
                let address = decodedData[schoolIndex].location ?? ""
                
                let school = School(schoolName: schoolName, overview: overview, dbn: dbn, phoneNumber: phone, email:email ,website: website, address: address, latitude: latitude,longitude: longitude,testTakersCount: "",reading_avg_score: latitude,math_avg_score:longitude,writing_avg_score: address)
                schoolList.append(school)
                schoolIndex+=1
            }
            return schoolList
        } catch  {
            self.delegate?.didFailWithError(error)
            print(error)
            return nil
        }
    }
    
    // function fetching the SAT score details for a particular school
    
    func fetchSATScoreDetailsForSchool(_ school:School)  {
        let satScoreURLString = "https://data.cityofnewyork.us/resource/f9bf-2cp4.json?dbn=\(school.dbn)&$$app_token=\(K.appToken)"
        
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
    
    func parseJSONForSATScore(with data : Data, for school:School) -> School?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([SATScore].self, from: data)
            var schoolWithSATDetails = school
            
            print("decoded data...\(decodedData)")
            
            if decodedData.count > 0 {
                schoolWithSATDetails.reading_avg_score = decodedData[0].sat_critical_reading_avg_score
                schoolWithSATDetails.math_avg_score = decodedData[0].sat_math_avg_score
                schoolWithSATDetails.writing_avg_score = decodedData[0].sat_writing_avg_score
                schoolWithSATDetails.testTakersCount = decodedData[0].num_of_sat_test_takers
                
            }
            return schoolWithSATDetails
        } catch  {
            self.delegate?.didFailWithError(error)
            print(error)
            return nil
        }
    }
}

