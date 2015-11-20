//
//  File.swift
//  MemeMe
//
//  Created by Li Yin on 11/19/15.
//  Copyright © 2015 Li Yin. All rights reserved.
//

import Foundation
import UIKit

class MemeDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var meme: Meme!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.imageView.image = meme.memedImage
        self.label.text = meme.creatTime
        
    }
}
