//
//  FeedAzioneTableViewCell.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 24/11/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit

class FeedAzioneTableViewCell: UITableViewCell {
    @IBOutlet var headerView: HeaderView!
    @IBOutlet var labelTitoloFeed: UILabel!
    @IBOutlet var labelNomeFeed: UILabel!
    @IBOutlet var labelAzienda: UILabel!
    @IBOutlet var labelTemaInfo: UILabel!
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
    
    func setData(feed:Feed, tag: Int){
        headerView.setDataHeaderView(feed: feed, tag: tag)
        self.labelTitoloFeed.text=feed.titoloFeed
        
        if feed.tipoFeed==Feed.TipoFeed.evento.rawValue {
            self.labelNomeFeed.text=feed.eventoFeedInt.titoloEvento
            self.labelAzienda.isHidden=true
            self.labelTemaInfo.text=feed.eventoFeedInt.temaEvento
            self.imageViewFeed.image = UIImage(named: "placeholder")
            self.imageViewFeed.imageFromServerURL(urlString: feed.eventoFeedInt.urlFotoEvento, imagePlaceholder: UIImage(named: "placeholder")!, completionBlock: {_ in })
        }else{
            self.labelNomeFeed.text=feed.vinoFeedInt.nomeVino
            self.labelAzienda.isHidden=false
            self.labelAzienda.text=feed.vinoFeedInt.aziendaVino.nomeAzienda
            self.labelTemaInfo.text=feed.vinoFeedInt.infoVino
            self.imageViewFeed.image = UIImage(named: "placeholder")
            self.imageViewFeed.imageFromServerURL(urlString: feed.vinoFeedInt.urlLogoVino, imagePlaceholder: UIImage(named: "placeholder")!, completionBlock: {_ in })
        }
    }
}

