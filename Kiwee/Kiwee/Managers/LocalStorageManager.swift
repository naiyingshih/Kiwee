//
//  LocalStorageManager.swift
//  Kiwee
//
//  Created by NY on 2024/4/19.
//

import UIKit
import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - CRUD Operations
    
    func fetchPlantImages() -> [LSFarm] {
        let fetchRequest: NSFetchRequest<LSFarm> = LSFarm.fetchRequest()
        do {
            let plantImages = try context.fetch(fetchRequest)
            return plantImages
        } catch {
            print("Failed to fetch plant images: \(error)")
            return []
        }
    }
    
    func savePlantImage(imageName: String, addTime: Int32, xPosition: Double, yPosition: Double) {
        let plantImageEntity = LSFarm(context: context)
        plantImageEntity.imageName = imageName
        plantImageEntity.addTime = addTime
        plantImageEntity.xPosition = xPosition
        plantImageEntity.yPosition = yPosition
        
        do {
            try context.save()
        } catch {
            print("Failed to save plant image: \(error)")
        }
    }
    
    func fetchLatestAddTime() -> Int {
        let fetchRequest: NSFetchRequest<LSFarm> = LSFarm.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "addTime", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let result = try context.fetch(fetchRequest)
            return Int(result.first?.addTime ?? 0)
        } catch {
            print("Failed to fetch latest addTime: \(error)")
            return 0
        }
    }
    
//    func saveContext() {
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                print("Error saving context: \(error)")
//            }
//        }
//    }
//    
//    func deleteItem(_ object: LSFarm) {
//        context.delete(object)
//        saveContext()
//    }
    
}
