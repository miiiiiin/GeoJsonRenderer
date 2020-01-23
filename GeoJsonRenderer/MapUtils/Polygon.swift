//
//  Polygon.swift
//  GeoJsonRenderer
//
//  Created by Running Raccoon on 2019/12/05.
//  Copyright © 2019 Running Raccoon. All rights reserved.
//

import Foundation
import CoreLocation

public class Polygon {
    public var outer: [CLLocationCoordinate2D] = []
    public var inner: [CLLocationCoordinate2D] = []
    
    init(points: [[CLLocationCoordinate2D]]) {
        let outerList: [[CLLocationCoordinate2D]] = points//[0]
        
        for point in outerList {
            let mapPoint = CLLocationCoordinate2D(latitude: point[0].latitude, longitude: point[0].latitude)
            self.outer.append(mapPoint)
        }
        
        for i in 0..<outerList.count {
            let innerList = points[i];
            for point in innerList {
                let mapPoint = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
                self.inner.append(mapPoint)
            }
        }
    }
}
