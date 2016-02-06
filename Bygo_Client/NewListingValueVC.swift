//
//  NewListingValue.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class NewListingValueVC: UIViewController {
    
    @IBOutlet var instructionLabel:UILabel!
    @IBOutlet var itemValueLabel:UILabel!
    @IBOutlet var currencyLabel:UILabel!
    @IBOutlet var itemValueTextField:UITextField!
    @IBOutlet var continueButton:UIButton!
    
    var model:Model?
    var listingName:String?
    var listingDepartment:Department?
    var listingCategory:Category?
    var listingImages:[UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        itemValueTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        continueButton.enabled = isDataValid()
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
    func textFieldDidChange(sender:AnyObject) {
        continueButton.enabled = isDataValid()
    }
    
    // MARK: - UIActions
    @IBAction func continueButtonTapped(sender:AnyObject) {
        if isDataValid() {
            itemValueTextField.resignFirstResponder()
            performSegueWithIdentifier("ShowSetRentalRates", sender: nil)
        }
    }
    
    @IBAction func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(view)
        if abs(translation.y) > abs(translation.x) && translation.y > 0.0 {
            itemValueTextField.resignFirstResponder()
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
