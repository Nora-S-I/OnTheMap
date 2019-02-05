//
//  ConfirmLocationViewController.swift
//  On The Map
//
//  Created by Norah Al Ibrahim on 1/12/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit

class ConfirmLocationViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var finishButton: UIButton!
    
    var selectedLocation: CLLocationCoordinate2D!
    var selectedLocationTtile: String!
    var studentURL: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        //disply selected location
        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedLocation
        annotation.title = selectedLocationTtile
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        let distance = CLLocationDistance(4000.0)
        let region = MKCoordinateRegion(center: self.selectedLocation, latitudinalMeters: distance, longitudinalMeters: distance)
        mapView.setRegion(region, animated: true)
        
    }
    
    @IBAction func finish(_ sender: Any) {
        //post location information to the server
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let currentStudentInfo = appDelegate.currentStudentInformation {
            
            let info = StudentInformation(objectId: currentStudentInfo.objectId, uniqueKey: "\(appDelegate.accountKey!)", firstName: appDelegate.firstname, lastName: appDelegate.lastname, mapString: selectedLocationTtile!, mediaUrl: studentURL!, latitude: selectedLocation.latitude, longitude: selectedLocation.longitude)
            
            API.shared.updateLocation(info, { (error) in
                if let error = error {
                    DispatchQueue.main.async {
                        self.alert(title: "Error", message: error)
                        
                    }
                    return
                }
                self.dismiss(animated: true, completion: nil)
                
            })
        }
        else {
            let info = StudentInformation(objectId: "", uniqueKey: "\(appDelegate.accountKey!)", firstName: appDelegate.firstname, lastName: appDelegate.lastname, mapString: selectedLocationTtile!, mediaUrl: studentURL!, latitude: selectedLocation.latitude, longitude: selectedLocation.longitude)
            
            API.shared.submitLocation(info, { (error) in
                if let error = error {
                    DispatchQueue.main.async {
                        self.alert(title: "Error", message: error)
                    }
                    return
                }
                self.dismiss(animated: true, completion: nil)
                
            })
        }
    }
    
}
