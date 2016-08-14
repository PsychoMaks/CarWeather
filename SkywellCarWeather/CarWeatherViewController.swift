//
//  CarWeatherViewController
//  SkywellCarWeather
//
//  Created by Maks Sergeychuk on 8/11/16.
//  Copyright © 2016 company.com. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import AlamofireImage
import Alamofire

class CarWeatherViewController: UITableViewController,CLLocationManagerDelegate, CarCreationDelegate {
    
    @IBOutlet var headerBGImageView: UIImageView!
    @IBOutlet var headerDegreesLabel: UILabel!
    @IBOutlet var headerWeatherIndicatorImageView: UIImageView!
    @IBOutlet var headerSkyLabel: UILabel!
    @IBOutlet var headerCityLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var request: Request? = nil
    
    var weather: Weather? {
        didSet{
            setupHeaderFileds()
        }
    }

    var detailViewController: CarInfoViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        weather = Weather.getWeather(withWeatherInfo: nil, inManagedObjectContext: managedObjectContext!)
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.54, green:0.76, blue:0.19, alpha:1.0)
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? CarInfoViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getMyLocation()
    }
    
    
    func newCarCreated(car: Car) {
        print("newcar created succerfly")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation = locations[locations.count - 1]
        let lat = latestLocation.coordinate.latitude
        let lon = latestLocation.coordinate.longitude
        let path = "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=2854c5771899ff92cd962dd7ad58e7b0"
        print(path)
        
        self.request?.cancel()
        self.request = Alamofire.request(.GET, path).responseJSON {[unowned self] (response) in
            if let JSON = response.result.value {
                self.weather = Weather.getWeather(withWeatherInfo: JSON as? NSDictionary, inManagedObjectContext: self.managedObjectContext!)
            }
        }
    }
    
    func getMyLocation() {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.startUpdatingLocation()
        }
    }

    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Car
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! CarInfoViewController
                controller.carItem = object
            }
        } else if segue.identifier == "carCreation" {
            let vc = segue.destinationViewController as! CarCreationViewController
            vc.delegate = self
        }
    }
    
    // MARK: - Supporting func's
    func setupHeaderFileds() {
        if let weather = weather {
            headerSkyLabel.text = weather.sky
            if let degr = weather.degrees {
                headerDegreesLabel.text = String(format: "%+.0f", degr.doubleValue)
            }
            headerCityLabel.text = weather.city
            if let imageData = weather.image {
                headerWeatherIndicatorImageView.image = UIImage(data: imageData)
            }
            locationManager.stopUpdatingLocation()
        }
    }
    
    var _fetchedResultsController: NSFetchedResultsController? = nil
}


// MARK: - Table View
extension CarWeatherViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! carPreviewTableViewCell
        let car = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Car
        self.configureCell(cell, withCarInfo: car)
        return cell
    }
    
    // MARK: Ediging
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func configureCell(cell: carPreviewTableViewCell, withCarInfo car: Car) {
        cell.carNameLabel.text = car.name
        cell.carPriceLabel.text = car.price
        if car.photos?.count > 0 {
            cell.carPreviewImageView.image = UIImage(data: (car.photos?.anyObject() as! CarPhoto).imageData!)
        }
    }
}


// MARK: - Fetched results controller
extension CarWeatherViewController: NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Car", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "price", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!) as! carPreviewTableViewCell, withCarInfo: anObject as! Car)
        case .Move:
            tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}

