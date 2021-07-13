//
//  SchoolListViewController.swift
//  20210712-Revathithangavelu-NYCSchools
//
//  Created by Revathi on 12/07/21.
//

import UIKit

class SchoolListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var nycSchoolsList = [School]()
    var schoolDataManager = SchoolDataManager()
    var indexPathForSelectedSchool : IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        title = K.appName
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        schoolDataManager.delegate = self
        loadSchoolList()
    }
    

    func loadSchoolList() {
        schoolDataManager.fetchNYCHighSchoolList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.showDetailsSegue {
            let showDetailsViewController = segue.destination as! SchoolDetailsViewController
            showDetailsViewController.school = nycSchoolsList[indexPathForSelectedSchool!.row]
        }
    }
}

//MARK: - TableViewDataSource methods

extension SchoolListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nycSchoolsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let school = nycSchoolsList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! SchoolListTableViewCell
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


