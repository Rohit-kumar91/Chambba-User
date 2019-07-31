//
//  PlaceMarker.swift
//  Abba Taxi
//
//  Created by Rishabh Arora on 11/17/18.
//  Copyright © 2018 Rishabh Arora. All rights reserved.
//

import UIKit
import GoogleMaps

class PlaceMarker: GMSMarker {
    
    init(place: CLLocationCoordinate2D, image:String) {
        super.init()
        
        position = place
        if image == "UserIcon"{
            icon = #imageLiteral(resourceName: "userPinIcon")
        }else {
            icon =  #imageLiteral(resourceName: "userPinIcon")
        }
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = .pop
    }
    
}
