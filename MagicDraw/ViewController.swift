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
        ScreenSize.width = 320
        ScreenSize.height = 1136*0.5
        
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
        
        
        dismissViewControllerAnimated(true, completion: {
            let  image = info[UIImagePickerControllerOriginalImage] as UIImage
            
            // let image = info[UIImagePickerControllerEditedImage] as UIImage
            
            self.postImageToParse(image)
        })
        
        ///
        

    }

    func postImageToParse(image: UIImage) {
        
        // image is too large
        
        ImageSize.width = image.size.width
        ImageSize.height = image.size.height
        // Get
        let width = ImageSize.width
        println("My image view state:\(width)")
        // Get
        let height = ImageSize.height
        println("My image view state:\(height)")
        
        
        
        let imageData = UIImageJPEGRepresentation(image, 0.5)
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
        
        var params = ["objecturl": objecturl]
        // var params = ["objecturl": "http://files.parsetfss.com/acbc822b-b4c4-4b64-9e34-aa2001e5b251/tfss-bd76f5d5-c3a1-49cb-af51-1ccf9d8ee5e5-image.jpg"]
        
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
                                    var ratio = ScreenSize.width/ImageSize.width
                                    var txx:CGFloat = 0.0
                                    var txy:CGFloat = 0.0
                                    var txw:CGFloat = 0.0
                                    var txz:CGFloat = 0.0
                                    
									if let tc = tx["textCoordinates"] as? NSArray{
										println("x \(tc[0]) y \(tc[1]) width \(tc[2]) height \(tc[3])")
										//tc[0]=xpos
										//tc[1]=ypos
                                        txx = tc[0] as CGFloat
                                        txy = tc[1] as CGFloat
                                        txw = tc[2] as CGFloat
                                        txz = tc[3] as CGFloat
									}
									if let tstring = tx["textString"] as? NSString{
										println("text \(tstring)" )
										//tstring= the detected text
									}
									if let tid = tx["id"] as? NSNumber{
										//tid = the id
										println("id \(tid)")
									}
                                    
                                    
                                    var newMagicSubview = MagicSubView(frame: CGRectMake(txx*ratio, txy*ratio, (txw-txx)*ratio, (txz-txy)*ratio))
                                    
                                    
                                    
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

