//
//  ViewController.swift
//  MagicDraw
//
//  Created by yiqin on 10/17/14.
//  Copyright (c) 2014 yiqin. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    var magicSubviews:[MagicSubView] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set
        ScreenSize.width = 500
        ScreenSize.height = 800
        
        // Get
        let width = ScreenSize.width
        println("My view state:\(width)")
    }

    @IBAction func addImage(sender: AnyObject) {
        println("Add the image")
        
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            imagePicker.sourceType = .Camera
        } else {
            imagePicker.sourceType = .PhotoLibrary
        }
        
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as UIImage
        
        postImageToParse(image)
        
        dismissViewControllerAnimated(true, completion: {
            
        })
    }

    func postImageToParse(image: UIImage) {
        
        // image is too large
        let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        
        ImageSize.width = scaledImage.size.width
        
        
        let imageData = UIImageJPEGRepresentation(scaledImage, 0.5)
        let imageFile = PFFile(name:"image.jpg", data: imageData)
        
        var sketchPhoto = PFObject(className: "SketchPhoto")
        sketchPhoto["imageName"] = "Testing BoilerMake"
        sketchPhoto["imageFile"] = imageFile
        sketchPhoto.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                println("Congratulations")
                
                let newSavedImageFile = sketchPhoto["imageFile"] as PFFile
                let url  = newSavedImageFile.url
                println("\(url)")
                
                self.textRecognition(url)
            }
            else {
                println("Oh, something is wrong.")
            }
        }
    }
    
    func textRecognition(objecturl:String) {
        let mashapeURL=NSURL(string: "https://imagevision-text-search-v1.p.mashape.com/textSearch/detectText")
        
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = ["X-Mashape-Key": "xiL7zSTisvmshlzqU2b8HimW98NFp1MvblHjsnGVIXnFab2CzB",
            "Content-Type": "application/x-www-form-urlencoded"]
        
        var params = [
            "objecturl": objecturl
        ]
        
        let manager = Alamofire.Manager.sharedInstance // or create a new one
        let request = Alamofire.request(.POST, mashapeURL, parameters: params, encoding: .JSON)
        request.responseString { (request, response, string, error) in
            if let result = string {
                println(result)
                // process result
				var jsonError: NSError?
				println ("Parsing result")
				let data = result.dataUsingEncoding(NSUTF8StringEncoding)
				if let json = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &jsonError) as? NSDictionary {
					if let detected=json["textDetected"] as? Bool{
						if detected==true {
							println("detected text")
							if let text = json["text"] as? NSArray {
							
								for tx in text{ //for each detected text
									println("NEW TEXT----------------")
									if let tc = tx["textCoordinates"] as? NSArray{
										println("x \(tc[0]) y \(tc[1])")
										//tc[0]=xpos
										//tc[1]=ypos
									}
									if let tstring = tx["textString"] as? NSString{
										println("text \(tstring)" )
										//tstring= the detected text
									}
									if let tid = tx["id"] as? NSNumber{
										//tid = the id
										println("id \(tid)")
									}
                                    var newMagicSubview = MagicSubView(frame: CGRectMake(0, 0, 100, 100))
									self.view.addSubview(newMagicSubview)
								}
							}
						}
					}
					
					
				} else {
					if let unwrappedError = jsonError {//no json
						println("json error: \(unwrappedError)")
						print(result)
					}
				}

                
                
                
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

