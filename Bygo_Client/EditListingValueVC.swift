//
//  EditListingValueVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class EditListingValueVC: UIViewController {
    
    @IBOutlet var instructionLabel:UILabel!
    @IBOutlet var itemValueLabel:UILabel!
    @IBOutlet var currencyLabel:UILabel!
    @IBOutlet var itemValueTextField:UITextField!
    @IBOutlet var continueButton:UIButton!
    
    var model:Model?
    var delegate:EditListingValueDelegate?
    var listing:Listing?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        itemValueTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        continueButton.enabled = isDataValid()
        
        guard let totalValue = listing?.totalValue.value else { return }
        let valueString = String(format: "%.2f", totalValue)
        itemValueTextField.placeholder = valueString
        itemValueTextField.text = valueString
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
            
            let totalValue = NSString(string: itemValueTextField.text!).doubleValue
            
            guard let listingID         = listing?.listingID            else { return }
            guard let name              = listing?.name                 else { return }
            guard let categoryID        = listing?.categoryID           else { return }
            guard let hourlyRate        = listing?.hourlyRate.value     else { return }
            guard let dailyRate         = listing?.dailyRate.value      else { return }
            guard let weeklyRate        = listing?.weeklyRate.value     else { return }
            guard let itemDescription   = listing?.itemDescription      else { return }
            
            model?.listingServiceProvider.updateListing(listingID, name: name, categoryID: categoryID, totalValue: totalValue, hourlyRate: hourlyRate, dailyRate: dailyRate, weeklyRate: weeklyRate, itemDescription: itemDescription, completionHandler: {
                (success:Bool) in
                if success {
                    self.delegate?.didUpdateValue()
                    self.navigationController?.popToRootViewControllerAnimated(true)
                } else {
                    print("Error updating the Listing")
                }
            })
        }
    }
    
    @IBAction func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(view)
        if abs(translation.y) > abs(translation.x) && translation.y > 0.0 {
            itemValueTextField.resignFirstResponder()
        }
    }
}


protocol EditListingValueDelegate {
    func didUpdateValue()
}
