//
//  TableSectionHeaderAzienda.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 27/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit

class TableSectionHeaderAzienda: UITableViewHeaderFooterView {
    
    @IBOutlet var labelNomeAzienda: UILabel!
    @IBOutlet var viewShadow: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.viewShadow.setShadowAndCorners(corners:[.topRight, .topLeft], x:0, y:0, offsetW:0, offsetH:-20, cornerRadius:10, colorBg: .white)
        }
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
