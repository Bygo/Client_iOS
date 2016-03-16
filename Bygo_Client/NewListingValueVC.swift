//
//  NewListingValue.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class NewListingValueVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var instructionLabel:UILabel!
    @IBOutlet var detailedLabel: UILabel!
    @IBOutlet var itemValueLabel:UILabel!
    @IBOutlet var currencyLabel:UILabel!
    @IBOutlet var itemValueTextField:UITextField!
    @IBOutlet var nextButton: UIBarButtonItem!
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var valueView: UIView!
    
    
    var model:Model?
    var listingName:String?
    var listingDepartment:Department?
    var listingCategory:Category?
    var listingImages:[UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        itemValueTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        nextButton.enabled = isDataValid()
        
        instructionLabel.text = "5. In total, how valuable are the items included in this Listing?"
        
        detailedLabel.text = "The Listing value will be used to calculate suggested rental rates. Currently, Listings are limited to values of $1000 or less."
        
        itemValueTextField.becomeFirstResponder()
        
        itemValueTextField.tintColor = kCOLOR_ONE
        
        view.backgroundColor = kCOLOR_THREE
        headerView.backgroundColor = .whiteColor()
        valueView.backgroundColor = .whiteColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        navigationController?.navigationItem.backBarButtonItem?.title = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Data
    func isDataValid() -> Bool {
        return itemValueTextField.text?.characters.count > 0
    }
    
    
    // MARK: - TextField Delegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == itemValueTextField {
            if let text = textField.text {
                let newString = (text as NSString).stringByReplacingCharactersInRange(range, withString: string)
                
                let components = newString.componentsSeparatedByString(".")
                
                // If the user is adding an extra decimal point, don't allow the change
                if components.count > 2 {
                    return false
                }
                
                // If the user is trying to specify a monetary value with greater than one cent precision, don't allow their text to be entered
                if components.count == 2 {
                    let cents = components[1]
                    if cents.characters.count > 2 {
                        return false
                    }
                }
                
                // If the value will be greater than 1000, don't allow the user to enter in a value
                let v = NSString(string: newString).doubleValue
                if v > 1000 { return false }
            }
        }
        return true
    }
    
    func textFieldDidChange(sender:AnyObject) {
        nextButton.enabled = isDataValid()
    }
    
    // MARK: - UI Actions
    @IBAction func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(view)
        if abs(translation.y) > abs(translation.x) && translation.y > 0.0 {
            itemValueTextField.resignFirstResponder()
        }
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        if isDataValid() {
            itemValueTextField.resignFirstResponder()
            performSegueWithIdentifier("ShowSetRentalRates", sender: nil)
        }
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowSetRentalRates" {
            guard let destVC = segue.destinationViewController as? NewListingRentalRatesVC else { return }
            destVC.model                = model
            destVC.listingName          = listingName
            destVC.listingDepartment    = listingDepartment
            destVC.listingCategory      = listingCategory
            destVC.listingImages        = listingImages
            destVC.listingValue         = Double(NSString(string: itemValueTextField!.text!).floatValue)
        }
    }
}
