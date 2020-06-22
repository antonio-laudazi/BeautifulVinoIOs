//
//  FeedPostTableViewCell.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 24/11/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit

class FeedPostTableViewCell: UITableViewCell {
    @IBOutlet var headerView: HeaderView!
    @IBOutlet var labelTitoloFeed: UILabel!
    @IBOutlet var labelTestoFeed: UILabel!
    @IBOutlet var imageViewFeed: UIImageView!
    @IBOutlet var viewShadow: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async{
            self.viewShadow.setShadowAndCorners(corners: [.allCorners], x:0, y:0, offsetW: 0, offsetH: 0, cornerRadius: 10, colorBg: .bvRedPink)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(feed:Feed, tag:Int){
        headerView.setDataHeaderView(feed: feed, tag: tag)
        self.labelTitoloFeed.text=feed.titoloFeed
        if feed.tipoFeed == Feed.TipoFeed.post.rawValue {
            var htmlstring=htmlTextStyleFeedPost
            if feed.testoFeed != nil {
                htmlstring.append(feed.testoFeed)
            }
            self.labelTestoFeed.attributedText=htmlstring.htmlToAttributedString
        }else{
           self.labelTestoFeed.text=feed.testoFeed
        }
        
        headerView.labelHeader.textColor=UIColor.white
        headerView.labelSottoheader.textColor=UIColor.white
        headerView.backgroundColor = UIColor.clear
        self.imageViewFeed.setCornersSmall()
        self.imageViewFeed.image = UIImage(named: "placeholder")
        self.imageViewFeed.imageFromServerURL(urlString: feed.urlImmagineFeed, imagePlaceholder: UIImage(named: "placeholder")!, completionBlock: {_ in})
    }
}


