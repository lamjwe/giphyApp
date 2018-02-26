//
//  GiphyCoreDataHandler.swift
//  GiphyApp
//
//  Created by Jonathan Lam on 2018-02-17.
//  Copyright © 2018 Jonathan Lam. All rights reserved.
//

import UIKit
import CoreData

class GiphyCoreDataHandler:NSObject {
    //singleton
    static let sharedInstance = GiphyCoreDataHandler()

    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

    // Saving GIFs to Core Data
    func saveGIPHYToFavourite(giphy:GiphImage) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Giphy", in: context)
        let manageObject = NSManagedObject(entity: entity!, insertInto: context)

        let imageData = getImageDataFromURL(urlString: giphy.originalUrl)
        let downsizedImageData = getImageDataFromURL(urlString: giphy.downsizedUrl)

        manageObject.setValue(giphy.title, forKey: "title")
        manageObject.setValue(giphy.id, forKey: "id")
        manageObject.setValue(giphy.downsizedUrl, forKey: "downsizedUrl")
        manageObject.setValue(giphy.originalUrl, forKey: "originalUrl")

        manageObject.setValue(imageData, forKey: "image")
        manageObject.setValue(downsizedImageData, forKey: "downsizedImage")

        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }

    // Fetching all GIFs stored on device
    func fetchFavouriteGIPHYs(id: String? = nil, completion: @escaping ([GiphImage]?) -> ()) {
        let context = getContext()
        var giphys:[GiphImage]? = nil

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Giphy")

        if let giphyID = id {
            request.predicate = NSPredicate(format: "id = %@", giphyID)
        }

        request.returnsObjectsAsFaults = false

        do {
            let result = try context.fetch(request)
            giphys = []
            for data in result as! [NSManagedObject] {
                let title = data.value(forKey: "title") as! String
                let id = data.value(forKey: "id") as! String
                let downsizedUrl = data.value(forKey: "downsizedUrl") as! String
                let originalUrl = data.value(forKey: "originalUrl") as! String

                let originalImageData = data.value(forKey: "image") as! NSData
                let downsizedImageData = data.value(forKey: "downsizedImage") as! NSData

                giphys?.append(GiphImage(title: title, id: id, downsizedUrl: downsizedUrl, originalUrl: originalUrl, originalImageData: originalImageData as Data, downsizedImageData: downsizedImageData as Data))
            }
        } catch {
            print("Failed")
        }
        completion(giphys)
    }

    // Fetch the ID of all the GIFs stored on the device
    func fetchFavouriteGIPHYIDs(completion: @escaping ([String]?) -> ()) {
        let context = getContext()
        var ids:[String]? = nil

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Giphy")
        request.propertiesToFetch = ["id"]

        do {
            let result = try context.fetch(request)
            ids = []
            for data in result as! [NSManagedObject] {
                let id = data.value(forKey: "id") as! String
                ids?.append(id)
            }
        } catch {
            print("Failed")
        }
        completion(ids)
    }

    // Delete GIFs from device
    func deleteGIPHYFromFavourite(id:String, completion: @escaping (Bool) -> ()){
        let context = getContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Giphy")
        request.predicate = NSPredicate(format: "id = %@", id)
        if let result = try? context.fetch(request) {
            for object in result {
                context.delete(object as! NSManagedObject)
            }
        }
        do {
            try context.save()
            completion(true)
        } catch {
            completion(false)
        }
    }

    // Testing: For clearing all data in Core Data
    func deleteAllRecords() {
        let context = getContext()
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Giphy")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }

    // Helper function for casting GIF image to type Data
    private func getImageDataFromURL(urlString:String) -> Data? {
        guard let url:URL = URL(string: urlString)
            else {
                print("image named \"\(urlString)\" doesn't exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: url) else {
            print("image named \"\(url)\" into NSData")
            return nil
        }
        return imageData
    }
}
