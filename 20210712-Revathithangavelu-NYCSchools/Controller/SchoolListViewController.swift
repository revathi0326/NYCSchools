//
//  SchoolListViewController.swift
//  20210712-Revathithangavelu-NYCSchools
//
//  Created by Revathi on 12/07/21.
//

//TODO: - # enable paging for the table data instead of fetching entire school list

import UIKit
import MapKit
import Foundation

// This viewcontroller shows the list of NYC schools fetching from the server.

class SchoolListViewController: UIViewController{
    
    //MARK: -  instance variables and iboutlet declarations
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noItemsLabel: UILabel!
    
    var nycSchoolsList = [School]() // array containing list of schools
    var filteredSchools = [School]() // array used when searching schools
    var schoolDataManager = SchoolDataManager()
    var indexPathForSelectedSchool : IndexPath?
    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    //MARK: -  basic functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        title = K.appName
        noItemsLabel.backgroundColor = UIColor.white
        tableView.backgroundView = noItemsLabel
        
        // registering tableview cell
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        schoolDataManager.delegate = self
        setupSearchController()
        loadSchoolList()
    }
    
    func setupSearchController(){
        // configure the searchcontroller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = K.searchPlaceholder
        navigationItem.searchController = searchController
        searchController.searchBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
         definesPresentationContext = true
    }
    
    func loadSchoolList() {
        // fetching highschool list
        noItemsLabel.text = "Loading school list..."
        schoolDataManager.fetchNYCHighSchoolList()
    }
    
    //MARK: - Navigationcontroller segues
    
    // function which get called before the pushing the new view controller. we can pass in details necessary for the destioj view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.showDetailsSegue {
            let showDetailsViewController = segue.destination as! SchoolDetailsViewController
            let school: School
            // checking whether search is active n pick object from appropriate arrays
            if isFiltering {
                school = filteredSchools[indexPathForSelectedSchool!.row]
            }else{
                school = nycSchoolsList[indexPathForSelectedSchool!.row]
            }
            showDetailsViewController.school = school
        }
    }
    
    //MARK: - School Search related methods
    
    // function to filter the school list when the user searches the school in search bar
    
    func filterContentForSearchText(_ searchText: String){
        filteredSchools = nycSchoolsList.filter { (school: School) -> Bool in
            return school.schoolName!.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    // function to check whether search is active
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    @objc func openAddressInMapApp(_ sender: UIButton){
        var selectedSchool:School
        if isFiltering {
            selectedSchool = filteredSchools[sender.tag]
        }else{
            selectedSchool = nycSchoolsList[sender.tag]
        }
         
        if  let latitude = Double(selectedSchool.latitude!), let longitude = Double(selectedSchool.longitude!){
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = "\(selectedSchool.schoolName!)"
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }
       
    }
}

//MARK: - TableViewDataSource methods

extension SchoolListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredSchools.count
        }
        return nycSchoolsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var school: School
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! SchoolListTableViewCell
        if isFiltering {
            school = filteredSchools[indexPath.row]
        }else{
            school = nycSchoolsList[indexPath.row]
        }
        
//        let greeting = "Hi there! It's nice to meet you! 👋"
//        let endOfSentence = greeting.firstIndex(of: "!")!
//        let firstSentence = greeting[...endOfSentence]
        
        let address = school.address!
        let endOfSentence = address.firstIndex(of: "(")!
        let firstSentence = address[..<endOfSentence]
        
        cell.addressLabel.text = String(firstSentence)
        cell.addressButton.tag = indexPath.row
        cell.addressButton.addTarget(self, action: #selector(self.openAddressInMapApp(_:)), for: .touchUpInside)
        cell.schoolNameLabel.text = school.schoolName
        return cell
    }
}


//MARK: - TableView Delegate methods
extension SchoolListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        indexPathForSelectedSchool = indexPath
        self.performSegue(withIdentifier: "SchoolDetailSegue", sender: self)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}


//MARK: - SchoolDataManager delegate methods

extension SchoolListViewController: SchoolDataManagerDelegate {
    func didUpdateSchoolList(schoolList: [School]) {
        DispatchQueue.main.async {
            self.noItemsLabel.text = ""
            self.nycSchoolsList.append(contentsOf: schoolList)
            self.tableView.reloadData()
        }
    }
    
    func didUpdateSchoolSATScoreDetails(school: School){
        
    }
    
    func didFailWithError(_ error: Error) {
        DispatchQueue.main.async {
            self.noItemsLabel.text = error.localizedDescription
        }
    }
}

//MARK: - SearchController delegates

extension SchoolListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
        
    }
}
