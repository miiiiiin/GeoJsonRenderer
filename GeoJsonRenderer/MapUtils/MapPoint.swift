//
//  MapPoint.swift
//  GeoJsonRenderer
//
//  Created by Running Raccoon on 2019/12/05.
//  Copyright © 2019 Running Raccoon. All rights reserved.
//

import Foundation
import ObjectMapper

open class MapPoint: Mappable {
    var latitude: Double!
    var longitude: Double!
    
    init() {
        
    }
    
    init(_ latitude: Double!, _ longitude: Double!) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public required init?(map: Map) {
        latitude = (try! map.value("latitude") ?? nil)
        longitude = (try! map.value("longitude") ?? nil)
    }
    
    open func mapping(map: Map) {
        latitude <- map["latitude"]
        longitude <- map["longitude"]
    }
}

