//
//  ViewContentProfiloF.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 25/01/18.
//  Copyright © 2018 Maria Tourbanova. All rights reserved.
//

import UIKit

class ViewContentProfiloS: UIView {
    @IBOutlet weak var textViewBiografia:UITextView!
    
    class func instanceFromNib() -> ViewContentProfiloS {
        return UINib(nibName: "ViewContentProfiloS", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ViewContentProfiloS
    }
    
    func create(utente:Utente){
        textViewBiografia.text=utente.biografiaUtente
    }
    
}

