//
//  MapViewController.swift
//  ICT352Project
//
//  Created by Donghyun kim on 12/8/19.
//  Copyright © 2019 Donghyun kim. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    let locationManager = CLLocationManager()
    let zoomedDistance: Double = 10000
    
    var previousLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationService()
    }
    
    func setupLocationManager (){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: zoomedDistance, longitudinalMeters: zoomedDistance)
            mapView.setRegion(region, animated: true)
        }
    }
        
        func checkLocationService() {
            if CLLocationManager.locationServicesEnabled() {
                setupLocationManager()
                checkLocationAuthorization()
            } else {
                //Later
            }
        }
        
        func checkLocationAuthorization() {
            switch CLLocationManager.authorizationStatus(){
            case .authorizedWhenInUse:
                // Todo: Map Status
                startRecordingLocation()
            case .denied:
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            case .restricted:
                break
            case .authorizedAlways:
                break
            @unknown default:
                fatalError()
        }
            
    }
    
    
    
    func startRecordingLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.stopUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation{
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func getDirection(){
        guard let location = locationManager.location?.coordinate else {
            
            return
        }
    }
    
    
    @IBAction func whenButtonTapped(_ sender: UIButton){
        getDirection()
    }
    
}
    
extension MapViewController: CLLocationManagerDelegate {
    
//    func locationManager (_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: zoomedDistance, longitudinalMeters: zoomedDistance)
//        mapView.setRegion(region, animated: true)
//    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
        }
    }

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else { return }
        
        guard center.distance(from: previousLocation) > 100 else { return }
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) {[weak self] (placeMarks, error) in
            guard let self = self else { return }
                
            if let _ = error {
                
                return
            
            }
            
            guard let placeMarks = placeMarks?.first else {
                return
            }
            
            let streetNumber = placeMarks.subThoroughfare ?? ""
            let streetName = placeMarks.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
        }
    }
}

