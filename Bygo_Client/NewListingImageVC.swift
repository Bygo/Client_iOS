//
//  NewListingImageVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 15/3/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class NewListingImageVC: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var model:Model?
    var selectedImage:UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        delegate = self
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func viewDidAppear(animated: Bool) {
        view.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        selectedImage = image
        performSegueWithIdentifier("ListingTypeSegue", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        print("Prep")
        if segue.identifier == "ListingTypeSegue" {
            guard let destVC = segue.destinationViewController as? NewListingTypeVC else { return }
            // guard let destVC = navVC.topViewController as? NewListingTypeVC else { return }
            
            print(model)
            
            destVC.parentVC = self
            destVC.model = model
            destVC.image = selectedImage
        }
    }
}
