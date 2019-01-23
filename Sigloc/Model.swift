//
//  Model.swift
//  Sigloc
//
//  Created by jay on 1/21/19.
//  Copyright © 2019 jay. All rights reserved.
//

import Foundation
import CoreLocation

class Model {
    static let shared = Model()
    private init() {
        if let data = UserDefaults.standard.object(forKey: key) as? Data,
            let locs = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, Location.self], from: data) as? [Location] {
            locations = locs ?? [Location]()
            printLocations()
        }
    }
    let key = "LOCATION-KEY"
    var locations = [Location]()
    var update: (([Location]) -> ())?
    
    func add(location: Location, update shouldUpdate: Bool = true, save shouldSave: Bool = true) {
        locations.append(location)
        if let update = update, shouldUpdate {
            DispatchQueue.main.async {
                update(self.locations)
            }
        }
        if shouldSave {
           save()
        }
    }
    
    func register(updater: @escaping ([Location])->()) {
        update = updater
    }
    
    func unregister() {
        update = nil
    }
    
    private func save() {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: locations, requiringSecureCoding: false) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func printLocations() {
        for location in locations {
            var log = ""
            if let placemark = location.placemark {
                log = String(format: "%@ %@\n%@ - %@",
                             placemark.thoroughfare ?? "unknown",
                             placemark.subAdministrativeArea ?? "unknown",
                             placemark.administrativeArea ?? "unknown",
                             location.location.timestamp.description(with: NSLocale.current))
            } else {
                log = String(format: "%d, %d\n%@",
                             location.location.coordinate.latitude,
                             location.location.coordinate.longitude,
                             location.location.timestamp.description(with: NSLocale.current))
            }
            print(log)
        }
    }
}
