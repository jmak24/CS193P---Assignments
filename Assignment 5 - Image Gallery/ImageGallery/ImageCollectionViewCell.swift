//
//  ImageCollectionViewCell.swift
//  ImageGallery
//
//  Created by Jon Mak on 2019-01-28.
//  Copyright © 2019 Jon Mak. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView! 
    
    var imageURL: URL? {
        didSet {
            imageView.image = nil
            updateUI()
        }
    }
    
    var aspectRatio: Double?
    
    private func updateUI() {
        if let url = imageURL {
            spinner?.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let imageData = urlContents, url == self?.imageURL {
                        self?.imageView.image = UIImage(data: imageData)
                    }
                    self?.spinner?.stopAnimating()
                }
            }
        }
    }
}
