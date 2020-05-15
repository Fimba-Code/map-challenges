//
//  ViewController.swift
//  MapApp
//
//  Created by Marcos Vicente on 15.05.2020.
//  Copyright © 2020 Antares Software Group. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

//    MARK: -OUTLETS
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    
    @IBAction func goOnTouchUpInside(_ sender: Any) {
        getDirections()
        
        distanceLabel.text = String(format: "Distância: %.2f km", getDistance())
    }
    
//    MARK: -PROPERTIES
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    
//    MARK: - METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        goButton.layer.cornerRadius = goButton.bounds.width / 2
        checkLocationServices()
    }

    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
//            Avisar ao user que deve ativar isto
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("Unknown case")
        }
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getDirections() {
        guard let location  = locationManager.location?.coordinate else { return }
        
        let request = createDirectionsRequest(from: location)
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] (response, error) in
            guard let response = response else { return }
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate = getCenterLocation(for: mapView).coordinate
        let start = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: start)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .walking
        request.requestsAlternateRoutes = false
        
        return request
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func getDistance() -> Double {
        guard let location = locationManager.location?.coordinate else { return 0.0 }
        let start = location
        let end = getCenterLocation(for: mapView).coordinate
        
        let source = CLLocation(latitude: start.latitude, longitude: start.longitude)
        let destination = CLLocation(latitude: end.latitude, longitude: end.longitude)
        
        let distance = destination.distance(from: source)
        
        return distance / 1000.0
    }
}

//  MARK: -EXTENSIONS

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}


extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .red
        
        return renderer
    }
}

