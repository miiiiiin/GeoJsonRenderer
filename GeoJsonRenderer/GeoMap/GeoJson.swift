//
//  GeoJson.swift
//  GeoJsonRenderer
//
//  Created by Running Raccoon on 2019/12/05.
//  Copyright © 2019 Running Raccoon. All rights reserved.
//

import Foundation

public protocol GeoJSON {
    
}

extension String {
    
    public func toGeoJSONObject(json: String) -> GeoJSON? {
        
        guard let jsonObject = json.jsonStringToDictionary else { return nil }
        
        guard let type = jsonObject["type"] as? String else {
            return nil
        }
        
        switch type {
        case "Point":
            return GeoPoint(JSONString: self)
            
        case "LineString":
            return GeoLineString(JSONString: self)
            
        case "Polygon":
            return GeoPolygon(JSONString: self)
            
        case "MultiPoint":
            return GeoMultiPolygon(JSONString: self)
            
        case "MultiLineString":
            return GeoMultiLineString(JSONString: self)
            
        case "MultiPolygon":
            return GeoMultiPolygon(JSONString: self)
        default:
            return nil
        }
    }
}
