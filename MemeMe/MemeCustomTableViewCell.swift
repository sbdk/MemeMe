//
//  MemeCustomTableViewCell.swift
//  MemeMe
//
//  Created by Li Yin on 11/20/15.
//  Copyright © 2015 Li Yin. All rights reserved.
//

import UIKit

class MemeCustomTableViewCell: UITableViewCell {

    @IBOutlet weak var tableCellImage: UIImageView!
    @IBOutlet weak var tableCellTopLabel: UILabel!
    @IBOutlet weak var tableCellBottomLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
