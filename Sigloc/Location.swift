//
//  Location.swift
//  Sigloc
//
//  Created by jay on 1/22/19.
//  Copyright © 2019 jay. All rights reserved.
//

import Foundation
import CoreLocation

class Location: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    let locationKey = "Location"
    let timestampKey = "Timestamp"
    let placemarkKey = "Placemark"
    var location: CLLocation
    var timestamp: Date
    var placemark: CLPlacemark?
    
    init(location: CLLocation, timestamp: Date, placeMark: CLPlacemark? = nil) {
        self.location = location
        self.timestamp = timestamp
        self.placemark = placeMark
    }
    
    required init?(coder aDecoder: NSCoder) {
        location = aDecoder.decodeObject(of: CLLocation.self, forKey: locationKey)!
        timestamp = aDecoder.decodeObject(of: NSDate.self, forKey: timestampKey)! as Date
        placemark = aDecoder.decodeObject(of: CLPlacemark.self, forKey: placemarkKey)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(location, forKey: locationKey)
        aCoder.encode(timestamp, forKey: timestampKey)
        if let pm = placemark {
            aCoder.encode(pm, forKey: placemarkKey)
        }
    }
}
