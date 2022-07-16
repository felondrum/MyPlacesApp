//
//  PlaceModel.swift
//  MyPlacesApp
//
//  Created by Антон Филиппов on 16.07.2022.
//

import Foundation



struct Place {
    var name: String
    var location: String
    var type: String
    var image: String
    
    static let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Speak Easy", "Morris Pub", "Вкусные истории",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]
    
    static func getPlaces() -> [Place] {
        var places = [Place]()
        for r in restaurantNames {
            let place = Place(name: r, location: "Екатеринбург", type: "Ресторан", image: r)
            places.append(place)
        }
        return places
    }
    
}
