//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Сергей Розов on 18.05.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell {    
 
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var gradientImage: UIImageView!
    
    static let reuseIdentifier = "ImagesListCell"
    
    private let gradient = CAGradientLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cellImage.layer.cornerRadius = 16
        cellImage.layer.masksToBounds = true
        gradientImage.layer.cornerRadius = 16
        gradientImage.layer.masksToBounds = true
        
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.ypBlack.withAlphaComponent(0.5).cgColor
        ]
        gradient.frame = gradientImage.bounds
        gradientImage.layer.addSublayer(gradient)
    }

}
