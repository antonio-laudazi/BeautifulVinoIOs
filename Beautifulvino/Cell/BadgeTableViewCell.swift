//
//  BadgeTableViewCell.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 27/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit

class BadgeTableViewCell: UITableViewCell {
    
    @IBOutlet var labelNomeBadge: UILabel!;
    @IBOutlet var labelNomeCenteredBadge: UILabel!;
    @IBOutlet var labelInfoBadge: UILabel!;
    @IBOutlet var imageViewLogoBadge: UIImageView!;
    @IBOutlet var viewOpacityBadge: UIView!;

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(badge:Badge){
        if badge.infoBadge==nil || badge.infoBadge=="" {
            self.labelNomeBadge.isHidden=true
            self.labelInfoBadge.isHidden=true
            self.labelNomeCenteredBadge.isHidden=false
            self.labelNomeCenteredBadge.text=badge.nomeBadge
        }else{
            self.labelNomeBadge.isHidden=false
            self.labelInfoBadge.isHidden=false
            self.labelNomeCenteredBadge.isHidden=true
            self.labelNomeBadge.text=badge.nomeBadge
            self.labelInfoBadge.text=badge.infoBadge
        }
        self.imageViewLogoBadge.imageFromServerURL(urlString: badge.urlLogoBadge, imagePlaceholder: UIImage(named: "placeholder")!, completionBlock: {_ in })
    }
    
}
