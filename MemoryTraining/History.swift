//
//  History.swift
//  MemoryTraining
//
//  Created by Александр Подрабинович on 09/01/15.
//  Copyright (c) 2015 Alex Podrabinovich. All rights reserved.
//

import Foundation
import CoreData

@objc(History)
class History: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var level: NSNumber

}
