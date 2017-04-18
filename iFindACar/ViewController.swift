//
//  ViewController.swift
//  iFindACar
//
//  Created by Srini Motheram on 4/15/17.
//  Copyright © 2017 Srini Motheram. All rights reserved.
//

import UIKit
//import Parse
import SWXMLHash
import Alamofire


class ViewController: UIViewController {
    
   // let hostName4model = "http://www.fueleconomy.gov/ws/rest/vehicle/menu/model?year=2016&make=Toyota"
    var hostName4model :String!
    
    let hostName4options = "http://www.fueleconomy.gov/ws/rest/vehicle/menu/options?year=2012&make=Honda&model=Fit"
    var vehicleArray = [Vehicle]()
    var modelArray = [String]()
    var makeArray = ["Nissan","Ford", "Toyota", "Honda"]
    var yearArray = ["2017", "2016", "2015", "2014", "2013"]
    @IBOutlet var vehicleTableView      :UITableView!
    
    func alamoFire(){
        for year in yearArray {
            for make in makeArray {
                hostName4model = "http://www.fueleconomy.gov/ws/rest/vehicle/menu/model?" + "year=" + year + "&make=" + make
              //  print("\(hostName4model!)")
                Alamofire.request(hostName4model, method: .get, parameters: nil).response { ( response) in
                    print(response.data!) // if you want to check XML data in debug window.
                    let xmlResult = SWXMLHash.parse(response.data!)
                    for elem in xmlResult["menuItems"]["menuItem"].all {
                        print(elem["text"].element!.text!)
                        guard let currModel = elem["text"].element!.text! as? String else { continue }
                        
                        print("year: \(year), make: \(make), model: \(currModel)")
                        let newVehicle = Vehicle(modelYear: year, make: make, model: currModel)
                        self.vehicleArray.append(newVehicle)
                        
                        self.modelArray.append(elem["text"].element!.text!)
                    }
                    
                    print("vehicleArrayCount: \(self.vehicleArray.count)")
                } // makeArray loop
            } // yearArray loop
           
        }
    }
    
    func parseXML(xmlToParse :String) {
        do {
            print("in parse xml func")
           // let xmlFromFuelEconomyGov = getFileFromUrl(hostName: hostName4model)
            let xmlResult =  SWXMLHash.parse(xmlToParse)
             print("xmlResult: \(xmlResult)")
            
            
            for elem in xmlResult["menuItems"]["menuItem"].all {
                print(elem["text"].element!.text!)
                modelArray.append(elem["text"].element!.text!)
                }
            print("modelArrayCount: \(modelArray.count)")
        }
    }
    
    func getFileFromUrl(hostName: String) {
        var returnString    :String!
        
       // UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlString = hostName
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let receivedData = data else {
                print("No Data")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
            if receivedData.count > 0 && error == nil {
                print("Received Data:\(receivedData)")
                let dataString = String.init(data: receivedData, encoding: .utf8)
                print("Got Data String:\(dataString!)")
                returnString = dataString!
               self.parseXML(xmlToParse: dataString!)
            } else {
                print("Got Data of Length 0")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        task.resume()
        print("returnString: \(returnString)")
       // return returnString!
    }
    
    //Mark: - interactive methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segShowDetailView" {
            let indexPath = vehicleTableView.indexPathForSelectedRow!
            let currentVehicle = vehicleArray[indexPath.row]
            let destVC = segue.destination as! DetailViewController
            destVC.currentVehicle = currentVehicle
            vehicleTableView.deselectRow(at: indexPath, animated: true)
        }
    }
 
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
      // self.getFileFromUrl(hostName: hostName4model)
        self.alamoFire()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.vehicleTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("in table view: \(vehicleArray.count)")
        return vehicleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! VehicleTableViewCell
        let currentVehicle = vehicleArray[indexPath.row]
        
        cell.modelYearLabel.text = currentVehicle.modelYear
        cell.makeLabel.text = currentVehicle.make
        cell.modelLabel.text = currentVehicle.modelYear
        print("in table view methods")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
}

