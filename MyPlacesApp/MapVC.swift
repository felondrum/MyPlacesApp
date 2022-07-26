//
//  MapVC.swift
//  MyPlacesApp
//
//  Created by Антон Филиппов on 26.07.2022.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var place: Place!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPlaceMark()
    }
    
    @IBAction func closeView() {
        dismiss(animated: true)
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
    
}
