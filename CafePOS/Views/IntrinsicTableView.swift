//
//  IntrinsicTableView.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 11/19/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import UIKit

class IntrinsicTableView: UITableView {
    
    override var contentSize:CGSize {
        
        didSet {
            
            self.invalidateIntrinsicContentSize()
            
        }
        
    }
    
    override var intrinsicContentSize: CGSize {
        
        self.layoutIfNeeded()
        
        return CGSize(width: UIViewNoIntrinsicMetric, height: contentSize.height)
        
    }
    
}
