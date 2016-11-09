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
    
    @IBAction func unwindToMap(segue: UIStoryboardSegue) {}
    
    let locationManager = CLLocationManager()

    
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
        
        drawFriendMarkersOnMap()
    }
    
    
    private func drawFriendMarkersOnMap() {
        let ref1 = FIRDatabase.database().reference(withPath: "locations")
        
        ref1.observeSingleEvent(of: .value, with: { (snapshot) in
            let savedLocations = snapshot.value as! [String : AnyObject]
            for (_, loc) in savedLocations {
                if loc is [String:AnyObject] {
                    let uid = loc["uid"]! as! String
                    let latitude = loc["latitude"] as! CLLocationDegrees
                    let longitude = loc["longitude"] as! CLLocationDegrees
                    if FIRAuth.auth()?.currentUser!.uid != uid {
                        print("Adding map marker for user \(uid)")
                        let position = CLLocationCoordinate2DMake(latitude, longitude)
                        let marker = GMSMarker(position: position)
                        marker.title = loc["name"]! as? String
                        marker.map = self.map
                        
                        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
                            let southWest = CLLocationCoordinate2DMake(latitude,longitude)
                            let northEast = self.map.myLocation!.coordinate
                            let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
                            let camera = self.map.camera(for: bounds, insets:UIEdgeInsets.init(top: 50, left: 50, bottom: 50, right: 50))
                            self.map.camera = camera!
                        }
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

