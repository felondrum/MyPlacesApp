//
//  RatingView.swift
//  MyPlacesApp
//
//  Created by Антон Филиппов on 26.07.2022.
//

import UIKit

@IBDesignable class RatingView: UIStackView {
    
    // MARK: Properties
    private var ratingImage = [UIImageView]()
    var rating = 0 {
        didSet {
            setUpImages()
        }
    }
    
    @IBInspectable var starSize: CGSize = CGSize(width: 20, height: 20) {
        didSet {
            setUpImages()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setUpImages()
        }
    }
    
    // MARK: Inizialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpImages()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setUpImages()
    }
    
    //MARK: private methods
    private func setUpImages() {
        
        for image in ratingImage {
            removeArrangedSubview(image)
            image.removeFromSuperview()
        }
        
        ratingImage.removeAll()
        
        //        // Load button image
        //        let bundle = Bundle(for: type(of: self))
        //
        //        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        //        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        //        let highlitedStar = UIImage(named: "highlitedStar", in: bundle, compatibleWith: self.traitCollection)
        
        for i in 0..<starCount {
            //create button
            
            let image = UIImageView()
            
            image.image = checkStateForImageBy(index: i)
            
            // set button image
            //            button.setImage(emptyStar, for: .normal)
            //            button.setImage(filledStar, for: .selected)
            //            button.setImage(highlitedStar, for: .highlighted)
            
            //add constraint for button
            image.translatesAutoresizingMaskIntoConstraints = false
            image.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            image.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // add button to stack view
            addArrangedSubview(image)
            
            // add button to rating button array
            ratingImage.append(image)
        }
        
    }
    
    private func checkStateForImageBy(index: Int) -> UIImage {
        if (index < rating) {
            return getStarBy(name: "filledStar")
        } else {
            return getStarBy(name: "emptyStar")
        }
    }
    
    
    private func getStarBy(name: String) -> UIImage {
        guard let star = UIImage(named: name, in: Bundle(for: type(of: self)), compatibleWith: self.traitCollection) else { return UIImage() }
        return star
    }
    
}
