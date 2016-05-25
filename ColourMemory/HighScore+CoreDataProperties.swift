//
//  HighScore+CoreDataProperties.swift
//  ColourMemory
//
//  Created by Jacky Tjoa on 15/5/16.
//  Copyright © 2016 Coolheart. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension HighScore {

    @NSManaged var name: String?
    @NSManaged var score: NSNumber?

}
