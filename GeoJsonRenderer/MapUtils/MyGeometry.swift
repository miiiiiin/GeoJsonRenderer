//
//  MyGeometry.swift
//  GeoJsonRenderer
//
//  Created by Running Raccoon on 2019/12/05.
//  Copyright © 2019 Running Raccoon. All rights reserved.
//

import Foundation
import GoogleMaps

class MyGeometry: GeoJSON {
    public var type: String!
    public var coordinates: [[[CLLocationCoordinate2D]]]!
    
    init(type: String, coordinates: [[[CLLocationCoordinate2D]]]) {
        self.type = type
        self.coordinates = coordinates
    }
    
    public var mpList: [Polygon]!
    
    //    init() {
    //        self.type = ""
    //        self.coordinates = coordinates
    //        self.mpList = mpList
    //    }
    
    public func toString() -> String {
        return "{type: \(type) :::: coordinates: \(coordinates) }"
    }
    
    public func isPoint() -> Bool {
        return self.type.isEqual("Point")
    }
    
    public func isMultiPoint() -> Bool {
        return self.type.isEqual("MultiPoint")
    }
    
    public func isLineString() -> Bool {
        return self.type.isEqual("LineString")
        
    }
    
    public func isPolygon() -> Bool {
        return self.type.isEqual("Polygon")
    }
    
    public func isMultiPolygon() -> Bool {
        return self.type.isEqual("MultiPolygon")
    }
    
    public func getCoordinates() -> [MapPoint] {
        
        var list: [MapPoint] = [];
        if (self.isPoint()) {
            var coordinates = self.coordinates as! [Double];
            var mapPoint = MapPoint(coordinates[1], coordinates[0])
            list.append(mapPoint);
            return list
        } else if (self.isLineString() || self.isMultiPolygon()) {
            for coordinates in self.coordinates as! [[Double]] {
                let mapPoint = MapPoint(coordinates[1], coordinates[0])
                list.append(mapPoint)
            }
            return list
        } else {
            return list
        }
    }
    
    public func getMultiPolygon() -> [Polygon] {
        if (self.mpList == nil) {
            self.mpList = [];
        }
        
        if (self.isMultiPolygon()) {
            let coordinates = self.coordinates as! [[[CLLocationCoordinate2D]]]
            
            for polygon in coordinates {
                let pg = Polygon(points: polygon)
                mpList.append(pg)
            }
        } else if (self.isPolygon()) {
            let coordinates = self.coordinates as! [[CLLocationCoordinate2D]]
            let pg = Polygon(points: coordinates)
            mpList.append(pg)
        } else {
            // Exception!!!!!
        }
        
        return self.mpList;
    }
}

