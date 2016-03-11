//
//  Meme.swift
//  MemeMe
//
//  Created by Li Yin on 11/18/15.
//  Copyright © 2015 Li Yin. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Meme: NSManagedObject {
    
    @NSManaged var topText: String
    @NSManaged var bottomText: String
    @NSManaged var pickedImage: UIImage?
    @NSManaged var memedImage: UIImage?
    @NSManaged var generateTime: NSDate
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(topTextInput: String, bottomTextInput: String, pickedImageFile: UIImage, memedImageFile: UIImage, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Meme", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        topText = topTextInput
        bottomText = bottomTextInput
        pickedImage = pickedImageFile
        memedImage = memedImageFile
        
        generateTime = NSDate()
    }
    
}