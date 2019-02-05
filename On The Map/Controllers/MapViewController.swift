//
//  MapViewController.swift
//  On The Map
//
//  Created by Norah Al Ibrahim on 1/12/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        loadLocations()
    }
    
    @IBAction func refresh(_ sender: Any) {
        loadLocations()
    }
    
    @IBAction func add(_ sender: Any) {
        
        //check if the user has posted a location beofre and want to update their location
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
                self.updateMap()
            }
        }
    }
    
    func updateMap() {
        //create annotations on the map
        mapView.removeAnnotations(mapView.annotations)
        
        var annotations = [MKPointAnnotation]()
        
        for item in StudentInformations.data {
            let annotation = MKPointAnnotation()
            annotation.title = item.firstName + " " + item.lastName
            annotation.coordinate = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
            annotation.subtitle = item.mediaUrl
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
    
    func presentAddLocationView() {
        //present add location view controller
        let addLocationView = self.storyboard?.instantiateViewController(withIdentifier: StoryboardID.addLocation)
            as! AddLocationViewController
        self.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .fullScreen
        self.present(addLocationView, animated: true, completion: nil)
    }
}

extension MapViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "mkPin"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            view?.canShowCallout = true
            view?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            view?.annotation = annotation
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
      
        //open url when user tab on it
        guard let annotation = view.annotation, let subtitle = annotation.subtitle else {
            return
        }
        if var url = subtitle, subtitle != nil {
            
            let index = url.index(url.startIndex, offsetBy: 4)
            if (url[..<index]) != "http" {
                url = "http://\(url)"
            }
            guard let _url = URL(string: url) else {
                return
            }
            UIApplication.shared.open(_url, options: [:], completionHandler: nil)
        }
    }
}
