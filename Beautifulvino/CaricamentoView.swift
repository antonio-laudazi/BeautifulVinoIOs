//
//  CaricamentoView.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 27/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit

class CaricamentoView: UIView {
    
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    
    class func instanceFromNib() -> CaricamentoView {
        return UINib(nibName: "CaricamentoView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CaricamentoView
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
