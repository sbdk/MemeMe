//
//  Meme.swift
//  MemeMe
//
//  Created by Li Yin on 11/18/15.
//  Copyright © 2015 Li Yin. All rights reserved.
//

import Foundation
import UIKit

class Meme: NSObject, NSCoding {
    
    var topText: String = ""
    var bottomText: String = ""
    var pickedImage: UIImage? = nil
    var memedImage: UIImage? = nil
    //var creatTime: String = ""
    
    init(topText: String, bottomText: String, pickedImage: UIImage, memedImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.pickedImage = pickedImage
        self.memedImage = memedImage
    }
    
    required init(coder unarchiver: NSCoder) {
        super.init()
        
        // Unarchive the data, one property at a time
        topText = unarchiver.decodeObjectForKey("TopText") as! String
        bottomText = unarchiver.decodeObjectForKey("BottomText") as! String
        pickedImage = unarchiver.decodeObjectForKey("PickedImage") as? UIImage
        memedImage = unarchiver.decodeObjectForKey("MemedImage") as? UIImage
        
    }
    
    
    func encodeWithCoder(archiver: NSCoder) {
        
        // archive the information inside the Person, one property at a time
        archiver.encodeObject(topText, forKey: "TopText")
        archiver.encodeObject(bottomText, forKey: "BottomText")
        archiver.encodeObject(pickedImage, forKey: "PickedImage")
        archiver.encodeObject(memedImage, forKey: "MemedImage")
    }
}