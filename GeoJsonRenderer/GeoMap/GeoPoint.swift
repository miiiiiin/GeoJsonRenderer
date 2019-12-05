//
//  GeoPoint.swift
//  GeoJsonRenderer
//
//  Created by Running Raccoon on 2019/12/05.
//  Copyright © 2019 Running Raccoon. All rights reserved.
//

import Foundation
import CoreLocation
import ObjectMapper

open class CoordinateTransform: TransformType {
    public typealias Object = CLLocationCoordinate2D
    public typealias JSON = [CLLocationDegrees]
    
    open func transformFromJSON(_ value: Any?) -> CLLocationCoordinate2D? {
        guard let jsonValue = value as? JSON , jsonValue.count > 1 else {
            return nil
        }
        
        return CLLocationCoordinate2D(latitude: jsonValue[1], longitude: jsonValue[0])
    }
    
    open func transformToJSON(_ value: CLLocationCoordinate2D?) -> JSON? {
        guard let coordinate = value else {
            return nil
        }
        
        return [coordinate.longitude, coordinate.latitude]
    }
}


public struct GeoPoint: GeoJSON, Mappable {
    
    public var coordinate: CLLocationCoordinate2D!
    
    public init?(map: Map) {
        guard let type = map.JSON["type"] as? String , type == "Point" else {
            return nil
        }
        
        guard let _ = map.JSON["coordinates"] as? [CLLocationDegrees] else {
            return nil
        }
    }
    
    public init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    public mutating func mapping(map: Map) {
        coordinate <- (map["coordinates"], CoordinateTransform())
    }
}


public struct GeoMultiPoint: GeoJSON, Mappable {
    
    public var coordinates: [CLLocationCoordinate2D]!
    public var points: [GeoPoint] {
        get {
            return self.coordinates.map { return GeoPoint(coordinate: $0) }
        }
    }
    
    public init?(map: Map) {
        guard let type = map.JSON["type"] as? String , type == "MultiPoint" else {
            return nil
        }
        
        guard let _ = map.JSON["coordinates"] as? [[CLLocationDegrees]] else {
            return nil
        }
    }
    
    public mutating func mapping(map: Map) {
        coordinates <- (map["coordinates"], CoordinateArrayTransform())
    }
    
}

