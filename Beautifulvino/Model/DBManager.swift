//
//  DBManager.swift
//  Tamoil
//
//  Created by Antonio Laudazi on 01/07/16.
//  Copyright © 2016 Maria Tourbanova. All rights reserved.
//

import UIKit
import CoreData

class DBManager: NSObject {
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.marte5.Scadenze" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Beautifulvino", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("BeautifulvinoCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    private func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    // MARK: - User
    
/*    func saveUser(utente:Utente){
        let context: NSManagedObjectContext=managedObjectContext
        let entityDescripition =  NSEntityDescription.entity(forEntityName: "User", in: context)
        let user = User(entity: entityDescripition!, insertInto:managedObjectContext)
        user.idUser=Int16(utente.idUtente)
        user.nomeUser=utente.nomeUtente
        user.cognomeUser=utente.cognomeUtente
        user.creditiUtente=Int16(utente.creditiUtente)
        user.esperienzaUser=Int16(utente.esperienzaUtente)
        user.biografiaUser=utente.biografiaUtente
        user.urlFotoUser=utente.urlFotoUtente
        saveContext()
    }
    
    func deleteUser(idUser:Int){
        var users = [User]()
        let context: NSManagedObjectContext=managedObjectContext
        let fetchRequest:NSFetchRequest<User>=User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format:"idUser ==  %d ", idUser)
        do {
            let results =
                try context.fetch(fetchRequest)
            users = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        context.delete(users[0])
        saveContext()
    }
    
    func getUser(idUser:Int)->User?{
        var users = [User]()
        let context: NSManagedObjectContext=managedObjectContext
        let fetchRequest:NSFetchRequest<User>=User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format:"idUser ==  %d", idUser)
        do {
            let results =
                try context.fetch(fetchRequest)
            users = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        if users.count>0 {
            return users[0]
        }
        return nil
    }
    
  */
}



