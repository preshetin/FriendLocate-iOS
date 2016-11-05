//
//  ViewController.swift
//  FriendLocate
//
//  Created by Petr Reshetin on 28/09/2016.
//  Copyright © 2016 Petr Reshetin. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: GMSMapView!
    
    let locationManager = CLLocationManager()
    var currentUserUid: String {
        get {
            return (FIRAuth.auth()?.currentUser!.uid)!
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            map.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            let ref = FIRDatabase.database().reference()
            FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
                let locationToSave: [String:Any] = [
                    "uid": user!.uid,
                    "longitude": location.coordinate.longitude,
                    "latitude": location.coordinate.latitude,
                    "created_at": Int(NSDate().timeIntervalSince1970 * 1000),
                    "name": UIDevice.current.name
                ]
                ref.child("locations").child(user!.uid).setValue(locationToSave)
            })
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        map.isMyLocationEnabled = true
        map.settings.myLocationButton = true
        
        print("current user is \(self.currentUserUid)")
        
        let ref = FIRDatabase.database().reference(withPath: "locations")
        ref.observe(FIRDataEventType.value, with: { (snapshot) in
            let savedLocations = snapshot.value as! [String : AnyObject]
            for (_, location) in savedLocations {
                if location is [String:AnyObject] {
                    let uid = location["uid"]! as! String
                    let latitude = location["latitude"] as! CLLocationDegrees
                    let longitude = location["longitude"] as! CLLocationDegrees
                    if self.currentUserUid != uid {
                        print("Adding map marker for user \(uid)")
                        let position = CLLocationCoordinate2DMake(latitude, longitude)
                        let marker = GMSMarker(position: position)
                        marker.title = location["name"]! as? String
                        marker.map = self.map
//                        
//                        var southWest = CLLocationCoordinate2DMake(latitide,longititude)
//                        var northEast = CLLocationCoordinate2DMake(latitude,longitude)
//                        var bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
//                        var camera = mapView.cameraForBounds(bounds, insets:UIEdgeInsetsZero)
//                        mapView.camera = camera
                        
                    }
                }
            }
        })
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("MEMORY WARNING")
    }

}

