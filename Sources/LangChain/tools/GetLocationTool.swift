//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/7.
//

import Foundation
import CoreLocation

public class GetLocationTool: BaseTool, CLLocationManagerDelegate {
    
    // Add "Privacy - Location When In Use Usage Description" to Info.plist
    let locationManager:CLLocationManager = CLLocationManager()
    var authorizationStatus: CLAuthorizationStatus?
    private var locationContinuation: CheckedContinuation<String, Error>?
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
        //wait
        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
        }
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currLocation:CLLocation = locations.last!
        let longitude = currLocation.coordinate.longitude
        let latitude = currLocation.coordinate.latitude
        // signal
        locationContinuation?.resume(returning: "\(longitude):\(latitude)")
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(manager.authorizationStatus)
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:  // Location services are available.
            // Insert code here of what should happen when Location services are authorized
            authorizationStatus = .authorizedWhenInUse
            locationManager.requestLocation()
            break
            
        case .restricted:  // Location services currently unavailable.
            // Insert code here of what should happen when Location services are NOT authorized
            authorizationStatus = .restricted
            break
            
        case .denied:  // Location services currently unavailable.
            // Insert code here of what should happen when Location services are NOT authorized
            authorizationStatus = .denied
            break
            
        case .notDetermined:        // Authorization not determined yet.
            authorizationStatus = .notDetermined
            manager.requestWhenInUseAuthorization()
            break
            
        default:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
}
