//
//  MagicSubview.swift
//  MagicDraw
//
//  Created by yiqin on 10/18/14.
//  Copyright (c) 2014 yiqin. All rights reserved.
//

import Foundation
import UIKit

class MagicSubView:UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.redColor()
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
