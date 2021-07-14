//
//  SchoolListViewController.swift
//  20210712-Revathithangavelu-NYCSchools
//
//  Created by Revathi on 12/07/21.
//

import UIKit

class SchoolListViewController: UIViewController{
   
    @IBOutlet weak var tableView: UITableView!
    
    var nycSchoolsList = [School]()
    var filteredSchools = [School]()
    var schoolDataManager = SchoolDataManager()
    var indexPathForSelectedSchool : IndexPath?
    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        title = K.appName
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        schoolDataManager.delegate = self
        setupSearchController()
        loadSchoolList()
    }
    
    func setupSearchController(){
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search School"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    func loadSchoolList() {
        schoolDataManager.fetchNYCHighSchoolList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.showDetailsSegue {
            let showDetailsViewController = segue.destination as! SchoolDetailsViewController
            let school: School
            if isFiltering {
                school = filteredSchools[indexPathForSelectedSchool!.row]
            }else{
                school = nycSchoolsList[indexPathForSelectedSchool!.row]
            }
            showDetailsViewController.school = school
        }
    }
    
    func filterContentForSearchText(_ searchText: String){
      filteredSchools = nycSchoolsList.filter { (school: School) -> Bool in
        return school.schoolName.lowercased().contains(searchText.lowercased())
      }
      tableView.reloadData()
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
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
        cell.schoolNameLabel.text = school.schoolName
        cell.accessoryType = .disclosureIndicator
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


//func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//    print("did end scrolling")
//
//}

//MARK: - SchoolDataManager delegate methods

extension SchoolListViewController: SchoolDataManagerDelegate {
    func didUpdateSchoolList(schoolList: [School]) {
        DispatchQueue.main.async {
            self.nycSchoolsList.append(contentsOf: schoolList)
            self.tableView.reloadData()
        }
    }
    
    func didUpdateSchoolSATScoreDetails(school: School){
        
    }
    
    func didFailWithError(_ error: Error) {
        
    }
}

//MARK: - SearchController delegates

extension SchoolListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)

    }
}
