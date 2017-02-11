//
//  Location.swift
//  PennLabsInterview
//
//  Created by Josh Doman on 2/10/17.
//  Copyright © 2017 Josh Doman. All rights reserved.
//

import UIKit
import CoreLocation

class Place: NSObject {
    
    let location: CLLocationCoordinate2D!
    let name: String!
    
    init(location: CLLocationCoordinate2D, name: String) {
        self.location = location
        self.name = name
    }
    
}
