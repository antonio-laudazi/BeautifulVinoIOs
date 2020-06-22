//
//  VinoTableViewCell.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 27/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit

class VinoTableViewCell: UITableViewCell {
    
    @IBOutlet var labelNomeVino: UILabel!
    @IBOutlet var labelInBreve: UILabel!
    @IBOutlet var labelUvaggio: UILabel!
    @IBOutlet var imageViewVino: UIImageView!
    @IBOutlet var viewShadowVino: UIView!
    @IBOutlet var viewBg: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.viewShadowVino.setShadowAndCorners(corners: [], x:0, y:0, offsetW: 0, offsetH: -20, cornerRadius: 0, colorBg: .white)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if !self.isSelected {
            self.viewBg.backgroundColor=UIColor.clear
        }else{
            self.viewBg.backgroundColor=UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        }
    }
    
    func setData(vino:Vino){
        self.imageViewVino.layer.borderWidth = 2
        self.imageViewVino.layer.borderColor = UIColor(red: 219.0/255.0, green: 219.0/255.0, blue: 219.0/255.0, alpha: 1).cgColor
        self.labelNomeVino.text=vino.nomeVino
        self.labelInBreve.text=vino.inBreveVino
        self.labelUvaggio.text=vino.uvaggioVino
        self.imageViewVino.layer.cornerRadius = self.imageViewVino.frame.size.width / 2
        self.imageViewVino.clipsToBounds = true
        self.imageViewVino.imageFromServerURL(urlString: vino.urlLogoVino, imagePlaceholder: UIImage(named: "placeholder")!, completionBlock: {_ in})
    }
}
