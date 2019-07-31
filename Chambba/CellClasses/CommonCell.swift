//
//  CommonCell.swift
//  Chambba
//
//  Created by Mayur chaudhary on 29/01/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import UIKit

class CommonCell: UITableViewCell {

    @IBOutlet weak var passwordShowBtn: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var staticImg: UIImageView!
    @IBOutlet weak var mainView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
