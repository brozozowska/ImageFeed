//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Сергей Розов on 24.05.2025.
//

import UIKit

class SingleImageViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    
}
