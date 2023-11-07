//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/7.
//

import Foundation
import CoreLocation

public class GetLocationTool: BaseTool, CLLocationManagerDelegate {
    
    // Add "Privacy – Location When In Use Usage Description" to Info.plist (or add NSLocationWhenInUseUsageDescription key)
    
    var longitude: Double =  0.0
    var latitude: Double =  0.0
    let locationManager:CLLocationManager = CLLocationManager()
    
    public override init(callbacks: [BaseCallbackHandler] = []) {
        super.init(callbacks: callbacks)
    }
    public override func name() -> String {
        "GetLocation"
    }
    
    public override func description() -> String {
        """
        Tool to get current locationz.
        Input must be here.
        Returns the current longitude and latitude, such as -78.4:38.5.
"""
    }
    
    public override func _run(args: String) async throws -> String {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
        locationManager.requestAlwaysAuthorization()
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.startUpdatingLocation()
            print("started get location.")
        }
        //wait
        return "\(longitude):\(latitude)"
    }
    
    private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currLocation:CLLocation = locations.last!
        longitude = currLocation.coordinate.longitude
        latitude = currLocation.coordinate.latitude
        // signal
    }
}
