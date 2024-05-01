//
//  LocalStorageManager.swift
//  Kiwee
//
//  Created by NY on 2024/4/19.
//

import UIKit
import CoreData

// MARK: - Plant storage manager

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
    
    func updatePlantImagePosition(addTime: Int32, xPosition: Double, yPosition: Double) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "LSFarm")
        fetchRequest.predicate = NSPredicate(format: "addTime == %d", addTime)
        
        do {
            let results = try context.fetch(fetchRequest)
            for case let farmObjectToUpdate as LSFarm in results {
                farmObjectToUpdate.setValue(xPosition, forKey: "xPosition")
                farmObjectToUpdate.setValue(yPosition, forKey: "yPosition")
            }
            try context.save()
        } catch let error as NSError {
            print("Failed to update plant image position: \(error), \(error.userInfo)")
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

// MARK: - User data manager

class UserDataManager {
    static let shared = UserDataManager()

    func getCurrentUserData(id: String) -> UserData {
        let defaults = UserDefaults.standard
        return UserData(
            id: id,
            name: defaults.string(forKey: "name") ?? "",
            gender: defaults.integer(forKey: "gender"),
            age: defaults.integer(forKey: "age"),
            goal: defaults.integer(forKey: "goal"),
            activeness: defaults.integer(forKey: "activeness"),
            height: defaults.double(forKey: "height"),
            initialWeight: defaults.double(forKey: "initial_weight"),
            updatedWeight: defaults.double(forKey: "initial_weight"),
            goalWeight: defaults.double(forKey: "goal_weight"),
            achievementTime: defaults.object(forKey: "achievement_time") as? Date ?? Date()
        )
    }
}
