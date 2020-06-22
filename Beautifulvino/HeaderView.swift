//
//  HeaderView.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 23/11/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit

class HeaderView: UIView {
    
    @IBOutlet var labelHeader: UILabel!
    @IBOutlet var contentView: UIView!
    @IBOutlet var labelSottoheader: UILabel!
    @IBOutlet var imageViewSmall: UIImageView!
    
    /* class func instanceFromNib() -> HeaderView {
     return UINib(nibName: "HeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! HeaderView
     }*/
    
    func setDataHeaderView(feed:Feed, tag:Int){
        self.labelHeader.text=feed.headerFeed
        self.labelSottoheader.text=feed.sottoHeaderFeed
        self.imageViewSmall.imageFromServerURL(urlString: feed.urlImmagineHeaderFeed, imagePlaceholder: UIImage(named: "placeholder")!, completionBlock: {_ in })
        self.contentView.tag=tag
        self.imageViewSmall.setImageRounded()
    }
    
    func setDataHeaderView(azienda:Azienda){
        self.labelHeader.text=azienda.nomeAzienda
        var cittaAz=""
        var regioneAz=""
        if azienda.cittaAzienda != nil{
            cittaAz=azienda.cittaAzienda
        }
        if azienda.regioneAzienda != nil{
            regioneAz=azienda.regioneAzienda
        }
        self.labelSottoheader.text="\(cittaAz.uppercased()) - \(regioneAz.uppercased())"
        self.imageViewSmall.imageFromServerURL(urlString: azienda.urlLogoAzienda, imagePlaceholder: UIImage(named: "placeholder")!, completionBlock: {_ in})
        self.imageViewSmall.setImageRounded()
    }
    
    override init(frame:CGRect){
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    private func commonInit(){
        Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame=self.bounds
        contentView.autoresizingMask=[.flexibleWidth, .flexibleHeight]
    }
}
