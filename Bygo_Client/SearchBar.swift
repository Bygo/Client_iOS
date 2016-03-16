//
//  SearchBar.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 27/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class SearchBar: UITextField {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        font = UIFont.systemFontOfSize(16.0)
        layer.cornerRadius  = frame.height/2.0 - 1.0
        backgroundColor     = .whiteColor()
        clearButtonMode     = UITextFieldViewMode.WhileEditing
        returnKeyType       = UIReturnKeyType.Search
        textColor           = .blackColor()
        tintColor           = kCOLOR_ONE
        placeholder         = "Search"
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 16.0, 0.0)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 16.0, 0.0)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
