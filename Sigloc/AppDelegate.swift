//
//  AppDelegate.swift
//  Sigloc
//
//  Created by jay on 1/16/19.
//  Copyright © 2019 jay. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager.init()
    var bgTask: UIBackgroundTaskIdentifier?
    let geocoder = CLGeocoder()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startMonitoringSignificantLocationChanges()
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            locationManager.startMonitoringSignificantLocationChanges()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let first = locations.first {
            record(location: first)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR")
    }
    
    func record(location: CLLocation) {
        if !isInForeground() {
            startBGTask(location: location)
        }
        geo(location: location) { locationWrap in
            Model.shared.add(location: locationWrap)
            if !self.isInForeground() {
                self.endBGTask()
            }
        }
    }
    
    func geo(location: CLLocation, complete: @escaping (Location) -> ()) {
        DispatchQueue.global().async {
            self.geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                var locationWrap = Location(
                    location: location,
                    timestamp: Date())
                if error == nil {
                    if let placemark = placemarks?.first {
                        locationWrap = Location(
                            location: location,
                            timestamp: Date(),
                            placeMark: placemark)
                    }
                }
                complete(locationWrap)
            }
        }
    }
    
    func startBGTask(location: CLLocation) {
        bgTask = UIApplication.shared.beginBackgroundTask(withName: "BG", expirationHandler: {
            if self.geocoder.isGeocoding {
                self.geocoder.cancelGeocode()
                let locationWrap = Location(
                    location: location,
                    timestamp: Date())
                Model.shared.add(location: locationWrap, update: false, save: false)
            }
            self.endBGTask()
        })
    }
    
    func endBGTask() {
        if let task = bgTask {
            UIApplication.shared.endBackgroundTask(task)
        }
        bgTask = UIBackgroundTaskIdentifier.invalid
    }
    
    func isInForeground() -> Bool {
        return UIApplication.shared.applicationState == .active
    }
}
