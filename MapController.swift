//
//  MapController.swift
//  PennLabsInterview
//
//  Created by Josh Doman on 2/10/17.
//  Copyright © 2017 Josh Doman. All rights reserved.
//

import UIKit
import MapKit

class MapController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate {
    
    let locationManager = CLLocationManager()
    
    var searchHistory = [String]()
    
    var places: [Place]? {
        didSet {
            if let places = places {
                for place in places {
                    let pin = MKPointAnnotation()
                    pin.coordinate = place.location
                    pin.title = place.name
                    mapView.addAnnotation(pin)
                }
            }
        }
    }
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        mapView.delegate = self
        return mapView
    }()
    
    let tableIdentifier = "tableCell"
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()
    
    var searchController: UISearchController!
    
    let identifier = "identifier"
    
    var tableHeightAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        
        self.navigationItem.titleView = searchController.searchBar
        
        self.definesPresentationContext = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        view.addSubview(mapView)
        
        _ = mapView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: tableIdentifier)
        
        view.addSubview(tableView)
        
        tableHeightAnchor = tableView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 70, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 100)[3]
        tableHeightAnchor?.constant = 0
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let text = searchBar.text, searchBar.text != "" {
            search(text: text)
            searchHistory.append(text)
            tableHeightAnchor?.constant = 0
            animate()
        }
        
    }
    
    func search(text: String) {
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
        NetworkManager.getRequest(term: text, callbackString: { _ in }, callback: { (data) in
            
            DispatchQueue.main.async {
                self.places = NetworkManager.getAllLocations(json: data as! [String : AnyObject])
                self.tableView.reloadData()
            }
            
        })
        
        searchController.isActive = false
        
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchController.isActive = true
        animate()
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableHeightAnchor?.constant = 100
        searchController.isActive = true
        animate()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableHeightAnchor?.constant = 0
        animate()
    }
    
    func animate() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.2, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
}

extension MapController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let startLocation = CLLocationCoordinate2DMake(39.9529, -75.197098)
            
        //if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: startLocation, span: span)
            mapView.setRegion(region, animated: true)
        //}
        
    }
}


//http://stackoverflow.com/questions/33978455/swift-how-do-i-make-a-pin-annotation-callout-full-steps-please

extension MapController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .infoLight)
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
}

extension MapController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = searchHistory[indexPath.row]
        search(text: name)
    }
}

extension MapController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableIdentifier, for: indexPath)
        cell.textLabel?.text = searchHistory[indexPath.row]
        return cell
    }
}
