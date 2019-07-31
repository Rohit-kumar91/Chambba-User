//
//  YourTripsCell.swift
//  Chambba
//
//  Created by Rohit Kumar on 26/02/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit

class YourTripsCell: UITableViewCell {
    
    
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
