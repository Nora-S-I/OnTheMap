//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Norah Al Ibrahim on 1/12/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextFeild: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var selectedLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findLocation(_ sender: Any) {
        
        if urlTextFeild.text == "" {
            alert(title: "Notification", message: "Please enter a URL")
        } else {
            activityIndicator.startAnimating()
            //check if the entered location is valid
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(locationTextField.text!) { (placemarks: [CLPlacemark]?, error: Error?) in
                if error != nil {
                    
                    self.alert(title: "Location not found", message: "Could not find the entered location")
                    self.activityIndicator.stopAnimating()
                    return
                }
                guard let placemarks = placemarks else { return }
                
                if placemarks.count <= 0 {
                    self.alert(title: "Location not found", message: "Could not find the entered location")
                    self.activityIndicator.stopAnimating()
                    return
                }
                
                let placemark = placemarks[0]
                self.selectedLocation = (placemark.location?.coordinate)!
                self.activityIndicator.stopAnimating()
                self.performSegue(withIdentifier: "pinLocation", sender: self)
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pinLocation" {
            
            if let confirmViewController = segue.destination as? ConfirmLocationViewController {
                confirmViewController.selectedLocation = selectedLocation
                confirmViewController.selectedLocationTtile = locationTextField.text
                confirmViewController.studentURL = urlTextFeild.text
                
                
            }
        }
    }
}
