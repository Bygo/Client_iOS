//
//  HomeVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 5/3/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
    
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var searchBar: SearchBar!
    
    var delegate:HomeDelegate?
    var model:Model?


    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - UI Actions
    @IBAction func panGestureRecognized(sender: AnyObject) {
        searchBar.resignFirstResponder()
    }
    
    
    @IBAction func menuButtonTapped(sender: AnyObject) {
        delegate?.openMenu()
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



