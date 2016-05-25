//
//  HighScoreCell.swift
//  ColourMemory
//
//  Created by Jacky Tjoa on 15/5/16.
//  Copyright © 2016 Coolheart. All rights reserved.
//

import UIKit

class HighScoreCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var rankLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        nameLbl.textColor = UIColor.whiteColor()
        scoreLbl.textColor = UIColor.whiteColor()
        rankLbl.textColor = UIColor.whiteColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
