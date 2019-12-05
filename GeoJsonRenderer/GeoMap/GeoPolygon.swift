//
//  GeoPolygon.swift
//  GeoJsonRenderer
//
//  Created by Running Raccoon on 2019/12/05.
//  Copyright © 2019 Running Raccoon. All rights reserved.
//

import Foundation
import CoreLocation
import ObjectMapper

open class CoordinateArrayOfArrayTransform: TransformType {
    public typealias Object = [[CLLocationCoordinate2D]]
    public typealias JSON = [[[CLLocationDegrees]]]
    
    open func transformFromJSON(_ value: Any?) -> Object? {
        guard let jsonValue = value as? JSON, jsonValue.count > 0 else {
            return []
        }
        
        var coordinatesArray = [[CLLocationCoordinate2D]]()
        
        for valueArray in jsonValue {
            var coordinates = [CLLocationCoordinate2D]()
            
            for value in valueArray {
                guard value.count > 1 else {
                    continue
                }
                
                let coordinate = CLLocationCoordinate2D(latitude: value[1], longitude: value[0])
                coordinates.append(coordinate)
            }
            
            coordinatesArray.append(coordinates)
        }
        
        return coordinatesArray
    }
    
    open func transformToJSON(_ value: Object?) -> JSON? {
        guard let coordinatesArray = value else {
            return []
        }
        
        var jsonValueArray = [[[CLLocationDegrees]]]()
        for coordinates in coordinatesArray {
            var jsonValue = [[CLLocationDegrees]]()
            
            for coordinate in coordinates {
                let value = [coordinate.latitude, coordinate.longitude]
                jsonValue.append(value)
            }
            
            jsonValueArray.append(jsonValue)
        }
        
        return jsonValueArray
    }
}

open class CoordinateArrayOfArrayOfArrayTransform: TransformType {
    public typealias Object = [[[CLLocationCoordinate2D]]]
    public typealias JSON = [[[[CLLocationDegrees]]]]
    
    open func transformFromJSON(_ value: Any?) -> Object? {
        guard let jsonValue = value as? JSON, jsonValue.count > 0 else {
            return []
        }
        
        var coordinatesArrayOfArray = [[[CLLocationCoordinate2D]]]()
        
        for valueArrayOfArray in jsonValue {
            var coordinatesArray = [[CLLocationCoordinate2D]]()
            
            for valueArray in valueArrayOfArray {
                var coordinates = [CLLocationCoordinate2D]()
                
                for value in valueArray {
                    let coordinate = CLLocationCoordinate2D(latitude: value[1], longitude: value[0])
                    coordinates.append(coordinate)
                }
                
                coordinatesArray.append(coordinates)
            }
            
            coordinatesArrayOfArray.append(coordinatesArray)
        }
        
        return coordinatesArrayOfArray
    }
    
    open func transformToJSON(_ value: Object?) -> JSON? {
        guard let coordinatesArrayOfArray = value else {
            return []
        }
        
        var jsonValueArrayOfArray = [[[[CLLocationDegrees]]]]()
        
        for coordinatesArray in coordinatesArrayOfArray {
            var jsonValueArray = [[[CLLocationDegrees]]]()
            
            for coordinates in coordinatesArray {
                var jsonValue = [[CLLocationDegrees]]()
                
                for coordinate in coordinates {
                    let value = [coordinate.latitude, coordinate.longitude]
                    jsonValue.append(value)
                }
                
                jsonValueArray.append(jsonValue)
            }
            
            jsonValueArrayOfArray.append(jsonValueArray)
        }
        
        return jsonValueArrayOfArray
    }
}

public struct GeoPolygon: GeoJSON, Mappable {
    
    public var coordinates: [[CLLocationCoordinate2D]]!
    public var outer: [CLLocationCoordinate2D] = []
    public var inner: [CLLocationCoordinate2D] = []
    
    public init(coordinates: [[CLLocationCoordinate2D]]) {
        self.coordinates = coordinates
        
        var outerList: [CLLocationCoordinate2D] = coordinates[0]
        for point in outerList {
            self.outer.append(point)
        }
        for i in 1..<coordinates.count {
            var innerList = coordinates[i]
            for point in innerList {
                self.inner.append(point)
            }
        }
    }
    
    public init?(map: Map) {
        guard let type = map.JSON["type"] as? String, type == "Polygon" else {
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

public struct GeoMultiPolygon: GeoJSON, Mappable {
    
    public var type: String!
    public var coordinates: [[[CLLocationCoordinate2D]]]!
    public var polygons: [GeoPolygon] {
        get {
            return self.coordinates.map {
                return GeoPolygon(coordinates: $0)
            }
        }
    }
    
    public var geopolygons: [GeoPolygon]!
    
    public init?(map: Map) {
        guard let type = map.JSON["type"] as? String, type == "MultiPolygon" else {
            return nil
        }
        
        self.type = type
        
        guard let coordinates = map.JSON["coordinates"] as? [[[[CLLocationDegrees]]]] else {
            return nil
        }
        
        //        self.geopolygons = polygons
    }
    
    public mutating func mapping(map: Map) {
        coordinates <- (map["coordinates"], CoordinateArrayOfArrayOfArrayTransform())
        
    }
    
    public func isPolygon() -> Bool {
        return self.type.isEqual("Polygon")
    }
    
    public func isMultiPolygon() -> Bool {
        return self.type.isEqual("MultiPolygon")
    }
    
    public func getMultiPolygon() -> [GeoPolygon] {
        if (self.isMultiPolygon()) {
            var coordinates = self.coordinates as! [[[CLLocationCoordinate2D]]]
            
            for polygon in coordinates {
                var pg = GeoPolygon(coordinates: polygon)//Polygon(points: polygon)
                //                self.polygons.append(pg)
            }
        } else if (self.isPolygon()) {
            var coordinates = self.coordinates as! [[CLLocationCoordinate2D]]
            var pg = GeoPolygon(coordinates: coordinates)
            //            self.polygons.append(pg)
        } else {
        }
        
        return self.polygons
    }
}
