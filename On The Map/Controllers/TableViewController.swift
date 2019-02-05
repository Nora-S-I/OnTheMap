//
//  TableViewController.swift
//  On The Map
//
//  Created by Norah Al Ibrahim on 1/12/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    
    @IBOutlet var locationsTableView: UITableView!
    
    let locationsTableCellID = "locationCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocations()
        
    }
    
    @IBAction func add(_ sender: Any) {
        
        if (UIApplication.shared.delegate as! AppDelegate).currentStudentInformation != nil {
            let alertController = UIAlertController(title: "Overwrite?", message: "Overwrite your current posted location?",
                                                    preferredStyle: .alert)
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let actionOk = UIAlertAction(title: "OK", style: .destructive) { (action) in
                self.presentAddLocationView()
            }
            alertController.addAction(actionCancel)
            alertController.addAction(actionOk)
            
            present(alertController, animated: true, completion: nil)
        }
        else {
            self.presentAddLocationView()
        }
        
    }
    
    @IBAction func refresh(_ sender: Any) {
        loadLocations()
        locationsTableView.reloadData()
    }
    
    @IBAction func logout(_ sender: Any) {
        
        API.shared.logout { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.alert(title: "Error", message: error)
                    return
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    func loadLocations() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        API.shared.getLocations { (locations, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let error = error {
                DispatchQueue.main.async {
                    self.alert(title: "Error", message: error)
                }
                return
            }
            
            guard let locations = locations else { return }
            DispatchQueue.main.async {
                StudentInformations.data = locations
            }
        }
    }
    
    func presentAddLocationView() {
        let addLocationView = self.storyboard?.instantiateViewController(withIdentifier: StoryboardID.addLocation)
            as! AddLocationViewController
        self.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .fullScreen
        self.present(addLocationView, animated: true, completion: nil)
    }
}

extension TableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return StudentInformations.data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: locationsTableCellID)
        if let studentName = cell?.textLabel, let studentURL = cell?.detailTextLabel {
            studentName.text = StudentInformations.data[indexPath.row].firstName + " " +
                StudentInformations.data[indexPath.row].lastName
            studentURL.text = StudentInformations.data[indexPath.row].mediaUrl
            
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentInfo = StudentInformations.data[indexPath.row]
        guard let _url = URL(string: studentInfo.mediaUrl) else {
            alert(title: "Invalid URL", message: "URL is not invalid")
            return
        }
        UIApplication.shared.open(_url, options: [:], completionHandler: nil)
    }
}


