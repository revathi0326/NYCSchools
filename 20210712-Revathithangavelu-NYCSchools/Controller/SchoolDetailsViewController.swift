//
//  SchoolDetailsViewController.swift
//  20210712-Revathithangavelu-NYCSchools
//
//  Created by Revathi on 13/07/21.
//

import UIKit

class SchoolDetailsViewController: UIViewController {
    @IBOutlet weak var satScoreView: UIView!
    @IBOutlet weak var overviewView: UIView!
    @IBOutlet weak var contactsView: UIView!
    
    @IBOutlet weak var numberOfSATTestTakerslabel: UILabel!
    @IBOutlet weak var criticalReadingAvgScoreLabel: UILabel!
    @IBOutlet weak var mathAvgScoreLabel: UILabel!
    @IBOutlet weak var wriringAvgScoreLabel: UILabel!
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var overViewLabel: UILabel!
    
    var school: School?
    var schoolDataManager: SchoolDataManager = SchoolDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        satScoreView.layer.cornerRadius = 15
        overviewView.layer.cornerRadius = 15
        contactsView.layer.cornerRadius = 15
        
        
        schoolDataManager.delegate = self
        
        self.title = school?.schoolName
        
        showAvailbleSchoolDetails()
        loadSATScoreDetails()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.schoolDataManager.delegate = nil
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showAvailbleSchoolDetails(){
        overViewLabel.text = school?.overview
        phoneNumberLabel.text = school?.phoneNumber
        emailLabel.text = school?.email
    }
    
    func loadSATScoreDetails(){
        schoolDataManager.fetchSATScoreDetailsForSchool(school!)
    }
    
}


//MARK: - SchoolDataManager delegate methods

extension SchoolDetailsViewController: SchoolDataManagerDelegate {
    func didUpdateSchoolList(schoolList: [School]) {
        
    }
    
    func didUpdateSchoolSATScoreDetails(school: School){
        DispatchQueue.main.async {
            self.numberOfSATTestTakerslabel.text = "\(self.numberOfSATTestTakerslabel.text!)\(school.testTakersCount ?? "")"
            self.mathAvgScoreLabel.text = "\(self.mathAvgScoreLabel.text!)\(school.math_avg_score ?? "")"
            self.wriringAvgScoreLabel.text = "\(self.wriringAvgScoreLabel.text!)\(school.writing_avg_score ?? "")"
            self.criticalReadingAvgScoreLabel.text = "\(self.criticalReadingAvgScoreLabel.text!)\(school.reading_avg_score ?? "")"
        }
        
    }
    
    func didFailWithError(_ error: Error) {
        
    }
}
