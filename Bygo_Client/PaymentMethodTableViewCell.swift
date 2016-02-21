//
//  PaymentMethodTableViewCell.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 18/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class PaymentMethodTableViewCell: UITableViewCell {

    @IBOutlet var paymentMethodLabel: UILabel!
    @IBOutlet var isSelectedIndicatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
