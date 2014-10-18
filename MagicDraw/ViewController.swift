//
//  ViewController.swift
//  MagicDraw
//
//  Created by yiqin on 10/17/14.
//  Copyright (c) 2014 yiqin. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set
        ScreenSize.width = 500
        ScreenSize.height = 800
        
        // Get
        let width = ScreenSize.width
        println("My view state:\(width)")
        
        
        
        
        // textRecognition()
        
        
        
    }

    @IBAction func addImage(sender: AnyObject) {
        println("Add the image")
        
    }
    
    
    func textRecognition() {
        let URL=NSURL(string: "https://imagevision-text-search-v1.p.mashape.com/textSearch/detectText")
        
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = ["X-Mashape-Key": "xiL7zSTisvmshlzqU2b8HimW98NFp1MvblHjsnGVIXnFab2CzB",
            "Content-Type": "application/x-www-form-urlencoded"]
        
        var params = [
            "objecturl": "http://files.parsetfss.com/acbc822b-b4c4-4b64-9e34-aa2001e5b251/tfss-422ec0e5-21cd-430f-9e4b-aa02142e4efa-IMG_1097.JPG"
        ]
        
        let manager = Alamofire.Manager.sharedInstance // or create a new one
        let request = Alamofire.request(.POST, URL, parameters: params, encoding: .JSON)
        request.responseString { (request, response, string, error) in
            // ...
            
            if let result = string {
                println(result)
                // process result
            } else if let theError = error {
                println(theError.localizedDescription)
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}

