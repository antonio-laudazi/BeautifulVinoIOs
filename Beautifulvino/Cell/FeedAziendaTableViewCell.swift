//
//  FeedAziendaTableViewCell.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 19/12/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//


import UIKit

class FeedAziendaTableViewCell: UITableViewCell {
    @IBOutlet var labelTitoloFeed: UILabel!
    @IBOutlet var headerView: HeaderView!
    @IBOutlet var imageViewFeed: UIImageView!
    @IBOutlet var viewShadow: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async{
            self.viewShadow.setShadowAndCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight ], x:0, y:0, offsetW: 0, offsetH: 0, cornerRadius: 10, colorBg: .white)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(feed:Feed, tag:Int){
        headerView.setDataHeaderView(feed: feed, tag: tag)
        self.labelTitoloFeed.text=feed.titoloFeed
        self.imageViewFeed.image = UIImage(named: "placeholder")
        self.imageViewFeed.imageFromServerURL(urlString: feed.urlImmagineFeed, imagePlaceholder: UIImage(named: "placeholder")!, completionBlock: {_ in })
        imageViewFeed.setCornersSmall()
    }
    
    func setData(azienda:Azienda){
        headerView.setDataHeaderView(azienda:azienda)
        self.labelTitoloFeed.text=azienda.infoAzienda
        self.imageViewFeed.image = UIImage(named: "placeholder")
        self.imageViewFeed.imageFromServerURL(urlString: azienda.urlImmagineAzienda, imagePlaceholder: UIImage(named: "placeholder")!, completionBlock: {_ in })
        imageViewFeed.setCornersSmall()
    }
}


