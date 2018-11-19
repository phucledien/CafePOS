//
//  Reactive+Extension.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 11/18/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import BEMCheckBox

extension Reactive where Base: BEMCheckBox {
    
    /// Reactive wrapper for `TouchUpInside` control event.
    var tap: ControlEvent<Void> {
        return controlEvent(.allEvents)
    }
}
