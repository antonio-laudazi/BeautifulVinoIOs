//
//  TableSectionFooterVino.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 09/01/18.
//  Copyright © 2018 Maria Tourbanova. All rights reserved.
//

import UIKit

class TableSectionFooterVino: UITableViewHeaderFooterView {
    
    @IBOutlet var viewShadow: UIView!
    @IBOutlet var labelMostraAltri: UILabel!
    @IBOutlet var viewLine: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.viewShadow.setShadowAndCorners(corners: [.bottomRight, .bottomLeft], x:0, y:20, offsetW: 0, offsetH: -20, cornerRadius: 10, colorBg: .white)
        }
    }
}
