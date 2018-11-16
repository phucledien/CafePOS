//
//  OrderTableViewCell.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 11/19/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var lblPayment: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
