//
//  EventiTableViewCell.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 26/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit

class EventoTableViewCell: UITableViewCell {
    
    @IBOutlet var labelDataEvento: UILabel!
    @IBOutlet var labelTitoloEvento: UILabel!
    @IBOutlet var labelCittaEvento: UILabel!
    @IBOutlet var labelTemaEvento: UILabel!
    @IBOutlet var labelPrezzoEvento: UILabel!
    @IBOutlet var imageViewSfondoEvento: UIImageView!
    @IBOutlet var imageViewPinEvento: UIImageView!
    @IBOutlet var viewShadowEvento: UIView!
    @IBOutlet var buttonPrenotatoEvento: UIButton!
    @IBOutlet var viewBg: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.viewShadowEvento.setShadowAndCorners(corners: [.allCorners], x:0, y:0, offsetW: 0, offsetH: 0, cornerRadius: 10, colorBg: .white)
            self.imageViewSfondoEvento.addBlackGradientLayer(frame: CGRect(x: 0, y: 0, width: self.imageViewSfondoEvento.frame.size.width, height: self.imageViewSfondoEvento.frame.size.height), colors: [ UIColor(red: 0, green: 0, blue: 0, alpha: 0.6), .clear, UIColor(red: 0, green: 0, blue: 0, alpha: 0.2), UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)])
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
       // self.layoutIfNeeded()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if !self.isSelected {
            self.viewBg.backgroundColor=UIColor.clear
        }else{
            self.viewBg.backgroundColor=UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        }
    }
    
    func setData(ev:Evento, tag:Int, prezzoHidden:Bool){
        self.buttonPrenotatoEvento.isEnabled=false
        self.labelTitoloEvento.text=ev.titoloEvento
        self.labelCittaEvento.text=ev.cittaEvento
        self.labelTemaEvento.text=ev.temaEvento
        self.labelDataEvento.text="\(ev.dataEvento.fromIntSince1970ToStringDate())"
        self.labelPrezzoEvento.text=ev.getPrezzoEvento()
        self.imageViewSfondoEvento.image = UIImage(named: "placeholder")

        if prezzoHidden && ev.statoEvento != Evento.StatoEvento.null.rawValue {
            self.labelPrezzoEvento.isHidden=true
            self.buttonPrenotatoEvento.isHidden=false
            
            self.buttonPrenotatoEvento.layer.cornerRadius = 12.2
            self.buttonPrenotatoEvento.layer.borderWidth = 2
            self.buttonPrenotatoEvento.layer.borderColor = UIColor.bvDandelion.cgColor
            self.buttonPrenotatoEvento.clipsToBounds = true
            
            
            if (ev.statoEvento==Evento.StatoEvento.prenotato.rawValue){
                self.buttonPrenotatoEvento.setTitle("PRENOTATO", for: .normal)
            } else{
                self.buttonPrenotatoEvento.setTitle("ACQUISTATO", for: .normal)
            }
        }else{
            self.labelPrezzoEvento.isHidden=false
            self.buttonPrenotatoEvento.isHidden=true
            labelPrezzoEvento.layer.cornerRadius = 12.0
            labelPrezzoEvento.clipsToBounds = true
        }
        if ev.imageEvento==nil{
            self.imageViewSfondoEvento.imageFromServerURL(urlString: ev.urlFotoEvento, imagePlaceholder: UIImage(named: "placeholder")!, completionBlock: {(data) in
                if data != nil{
                    ev.imageEvento=data
                }
            })
        }else{
            self.imageViewSfondoEvento.image=UIImage(data: ev.imageEvento)
        }
        self.viewBg.layer.cornerRadius=10.0
        self.imageViewSfondoEvento.setCornersSmall()
       
    }
}






