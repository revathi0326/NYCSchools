//
//  SchoolDetailsViewController.swift
//  20210712-Revathithangavelu-NYCSchools
//
//  Created by Revathi on 13/07/21.
//

//TODO: - 1.Providing functionality for phone and email text

// This viewcontroller displays the detail of the selected school
import UIKit
import CoreData

class SchoolDetailsViewController: UIViewController {
    //MARK: -  instance variables and iboutlet declarations
    
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
    @IBOutlet weak var favoriteBarButton: UIBarButtonItem!
    
    var school: School?
    var schoolDataManager: SchoolDataManager = SchoolDataManager()
    
    //MARK: -  basic functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // to create rounded corners
        satScoreView.layer.cornerRadius = 15
        overviewView.layer.cornerRadius = 15
        contactsView.layer.cornerRadius = 15
        
        schoolDataManager.delegate = self
        self.title = school?.schoolName
        
        showAvailbleSchoolDetails()
        loadSATScoreDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // checking whether school is removed from favorite list when switch tabs
        checkSchoolForFavorite()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.schoolDataManager.delegate = nil
    }
   
    // This function will show the available details about the school before fetching the SAT details of the school
    func showAvailbleSchoolDetails(){
        overViewLabel.text = school?.overview
        phoneNumberLabel.text = school?.phoneNumber
        emailLabel.text = school?.email
    }
    
    // This function will fetch the SAT score details for the particular school
    func loadSATScoreDetails(){
        let schoolSelected = school!
        schoolDataManager.fetchSATScoreDetailsForSchool(schoolSelected)
    }
    
    // This function will check whether the school is in user's favorite and display favorite button accordingly
    func checkSchoolForFavorite(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let schoolDBN = school!.dbn
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: K.DBStore.entityName)
        fetchRequest.predicate = NSPredicate(format: "\(K.DBStore.dbn) == %@", schoolDBN)
       
        do {
            // if school object return from the db it means it favorite school
            let schoolAvailable:[NSManagedObject] = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if schoolAvailable.count > 0 {
                favoriteBarButton.image = UIImage(systemName: "star.fill")
                school?.favorite = true
            }else{
                favoriteBarButton.image = UIImage(systemName: "star")
                school?.favorite = false
            }
        } catch let error as NSError {
            //TODO: - #Need to display some user friendly info
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // This function will be triggered when the favorite button in nav bar is tapped
    @IBAction func togglefavorites(_ barButtonItem:UIBarButtonItem) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if school?.favorite  == true{
            favoriteBarButton.image = UIImage(systemName: "star")
            school?.favorite = false
            
            let schoolDBN = school!.dbn
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: K.DBStore.entityName)
            fetchRequest.predicate = NSPredicate(format: "\(K.DBStore.dbn) == %@", schoolDBN)
            do {
                var schoolToBeDeleted:[NSManagedObject] = []
                schoolToBeDeleted = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
                managedContext.delete(schoolToBeDeleted[0])
                do {
                    try managedContext.save()
                    print("sucessfully deleted")
                } catch let error as NSError {
                    //TODO: - #Need to display some user friendly info
                    print("Could not delete. \(error), \(error.userInfo)")
                }
            } catch let error as NSError {
                //TODO: - #Need to display some user friendly info
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }else{
            favoriteBarButton.image = UIImage(systemName: "star.fill")
            school?.favorite = true
            // creating an nsmanagedobject and adding it to the db
            let entity = NSEntityDescription.entity(forEntityName: K.DBStore.entityName, in: managedContext)!
            let schoolToBeStored = NSManagedObject(entity: entity,
                                                   insertInto: managedContext)
            schoolToBeStored.setValue(school?.dbn, forKeyPath: K.DBStore.dbn)
            schoolToBeStored.setValue(school?.schoolName, forKeyPath: K.DBStore.schoolName)
            schoolToBeStored.setValue(school?.overview, forKeyPath: K.DBStore.schoolOverview)
            schoolToBeStored.setValue(school?.email, forKeyPath: K.DBStore.emailID)
            schoolToBeStored.setValue(school?.phoneNumber, forKeyPath: K.DBStore.phoneNumber)
            schoolToBeStored.setValue(school?.website, forKeyPath: K.DBStore.website)
            schoolToBeStored.setValue(school?.testTakersCount, forKeyPath: K.DBStore.testTakersCount)
            schoolToBeStored.setValue(school?.reading_avg_score, forKeyPath: K.DBStore.reading_avg_score)
            schoolToBeStored.setValue(school?.math_avg_score, forKeyPath: K.DBStore.math_avg_score)
            schoolToBeStored.setValue(school?.writing_avg_score, forKeyPath: K.DBStore.writing_avg_score)
            schoolToBeStored.setValue(school?.favorite, forKeyPath: K.DBStore.favorite)
            
            do {
                try managedContext.save()// this is where the data is actually saved in db
                print("sucessfully saved")
            } catch let error as NSError {
                //TODO: - #Need to display some user friendly info
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
}




//MARK: - SchoolDataManager delegate methods

extension SchoolDetailsViewController: SchoolDataManagerDelegate {
    func didUpdateSchoolList(schoolList: [School]) {
        //TODO: - #Modify the class to separate SAT score delegates and school list delegates
    }
    
    func didUpdateSchoolSATScoreDetails(school: School){
        DispatchQueue.main.async {
            // UI updates need to ahppen in main thread
            self.school = school
            self.numberOfSATTestTakerslabel.text = "\(self.numberOfSATTestTakerslabel.text!)\(school.testTakersCount ?? "")"
            self.mathAvgScoreLabel.text = "\(self.mathAvgScoreLabel.text!)\(school.math_avg_score ?? "")"
            self.wriringAvgScoreLabel.text = "\(self.wriringAvgScoreLabel.text!)\(school.writing_avg_score ?? "")"
            self.criticalReadingAvgScoreLabel.text = "\(self.criticalReadingAvgScoreLabel.text!)\(school.reading_avg_score ?? "")"
        }
    }
    
    func didFailWithError(_ error: Error) {
        
    }
}
