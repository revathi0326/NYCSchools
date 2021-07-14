//
//  FavoriteSchoolDetailViewController.swift
//  20210712-Revathithangavelu-NYCSchools
//
//  Created by Revathi on 13/07/21.
//
// This viewcontroller displays the detail of the selected school.

//TODO: - #need to figure out how school details viewcontroller can be reused instead of this viewcontroller

import UIKit
import CoreData

class FavoriteSchoolDetailViewController: UIViewController {
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
    
    var school: NSManagedObject?
    var schoolDataManager: SchoolDataManager = SchoolDataManager()
   // var isFavorite = true
    
    //MARK: -  basic functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        satScoreView.layer.cornerRadius = 15
        overviewView.layer.cornerRadius = 15
        contactsView.layer.cornerRadius = 15
        
        showSchoolDetails()
    }
    
    // this function retieves school data from the database and displays it
    func showSchoolDetails(){
        self.title = school!.value(forKeyPath: K.DBStore.schoolName) as? String
        overViewLabel.text = "\(overViewLabel.text!)\(school!.value(forKeyPath: K.DBStore.schoolOverview)as? String ?? "")"
        
        phoneNumberLabel.text = "\(phoneNumberLabel.text!)\(school!.value(forKeyPath: K.DBStore.phoneNumber) as? String ?? "")"
        emailLabel.text = "\(emailLabel.text!)\(school!.value(forKeyPath: K.DBStore.emailID) as? String ?? "")"
        numberOfSATTestTakerslabel.text = "\(emailLabel.text!)\(school!.value(forKeyPath: K.DBStore.testTakersCount) as? String ?? "")"
        mathAvgScoreLabel.text = "\(mathAvgScoreLabel.text!)\(school!.value(forKeyPath: K.DBStore.math_avg_score) as? String ?? "")"
        wriringAvgScoreLabel.text = "\(wriringAvgScoreLabel.text!)\(school!.value(forKeyPath: K.DBStore.writing_avg_score) as? String ?? "")"
        criticalReadingAvgScoreLabel.text = "\(criticalReadingAvgScoreLabel.text!)\(school!.value(forKeyPath: K.DBStore.reading_avg_score) as? String ?? "")"
        favoriteBarButton.image = UIImage(systemName: "star.fill")
    }
    
    // this function removes the school from favorite list
    @IBAction func removeFromFavorites(_ barButtonItem:UIBarButtonItem) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        favoriteBarButton.image = UIImage(systemName: "star")
        
        let schoolDBN = school!.value(forKeyPath: K.DBStore.dbn) as! String
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: K.DBStore.entityName)
        fetchRequest.predicate = NSPredicate(format: "\(K.DBStore.dbn) == %@", schoolDBN)
        do {
            var schoolToBeDeleted:[NSManagedObject] = []
            schoolToBeDeleted = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            managedContext.delete(schoolToBeDeleted[0])
            do {
                try managedContext.save()
                self.navigationController?.popToRootViewController(animated: true)
            } catch let error as NSError {
                //TODO: - #Need to display some user friendly info
                print("Could not delete. \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            //TODO: - #Need to display some user friendly info
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
}
