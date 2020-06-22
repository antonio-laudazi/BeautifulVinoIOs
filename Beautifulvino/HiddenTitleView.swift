//
//  HiddenTitleView.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 08/01/18.
//  Copyright © 2018 Maria Tourbanova. All rights reserved.
//

import UIKit

class HiddenTitleView: UIView {
    
    @IBOutlet weak var labelTitle:UILabel?
    @IBOutlet weak var buttonChiudi:UIButton?

    class func instanceFromNib() -> HiddenTitleView {
        return UINib(nibName: "HiddenTitleView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! HiddenTitleView
    }
    
    func create(title: String, action: Selector){
        self.setShadow()
        self.labelTitle?.text=title
        self.buttonChiudi?.addTarget(nil,  action: action, for: .touchUpInside)
    }
}

