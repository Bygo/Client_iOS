//
//  NewListingVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/3/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class NewListingVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker: UIImagePickerController = UIImagePickerController()

    @IBOutlet var headerView: UIView!
    @IBOutlet var footerView: UIView!
    
    @IBOutlet var captureButton: UIButton!
    @IBOutlet var hideButton: UIButton!
    
    var hasAppeared = false
    
//    @IBOutlet var questionLabel: UILabel!
//    @IBOutlet var featuredImageLabel: UILabel!

//    @IBOutlet var croppingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            imagePicker.sourceType     = .Camera
            imagePicker.cameraDevice   = UIImagePickerControllerCameraDevice.Rear
            imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
            imagePicker.delegate       = self
            imagePicker.allowsEditing  = false
            imagePicker.modalTransitionStyle = .CrossDissolve
            imagePicker.showsCameraControls = false
            
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            imagePicker.sourceType     = .PhotoLibrary
            imagePicker.delegate       = self
            imagePicker.allowsEditing  = false
            imagePicker.modalTransitionStyle = .CrossDissolve
            presentViewController(imagePicker, animated: false, completion: nil)
        }
        imagePicker.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        if !hasAppeared {
            presentViewController(imagePicker, animated: false, completion: nil)
            configureFooterView()
        }
        hasAppeared = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func configureHeaderView() {
        headerView = UIView(frame: CGRectMake(0,0,imagePicker.view.bounds.width,80))
        headerView.backgroundColor = .blackColor()
        imagePicker.view.addSubview(headerView)
        
        let label1 = UILabel()
        label1.numberOfLines = 0
        label1.text = "What are you listing?"
        label1.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
        label1.textAlignment = .Center
        label1.sizeToFit()
        let w1 = label1.bounds.width
        let h1 = label1.bounds.height
        let vw = view.bounds.width
        label1.frame = CGRectMake((vw/2.0)-(w1/2.0), 16.0, w1, h1)
        label1.textColor = .whiteColor()
        
        headerView.addSubview(label1)
        
        
        let label2 = UILabel()
        label2.numberOfLines = 0
        label2.text = "This is your featured image. Make it a good one!"
        label2.font = UIFont.systemFontOfSize(12.0, weight: UIFontWeightMedium)
        label2.textAlignment = .Center
        label2.sizeToFit()
        let w2 = label2.bounds.width
        let h2 = label2.bounds.height
        label2.frame = CGRectMake((vw/2.0)-(w2/2.0), 16.0+h1, w2, h2)
        label2.textColor = .whiteColor()
        label2.alpha = 0.75
        headerView.addSubview(label2)
        
        headerView.frame = CGRectMake(0, 0, view.bounds.width, 16.0+h1+4.0+h2+16.0)
        
        imagePicker.view.layoutIfNeeded()
        
    }
    
    func configureFooterView() {
        let height:CGFloat = 200.0

        footerView = UIView(frame: CGRectMake(0, view.bounds.height-height, view.bounds.width, height))
        footerView.backgroundColor = kCOLOR_ONE
        imagePicker.view.addSubview(footerView)
        
        let label1 = UILabel()
        label1.numberOfLines = 0
        label1.text = "What are you listing?"
        label1.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
        label1.textAlignment = .Center
        label1.sizeToFit()
        let w1 = label1.bounds.width
        let h1 = label1.bounds.height
        let vw = view.bounds.width
        let vh = footerView.bounds.height
        label1.frame = CGRectMake((vw/2.0)-(w1/2.0), 12.0, w1, h1)
        label1.textColor = .whiteColor()
        
        footerView.addSubview(label1)
        
        
        let label2 = UILabel()
        label2.numberOfLines = 0
        label2.text = "This is your featured image. Make it a good one!"
        label2.font = UIFont.systemFontOfSize(12.0, weight: UIFontWeightMedium)
        label2.textAlignment = .Center
        label2.sizeToFit()
        let w2 = label2.bounds.width
        let h2 = label2.bounds.height
        label2.frame = CGRectMake((vw/2.0)-(w2/2.0), 16.0+h1+4.0, w2, h2)
        label2.textColor = .whiteColor()
        label2.alpha = 0.75
        footerView.addSubview(label2)
        
        let bottomOffset:CGFloat = 24.0
        
        let cancelButton = UIButton()
        cancelButton.titleLabel?.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
        cancelButton.titleLabel?.textColor = .whiteColor()
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.frame = CGRectMake(16.0, (vh)-bottomOffset-60.0, 60.0, 60.0)
        cancelButton.addTarget(self, action: #selector(NewListingVC.cancelButtonTapped(_:)), forControlEvents: .TouchUpInside)
        footerView.addSubview(cancelButton)
        
        let buttonWidth:CGFloat = 45.0
        let outlineWidth:CGFloat = 60.0
        
        let outlineOffset:CGFloat = (60.0-(buttonWidth/2.0))+((outlineWidth-buttonWidth)/2.0)
        
        let captureOutline = UIView(frame: CGRectMake((vw/2.0)-outlineWidth/2.0, vh-bottomOffset-outlineOffset-(bottomOffset*0.5), outlineWidth, outlineWidth))
        captureOutline.backgroundColor = .clearColor()
        captureOutline.layer.cornerRadius = (outlineWidth/2.0)-1.0
        captureOutline.layer.borderColor = UIColor.whiteColor().CGColor
        captureOutline.layer.borderWidth = 4.0
        footerView.addSubview(captureOutline)
        
//        let buttonOffset:CGFloat  = 60.0-(buttonWidth/2.0)
//        captureButton = UIButton(frame: CGRectMake((vw/2.0)-(buttonWidth/2.0), vh-bottomOffset-buttonOffset-(bottomOffset*0.5), buttonWidth, buttonWidth))
//        captureButton.tintColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
//        captureButton.backgroundColor = .whiteColor()
//        captureButton.layer.cornerRadius = (buttonWidth/2.0)
//        captureButton.addTarget(self, action: "captureButtonTapped:", forControlEvents: .TouchUpInside)
//        footerView.addSubview(captureButton)
        
        imagePicker.view.layoutIfNeeded()
    }
    
    func configureCroppingView() {
        
    }
    
    func configureCaptureButton() {
        captureButton = UIButton(frame: CGRectMake(view.bounds.width-16.0-80.0, view.bounds.height-20.0-80.0, 80.0, 80.0))
        captureButton.backgroundColor = .orangeColor()
        captureButton.setImage(UIImage(named: "Photos")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        captureButton.tintColor = .whiteColor()
        view.addSubview(captureButton)
        imagePicker.view.addSubview(captureButton)

    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
//        view.removeFromSuperview()
        let imageView = UIImageView(frame: CGRectMake(8.0, (view.bounds.height/2.0) - ((view.bounds.width-16.0)/2.0), view.bounds.width-16.0, view.bounds.width-16.0))
        imageView.image = image
        imageView.contentMode          = UIViewContentMode.ScaleAspectFill
        imageView.backgroundColor      = .lightGrayColor()
        imageView.clipsToBounds        = true
        imageView.layer.masksToBounds  = true
        imageView.layer.cornerRadius = kCORNER_RADIUS
        view.addSubview(imageView)
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        print("Finished picking image")
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        imagePicker.dismissViewControllerAnimated(true, completion: {
            self.dismissViewControllerAnimated(true, completion: {
                self.dismissViewControllerAnimated(false, completion: nil)
            })
        })
    }
    
    @IBAction func captureButtonTapped(sender: AnyObject) {
        imagePicker.takePicture()
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
