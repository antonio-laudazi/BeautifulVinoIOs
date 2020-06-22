//
//  Provincia.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 21/11/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit

class Provincia: NSObject, Codable {
    var idProvincia:String!
    var nomeProvincia:String!
    
    init(all:Bool){
        if all==true {
            self.idProvincia = "X"
            self.nomeProvincia = "TUTTI"
        }
    }
    
   /* init(ev:Evento){
        self.idProvincia = ev.idEvento
        self.nomeProvincia = ev.titoloEvento
    }*/
}


