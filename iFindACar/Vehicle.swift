//
//  Vehicle.swift
//  iFindACar
//
//  Created by Srini Motheram on 4/15/17.
//  Copyright © 2017 Srini Motheram. All rights reserved.
//

import UIKit

class Vehicle: NSObject {
    var modelYear    :String!
    var make    :String!
    var model   :String!
  
    
    convenience init(modelYear: String, make: String, model: String) {
        self.init()
        self.modelYear = modelYear
        self.make = make
        self.model = model
    }

}
