//
//  ViewContentProfiloF.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 25/01/18.
//  Copyright © 2018 Maria Tourbanova. All rights reserved.
//

import UIKit

class ViewContentProfiloF: UIView {
    
    @IBOutlet weak var labelNomeCognome:UILabel!
    @IBOutlet weak var labelLivello:UILabel!
    @IBOutlet weak var labelProssimoLivello:UILabel!
    @IBOutlet weak var imageViewFoto:UIImageView!
    @IBOutlet weak var buttonModifica:UIButton!
    @IBOutlet weak var buttonSegui:UIButton!

    class func instanceFromNib() -> ViewContentProfiloF {
        return UINib(nibName: "ViewContentProfiloF", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ViewContentProfiloF
    }
    
    func create(utente:Utente, mioProfilo:Bool){
        buttonSegui.addCornerRadius()
        self.imageViewFoto.layer.cornerRadius = self.imageViewFoto.frame.size.width / 2
        self.imageViewFoto.layer.borderWidth = 3
        self.imageViewFoto.layer.borderColor = UIColor.white.cgColor
        self.imageViewFoto.clipsToBounds = true
        if let nome = utente.usernameUtente {
            labelNomeCognome.text="\(nome)"
        }else{
            labelNomeCognome.text=" "
        }
        
        if let livelloPr = utente.puntiMancantiProssimoLivelloUtente{
            if mioProfilo{
                labelProssimoLivello.text="\(livelloPr)"
            }else{
                labelProssimoLivello.text=" "
            }
        }else{
            labelProssimoLivello.text=" "
        }
        
        if let livello = utente.livelloUtente{
            labelLivello.text="livello: \(livello.uppercased())"
        }else{
            labelLivello.text=""
        }
        
        
        
        
        imageViewFoto.imageFromServerURL(urlString: utente.urlFotoUtente, imagePlaceholder: UIImage(named: "placeholderUser")!, completionBlock: {_ in})
    }

}
