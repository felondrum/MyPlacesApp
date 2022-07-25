//
//  StorageManager.swift
//  MyPlacesApp
//
//  Created by Антон Филиппов on 21.07.2022.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    static func savePlace(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deletePlace(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
}
