//
//  MapManager.swift
//  MyPlacesApp
//
//  Created by Антон Филиппов on 05.08.2022.
//

import UIKit
import MapKit

class MapManager {
    let locationManager = CLLocationManager()
    private let regionInMeters = 1000.0
    private var directionsArray: [MKDirections] = []
    private var placeCoordinate: CLLocationCoordinate2D?
    
    //Проверка доступности сегрвисов геолокации
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ())
    {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, incomeSegueIdentifier: segueIdentifier)
            closure()
        } else {
            presentAlertController(title: "Ooops", message: "It doen't work")
        }
    }
    
    //Проверка авторизации приложения для использования сервисов геолокации
    func checkLocationAuthorization(mapView: MKMapView, incomeSegueIdentifier: String) {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "showUser" { showUserLocation(mapView: mapView) }
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
    
    //Показать локацию пользователя
    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    //Строим маршрут от месторасположения пользователя до заведения
     func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        guard let location = locationManager.location?.coordinate else {
            presentAlertController(title: "Ooops", message: "Where are you?")
            return
        }
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        
        guard let request = createDirectionsRequest(from: location) else {
            presentAlertController(title: "Ooops", message: "Where to go?")
            return
        }
        let directions = MKDirections(request: request)
        resetMapView(mapView: mapView, withNew: directions)
        directions.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.presentAlertController(title: "Ooops", message: "Can we go?")
                return
            }
            for route in response.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                let travelInfo = "Расстояние до места: \(distance) км, время в пути: \(timeInterval) сек"
                print(travelInfo)
                
            }
        }
    }
    
    //Настройка запроса для построения маршрута
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    //Меняем отоброжаемую зоны области карты в соответствии с перемещением пользователя
    func startTrackinUserLocation(for mapView:MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        guard let location = location else {
            return
        }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        closure(center)
    }
    
    //Определение центра отображаемой области карты
    func getCenterLocation(for mV: MKMapView) -> CLLocation {
        let latitude = mV.centerCoordinate.latitude
        let longitude = mV.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    //Устанавливаем отметку с заведением на карте
    func setUpPlaceMark(place: Place, mapView: MKMapView) {
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
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
            
            
        }
        
    }
    
    // Сбор всех ранее построенных маршрутов перед построение нового
    private func resetMapView(mapView: MKMapView, withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map {
            $0.cancel()
        }
        directionsArray.removeAll()
    }
    
    //Алерт
    private func presentAlertController(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        let alertWindow = UIWindow(frame: UIScreen().bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?
            .present(alert, animated: true, completion: nil)
    }
    
    
}
