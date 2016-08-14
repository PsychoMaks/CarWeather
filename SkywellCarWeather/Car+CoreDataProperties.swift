//
//  Car+CoreDataProperties.swift
//  SkywellCarWeather
//
//  Created by Maks Sergeychuk on 8/14/16.
//  Copyright © 2016 company.com. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Car {

    @NSManaged var condition: String?
    @NSManaged var desc: String?
    @NSManaged var engine: String?
    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var price: String?
    @NSManaged var transmission: String?
    @NSManaged var photos: NSSet?

}
