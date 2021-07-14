//
//  FavoritesViewController.swift
//  20210712-Revathithangavelu-NYCSchools
//
//  Created by Revathi on 12/07/21.
//

//This viewcontroller  shows the list of schools liked by the user for later reference
//TODO: - #Implement search functionality

import UIKit
import CoreData

class FavoritesViewController: UIViewController {
    //MARK: -  instance variables and iboutlet declarations
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noItemsLabel: UILabel!
    
    var indexPathForSelectedSchool : IndexPath?
    var schools: [NSManagedObject] = [ ]
    
    //MARK: -  basic functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        noItemsLabel.backgroundColor = UIColor.white
        tableView.backgroundView = noItemsLabel
       
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
       
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = "Favorites"
        fetchFavoriteSchoolsFromDB()
    }
    
    func fetchFavoriteSchoolsFromDB() {
         guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
         }
         let managedContext = appDelegate.persistentContainer.viewContext
         let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: K.DBStore.entityName)
         do {
            schools = try managedContext.fetch(fetchRequest)
            if schools.count == 0 {
                noItemsLabel.text = "No favorite schools"
            }else {
                noItemsLabel.text = ""
            }
            tableView.reloadData()
         } catch let error as NSError {
            //TODO: - #Need to display some user friendly info
            print("Could not fetch. \(error), \(error.userInfo)")
         }
    }
    
    //MARK: - Navigationcontroller segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.favoriteSchoolDetailSegue {
            let showDetailsViewController = segue.destination as! FavoriteSchoolDetailViewController
            showDetailsViewController.school = schools[indexPathForSelectedSchool!.row]
           
        }
    }
}

//MARK: - TableViewDataSource methods

extension FavoritesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schools.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let school = schools[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! SchoolListTableViewCell
       cell.schoolNameLabel.text = school.value(forKeyPath: K.DBStore.schoolName) as? String
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}


//MARK: - TableView Delegate methods
extension FavoritesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        indexPathForSelectedSchool = indexPath
        self.performSegue(withIdentifier: K.favoriteSchoolDetailSegue, sender: self)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
