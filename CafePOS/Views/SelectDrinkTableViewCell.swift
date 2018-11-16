//
//  SelectDrinkTableViewCell.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 11/18/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import UIKit
import BEMCheckBox
import RxSwift

class SelectDrinkTableViewCell: UITableViewCell {
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var btnPlus: UIButton!

    var bag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkBox.tintColor = #colorLiteral(red: 0.942977488, green: 0.4194691777, blue: 0.5093488097, alpha: 1)
        checkBox.onTintColor = #colorLiteral(red: 0.942977488, green: 0.4194691777, blue: 0.5093488097, alpha: 1)
        checkBox.onCheckColor = #colorLiteral(red: 0.942977488, green: 0.4194691777, blue: 0.5093488097, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
