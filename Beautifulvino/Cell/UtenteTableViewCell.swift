//
//  UtenteTableViewCell.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 31/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit

class UtenteTableViewCell: UITableViewCell {

    @IBOutlet var labelNomeCognomeUtente: UILabel!;
    @IBOutlet var labelEsperienzaLivelloUtente: UILabel!;
    @IBOutlet var imageViewLogoUtente: UIImageView!;

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setData(utente:Utente){
        self.imageViewLogoUtente.layer.cornerRadius = self.imageViewLogoUtente.frame.size.width / 2
        self.imageViewLogoUtente.clipsToBounds = true
        self.labelNomeCognomeUtente.text="\(utente.usernameUtente!)"
        if let livello = utente.livelloUtente{
            self.labelEsperienzaLivelloUtente.text="livello: \(livello.uppercased())"
        }else{
            self.labelEsperienzaLivelloUtente.text=" "
        }
        self.imageViewLogoUtente.imageFromServerURL(urlString: utente.urlFotoUtente, imagePlaceholder: UIImage(named: "placeholderUser")!, completionBlock: {_ in})
    }
}
