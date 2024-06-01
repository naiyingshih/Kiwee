//
//  LSFarm+CoreDataProperties.swift
//  Kiwee
//
//  Created by NY on 2024/4/20.
//
//

import Foundation
import CoreData

extension LSFarm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LSFarm> {
        return NSFetchRequest<LSFarm>(entityName: "LSFarm")
    }

    @NSManaged public var imageName: String?
    @NSManaged public var xPosition: Double
    @NSManaged public var yPosition: Double
    @NSManaged public var addTime: Int32

}

extension LSFarm : Identifiable {

}
