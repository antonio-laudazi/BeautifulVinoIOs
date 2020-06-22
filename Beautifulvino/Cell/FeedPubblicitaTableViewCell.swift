//
//  FeedTestoTableViewCell.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 20/11/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit

class FeedPubblicitaTableViewCell: UITableViewCell {
    
    @IBOutlet var labelTestoLabelFeed: UILabel!
    @IBOutlet var labelTitoloFeed: UILabel!
    @IBOutlet var imageViewFeed: UIImageView!
    @IBOutlet var viewShadow: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.viewShadow.setShadowAndCorners(corners: [.allCorners], x:0, y:0, offsetW: 0, offsetH: 0, cornerRadius: 10, colorBg: .white)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(feed:Feed){
        labelTestoLabelFeed.layer.cornerRadius = 12.0
        labelTestoLabelFeed.clipsToBounds = true
        self.labelTestoLabelFeed.text=feed.testoLabelFeed
        self.labelTitoloFeed.text=feed.titoloFeed
        self.imageViewFeed.setCornersBig()
        self.imageViewFeed.image = UIImage(named: "placeholder")
        self.imageViewFeed.imageFromServerURL(urlString: feed.urlImmagineFeed, imagePlaceholder: UIImage(named: "placeholder")!, completionBlock: {_ in })
    }
    
}
