//
//  RealmManager.swift
//  Instagram
//
//  Created by Inna Kokorina on 29.04.2022.
//

import Foundation
import RealmSwift

class RealmManager {
    let realm = try! Realm()
    func saveRealm(photos: Photos) {
        
        do {
            try realm.write({
                try realm.add(photos)
            })
        } catch {
            print("Error saving Data context \(error)")
        }
    }
    
    
    func loadRealm () -> Results<Photos> {
       let postArray = realm.objects(Photos.self)
        return postArray
    }
}
