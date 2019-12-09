//
//  MapViewController.swift
//  GeoJsonRenderer
//
//  Created by Running Raccoon on 2019/12/06.
//  Copyright © 2019 Running Raccoon. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var manager: CLLocationManager!
    var userLoc: CLLocationCoordinate2D!
    fileprivate var googleMapGroupServiceZoneOverlays: [GMSPolygon]?
    fileprivate var googleMapGroupServiceZoneVisibleBounds: GMSCoordinateBounds?
    var polygonPaths: [GMSPath] = []
    var polygon: GMSPolygon!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        let camera = GMSCameraPosition.camera(withLatitude: 37.36, longitude: -122.0, zoom: 6.0)
        mapView.camera = camera
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.initLocationManager()
        self.getPath()
    }
    
    
    private func getPath() {
        let path = Bundle.main.path(forResource: "GeoJSON_sample", ofType: "geojson")
        let geoJsonString = path
        
        print("jsonstring : \(path)")
        
        self.configureRoute(geoJsonString)
        
    }
    
    fileprivate func configureRoute(_ geoJSONString: String?) {
        self.googleMapGroupServiceZoneOverlays?.forEach({ overlay in
            overlay.map = nil
        })
        self.googleMapGroupServiceZoneOverlays = nil
        self.googleMapGroupServiceZoneVisibleBounds = nil
        
        guard let geoJSONString = geoJSONString, let polygons = GMSPolygon.polygons(geoJSONString), let mapView = self.mapView else {
            return
        }
        
        for polygon in polygons {
            self.polygon = polygon
            
            if let path = polygon.path {
                self.polygonPaths.append(path)
            }
            
            polygon.holes = self.polygonPaths
            
            for path in self.polygonPaths {
                let line = GMSPolyline(path: path)
                line.map = mapView
                line.zIndex = 0
                line.strokeColor = UIColor.gray
                line.strokeWidth = 3
            }
        }
        self.googleMapGroupServiceZoneOverlays = polygons
    }
    
    private func initLocationManager() {
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.startMonitoringSignificantLocationChanges()
        
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        } else {
            manager.requestWhenInUseAuthorization()
        }
    }
}

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
       
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation
        
        manager.stopUpdatingLocation()
        manager.delegate = nil
        
        self.userLoc = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        if let location = locations.last {
            print("new loc : \(location)")
            manager.stopUpdatingLocation()
        }
    }
}
