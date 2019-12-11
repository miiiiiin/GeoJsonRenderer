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
import ObjectMapper

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
        var features = [[String: AnyObject]]()
        
        if let path = Bundle.main.path(forResource: "GeoJSON_sample", ofType: "geojson") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                
                let object: AnyObject = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as AnyObject
                guard let dictionary = object as? [String: AnyObject] else { return }
                
                features = dictionary["features"] as! [[String: AnyObject]]
                
            } catch let error {
                print("parse error: \(error.localizedDescription)")
            }
        } else {
            print("Invalid filename/path.")
        }
      
        
        var geometries = [[String: AnyObject]]()
        
        for feature in features {
            geometries.append(feature["geometry"] as! [String : AnyObject])
            
        }
        
        geometries.forEach { geometry in
            let geojsonstring = geometry.jsonString()
            self.configureRoute(geojsonstring)
        }
        
        self.createOuterBounds(mapView: self.mapView, polygonPaths: self.polygonPaths)
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
                line.zIndex = 1
                line.strokeColor = UIColor.gray
                line.strokeWidth = 3
            }
            
//            for path in self.polygonPaths {
//                let option = GMSPolygon(path: path)
//                option.fillColor = UIColor.black.withAlphaComponent(0.6)
//                option.zIndex = 0
//                option.map = mapView
//                option.holes =
//            }
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
    
    func createOuterBounds(mapView: GMSMapView, polygonPaths: [GMSPath]) {
        let delta: Float = 0.01
        
        let outerBoundsPath = GMSMutablePath()
        outerBoundsPath.add(CLLocationCoordinate2D(latitude: CLLocationDegrees(-90 - delta), longitude: CLLocationDegrees(180+delta)))
        outerBoundsPath.add(CLLocationCoordinate2D(latitude: 0, longitude: CLLocationDegrees(180 + delta)))
        outerBoundsPath.add(CLLocationCoordinate2D(latitude: CLLocationDegrees(90 + delta), longitude: CLLocationDegrees(180 + delta)))
        outerBoundsPath.add(CLLocationCoordinate2D(latitude: CLLocationDegrees(90 + delta), longitude: 0))
        outerBoundsPath.add(CLLocationCoordinate2D(latitude: CLLocationDegrees(90 + delta), longitude: CLLocationDegrees(-180-delta)))
        outerBoundsPath.add(CLLocationCoordinate2D(latitude: 0, longitude: CLLocationDegrees(-180 + delta)))
        outerBoundsPath.add(CLLocationCoordinate2D(latitude: CLLocationDegrees(-90 - delta), longitude: CLLocationDegrees(-180 - delta)))
        outerBoundsPath.add(CLLocationCoordinate2D(latitude: CLLocationDegrees(-90 - delta), longitude: 0))
        outerBoundsPath.add(CLLocationCoordinate2D(latitude: CLLocationDegrees(-90 - delta), longitude: CLLocationDegrees(180 + delta)))
        
        let polygonOptions = GMSPolygon(path: outerBoundsPath)
        polygonOptions.fillColor = UIColor.black.withAlphaComponent(0.6)
        polygonOptions.zIndex = 0
        polygonOptions.map = mapView
        polygonOptions.holes = polygonPaths
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

extension Dictionary {
    
    func jsonString() -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [])
        guard jsonData != nil else {return nil}
        let jsonString = String(data: jsonData!, encoding: .utf8)
        guard jsonString != nil else {return nil}
        return jsonString! as String
    }
}
