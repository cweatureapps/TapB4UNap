//
//  LocationManager.swift
//  TapB4UNap
//
//  Created by Ken Ko on 5/06/2016.
//  Copyright © 2016 Ken Ko. All rights reserved.
//

import Foundation
import CoreLocation
import XCGLogger

protocol LocationManagerDelegate {
    /// Called when exiting a region
    func didExitRegion()
}

/**
The `LocationManager` handles region monitoring for this app.

- remark:
Region monitoring has been chosen as it allows more fine grain accuracy in detecting change.
It will also make it easy to support iBeacon technology in the future.

Significant location change works at approximately 500m which is too much for our purposes.

Location-Based local notifications is also not viable, as this code needs to be accessible from a today widget,
which won't have access to `UIApplication.sharedApplication()` in order to schedule a notification.

*/
class LocationManager: NSObject {

    static let sharedInstance = LocationManager()

    private enum Constants {
        static let radius = 50.0
        static let isMonitoringKey = "isMonitoring"
    }

    private let log = XCGLogger.defaultInstance()
    private let userDefaults: NSUserDefaults = SettingsManager.sharedUserDefaults

    private(set) var isMonitoring: Bool {
        get {
            return userDefaults.boolForKey(Constants.isMonitoringKey)
        }
        set {
            userDefaults.setBool(newValue, forKey: Constants.isMonitoringKey)
            userDefaults.synchronize()
        }
    }

    private var isAuthorizing = false

    private var coreLocationManager = CLLocationManager()

    var delegate: LocationManagerDelegate?

    override private init() {
        super.init()
        coreLocationManager.delegate = self
    }

    /**
    Set up and start monitoring a geofence around the current location, requesting authorization if required.
    If location services is unavailable, this fails silently and logs.
    */
    func setupGeofence() {
        guard CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) else {
            log.debug("Geofencing is not supported on this device")
            return
        }
        switch CLLocationManager.authorizationStatus() {
        case .Denied: fallthrough
        case .Restricted:
            log.debug("no permission for location")
        case .NotDetermined: fallthrough
        case .AuthorizedWhenInUse:
            isAuthorizing = true
            coreLocationManager.requestAlwaysAuthorization()
        case .AuthorizedAlways:
            startMonitoring()
        }
    }

    private func startMonitoring() {
        log.debug("startMonitoring called")
        cancelAllGeofences()
        coreLocationManager.requestLocation()
    }

    /// Stop monitoring all regions which are currently registered
    func cancelAllGeofences() {
        let monitoredRegions = coreLocationManager.monitoredRegions
        log.info("stop monitoring all regions, count: \(monitoredRegions.count)")
        for r in monitoredRegions {
            coreLocationManager.stopMonitoringForRegion(r)
        }
        isMonitoring = false
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        log.info("didUpdateLocations called, location received")
        guard !isMonitoring, let coord = locations.first?.coordinate else { return }
        let region = CLCircularRegion(center: coord, radius: Constants.radius, identifier: NSUUID().UUIDString)
        region.notifyOnEntry = false
        region.notifyOnExit = true
        coreLocationManager.startMonitoringForRegion(region)
        isMonitoring = true
        log.info("started monitoring region, number of regions: \(coreLocationManager.monitoredRegions.count)")
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        guard isAuthorizing && status == .AuthorizedAlways else { return }
        isAuthorizing = false
        startMonitoring()
    }

    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        log.info("didExitRegion called")
        guard isMonitoring else { return }
        log.debug("didExitRegion passed guard and is running")
        cancelAllGeofences()
        delegate?.didExitRegion()
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        log.error(error.localizedDescription)
    }

    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        log.error(error.localizedDescription)
    }
}
