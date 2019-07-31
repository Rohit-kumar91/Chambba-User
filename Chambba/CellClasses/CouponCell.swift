//
//  CouponCell.swift
//  Chambba
//
//  Created by Rohit Kumar on 26/02/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit

class CouponCell: UITableViewCell {
    
    
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var expireLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
