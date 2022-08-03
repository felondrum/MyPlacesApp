//
//  MapVC.swift
//  MyPlacesApp
//
//  Created by Антон Филиппов on 26.07.2022.
//

import UIKit
import MapKit
import CoreLocation

protocol MapVCDelegate {
    func getAddress(_ address: String?)
}


class MapVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinConnect: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBAction func doneButtonPressed() {
        mapVCDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    var mapVCDelegate: MapVCDelegate?
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMeters = 10000.0
    var incomeSegueIdentifier = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = ""
        mapPinConnect.isHidden = true
        addressLabel.isHidden = true
        doneButton.isHidden = true
        mapView.delegate = self
        setUpMapView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkLocationServices()
        if incomeSegueIdentifier == "showUser" {
            mapPinConnect.isHidden = false
            addressLabel.isHidden = false
            doneButton.isHidden = false
        }
    }
    
    @IBAction func closeView() {
        dismiss(animated: true)
    }
    
    private func setUpMapView() {
        if incomeSegueIdentifier == "showMap" {
            setUpPlaceMark()
        }
    }
    
    private func setUpPlaceMark() {
        guard let location = place.location else { return }
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
            
            
        }
        
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setUpLocalitonManager()
            checkLocationAuthorization()
        } else {
            
        }
    }
    
    private func setUpLocalitonManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "showUser" { showUserLocation() }
            break
        case .denied:
            presentAlertController(title: "Ooops", message: "Let your phone to watch you!")
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            //Show allert controller
            break
        case .authorizedAlways:
            break
        @unknown default:
            print ("New case is avaliable")
        }
        
    }
    
    private func presentAlertController(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    

    @IBAction func centerViewInUserLocation() {
        showUserLocation()
    }
    
    private func getCenterLocation(for mV: MKMapView) -> CLLocation {
        let latitude = mV.centerCoordinate.latitude
        let longitude = mV.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
}


extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if (streetName != nil) {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
        
    }
}

extension MapVC: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
