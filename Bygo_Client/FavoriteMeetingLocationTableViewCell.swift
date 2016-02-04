//
//  FavoriteMeetingLocationTableViewCell.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import MapKit

class FavoriteMeetingLocationTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
