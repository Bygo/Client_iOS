//
//  ListingImageCollectionViewCell.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 21/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class ListingImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    
    override func prepareForReuse() {
        imageView.image = nil
    }
}
