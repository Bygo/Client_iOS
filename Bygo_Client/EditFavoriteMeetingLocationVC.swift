//
//  EditFavoriteMeetingLocationVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 3/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import MapKit

class EditFavoriteMeetingLocationVC: UIViewController, UITextFieldDelegate {
    
    var location:FavoriteMeetingLocation?
    var model:Model?
    var delegate:EditFavoriteMeetingLocationDelegate?
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var addressDetailLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Design
        navigationController?.navigationBar.barTintColor    = kCOLOR_ONE
        navigationController?.navigationBar.translucent     = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        
        // Do any additional setup after loading the view.
        saveButton.enabled = false
        view.backgroundColor = kCOLOR_THREE
        
        guard let location = location else { return }
        nameTextField.text = location.name
        
        let addressComponents = location.address?.componentsSeparatedByString(", ")
        guard let address = addressComponents?.joinWithSeparator("\n") else { return }
        addressDetailLabel.text = address
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        saveButton.enabled = true
    }
    
    
    // MARK: - UI Actions
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        guard let locationID  = location?.locationID    else { return }
        guard let name        = nameTextField.text      else { return }
        guard let address     = location?.address       else { return }
        guard let isPrivate   = location?.isPrivate     else { return }
        if name.characters.count < 1 { return }
        
        self.model?.favoriteMeetingLocationServiceProvider.updateFavoriteMeetingLocation(locationID, name: name, address: address, isPrivate: isPrivate, completionHandler: { (success:Bool)->Void in
            if success {
                self.dismissViewControllerAnimated(true, completion: {
                    self.delegate?.didUpdateFavoriteMeetingLocation()
                })
            } else {
                print("Error trying to update favorite meeting location")
            }
        })
    }
    
    @IBAction func deleteButtonTapped(sender: AnyObject) {
        guard let locationID = location?.locationID else { return }
        model?.favoriteMeetingLocationServiceProvider.deleteFavoriteMeetingLocation(locationID, completionHandler:{
            (success:Bool)->Void in
            if success {
                self.dismissViewControllerAnimated(true, completion: {
                    self.delegate?.didDeleteFavoriteMeetingLocation()
                })
            } else {
                print("Error while trying to delete location")
            }
        })
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}


protocol EditFavoriteMeetingLocationDelegate {
    func didUpdateFavoriteMeetingLocation()
    func didDeleteFavoriteMeetingLocation()
}
