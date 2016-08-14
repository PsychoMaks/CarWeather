//
//  CarPhoto+CoreDataProperties.swift
//  SkywellCarWeather
//
//  Created by Maks Sergeychuk on 8/11/16.
//  Copyright © 2016 company.com. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CarPhoto {

    @NSManaged var imageData: NSData?
    @NSManaged var car: NSManagedObject?

}
