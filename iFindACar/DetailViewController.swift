//
//  DetailViewController.swift
//  iFindACar
//
//  Created by Srini Motheram on 4/17/17.
//  Copyright © 2017 Srini Motheram. All rights reserved.
//

import UIKit
import SWXMLHash
import Alamofire

class DetailViewController: UIViewController, UINavigationControllerDelegate  {
    
    var currentVehicle  :Vehicle?
    
    @IBOutlet var modelYearLabel2    :UILabel!
    @IBOutlet var makeLabel2         :UILabel!
    @IBOutlet var modelLabel2        :UILabel!
    
    var hostName4options :String!
    var hostName4detailsByVehicleId :String!
    var vehicleId        :String!
    var powerTrain    = "no data"
    var vehicleIDArray = [String]()
    
    // let hostName4options = "http://www.fueleconomy.gov/ws/rest/vehicle/menu/options?year=2012&make=Honda&model=Fit"
    
    
    func alamoFire2(currCar: Vehicle){
        
        hostName4options = "http://www.fueleconomy.gov/ws/rest/vehicle/menu/options?" + "year=" + currCar.modelYear + "&make=" + currCar.make + "&model="+currCar.model
        print("\(hostName4options!)")
        Alamofire.request(hostName4options, method: .get, parameters: nil).response { ( response) in
            // print(response.data!) // if you want to check XML data in debug window.
            let xmlResult = SWXMLHash.parse(response.data!)
            for elem in xmlResult["menuItems"]["menuItem"].all {
                //  print(elem["text"].element!.text!)
                guard let currVehicleId = elem["value"].element!.text!  as? String
                    else { print("nothing in currVehicleId"); continue }
                self.vehicleIDArray.append(currVehicleId)
                self.hostName4detailsByVehicleId = "http://www.fueleconomy.gov/ws/rest/vehicle/" + self.vehicleIDArray.first!
                print("hostName4detailsByVehicleID: \(self.hostName4detailsByVehicleId!)")
            }
            //  DispatchQueue.main.async {
            //      self.vehicleTableView.reloadData()
            //   }
        }
    }
    
    func alamoFire3(){
        Alamofire.request(self.hostName4detailsByVehicleId!, method: .get, parameters: nil).response { ( response) in
            // print(response.data!) // if you want to check XML data in debug window.
            let xmlResultFinal = SWXMLHash.parse(response.data!)
            for elem in xmlResultFinal["vehicle"].all {
                //  print(elem["text"].element!.text!)
                guard let cityMPG = elem["city08"].element!.text!  as? String
                    else { print("nothing in currPowerTRain"); continue }
                print("cityMPG: \(cityMPG)")
                
            }
        }
    }

    
    func showCarDetails(currCar: Vehicle) {
        modelYearLabel2.text = currCar.modelYear
        makeLabel2.text = currCar.make
        modelLabel2.text = currCar.model
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        alamoFire2(currCar: currentVehicle!)
        showCarDetails(currCar: currentVehicle!)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
//        print("\(currentFoodDish?.imageName)")
//        if currentFoodDish?.imageName != nil {
//            print("GOT HERE!!!")
//            let imgUrl = getDocumentPathForFile(filename: (currentFoodDish?.imageName)!)
//            print("\(imgUrl)")
//            capturedImage.image = UIImage(contentsOfFile: imgUrl.path)
//        }
        print("\(vehicleIDArray.count)")
        if vehicleIDArray.count < 0 {
            alamoFire2(currCar: currentVehicle!)
            sleep(2)
        }
       // alamoFire3()
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
}
