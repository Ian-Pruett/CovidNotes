//
//  NearbyTestingViewController.swift
//  CovidNotes
//
//  Created by Ian Pruett on 5/5/20.
//  Copyright © 2020 Ian Pruett. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class NearbyTestingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    var locationManager = CLLocationManager()
    var geoCoder = CLGeocoder()
    var testingCenters: [MKMapItem] = []
    
    
    func findTestingCenters() {
        testingCenters = []
        let req = MKLocalSearch.Request()
        req.naturalLanguageQuery = "COVID-19 Testing Site"
        if let userLocation = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            req.region = region
            let search = MKLocalSearch(request: req)
            search.start(completionHandler: searchHandler)
        }
    }
    
    func searchHandler(response: MKLocalSearch.Response?, error: Error?) {
        if let err = error {
            print("Error occured in search: \(err.localizedDescription)")
        } else if let res = response {
            print("\(res.mapItems.count) matches found")
            self.mapView.removeAnnotations(self.mapView.annotations)
            for item in res.mapItems {
                testingCenters.append(item)
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                self.mapView.addAnnotation(annotation)
            }
        }
        
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        initializeLocation()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        findTestingCenters()
    }
}

extension NearbyTestingViewController: CLLocationManagerDelegate {
    
    func initializeLocation() {
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            startLocation()
        case .denied, .restricted:
            print("location not authorized")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            print("error")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if ((status == .authorizedAlways)) || ((status == .authorizedWhenInUse)) {
            self.startLocation()
        } else {
            self.stopLocation()
        }
    }
    
    func startLocation() {
        // https://stackoverflow.com/questions/28600380/setting-corelocation-distance-filter
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func stopLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        findTestingCenters()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager error: \(error.localizedDescription)")
    }
}

// https://www.youtube.com/watch?v=FtO5QT2D_H8
extension NearbyTestingViewController: UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testingCenters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testingCenterCell", for: indexPath) as! TestingCenterViewCell
        
        // Configure the cell...
        let indexRow = indexPath.row
        let testingCenter = testingCenters[indexRow]
        cell.titleLabel.text = testingCenter.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexRow = indexPath.row
        let testingCenter = testingCenters[indexRow]
        mapView.setCenter(testingCenter.placemark.coordinate, animated: true)
        print(testingCenter.name!)
    }
}
