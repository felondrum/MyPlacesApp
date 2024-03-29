//
//  CustomCell.swift
//  MyPlacesApp
//
//  Created by Антон Филиппов on 16.07.2022.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var rating: RatingView!
    
    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace?.layer.cornerRadius = imageOfPlace.frame.size.height / 2
            imageOfPlace?.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
}
