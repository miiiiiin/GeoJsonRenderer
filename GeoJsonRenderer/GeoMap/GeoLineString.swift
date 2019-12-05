//
//  GeoLineString.swift
//  GeoJsonRenderer
//
//  Created by Running Raccoon on 2019/12/05.
//  Copyright © 2019 Running Raccoon. All rights reserved.
//

import Foundation
import CoreLocation
import ObjectMapper

open class CoordinateArrayTransform: TransformType {
    public typealias Object = [CLLocationCoordinate2D]
    public typealias JSON = [[CLLocationDegrees]]
    
    open func transformFromJSON(_ value: Any?) -> Object? {
        guard let jsonValue = value as? JSON else {
            return []
        }
        
        var coordinates = [CLLocationCoordinate2D]()
        for value in jsonValue {
            guard value.count > 1 else {
                continue
            }
            
            let coordinate = CLLocationCoordinate2D(latitude: value[1], longitude: value[0])
            coordinates.append(coordinate)
        }
        
        return coordinates
    }
    
    open func transformToJSON(_ value: Object?) -> JSON? {
        guard let coordinates = value else {
            return []
        }
        
        var jsonValue = [[CLLocationDegrees]]()
        for coordinate in coordinates {
            let value = [coordinate.latitude, coordinate.longitude]
            jsonValue.append(value)
        }
        
        return jsonValue
    }
}

public struct GeoLineString: GeoJSON, Mappable {
    
    public var coordinates: [CLLocationCoordinate2D]!
    
    public init(coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates
    }
    
    public init?(map: Map) {
        guard let type = map.JSON["type"] as? String , type == "LineString" else {
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

public struct GeoMultiLineString: GeoJSON, Mappable {
    
    public var coordinates: [[CLLocationCoordinate2D]]!
    public var lineStrings: [GeoLineString] {
        get {
            return self.coordinates.map { return GeoLineString(coordinates: $0) }
        }
    }
    
    public init?(map: Map) {
        guard let type = map.JSON["type"] as? String , type == "MultiLineString" else {
            return nil
        }
        
        guard let _ = map.JSON["coordinates"] as? [[[CLLocationDegrees]]] else {
            return nil
        }
    }
    
    public mutating func mapping(map: Map) {
        coordinates <- (map["coordinates"], CoordinateArrayOfArrayTransform())
    }
    
}

