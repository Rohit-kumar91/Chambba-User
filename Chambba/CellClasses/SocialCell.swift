//
//  SocialCell.swift
//  Chambba
//
//  Created by Rohit Kumar on 28/02/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit

class SocialCell: UITableViewCell {

    
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var socialLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
