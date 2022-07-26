//
//  CustomCell.swift
//  MyPlacesApp
//
//  Created by Антон Филиппов on 16.07.2022.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var rating: RatingView!
    
    @IBOutlet weak var imageOfPlace: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
}
