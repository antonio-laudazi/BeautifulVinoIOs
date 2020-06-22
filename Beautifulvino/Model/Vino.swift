//
//  Vino.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 30/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit

class Vino: NSObject, Codable {
    var idVino:String!
    var nomeVino: String!
    var uvaggioVino: String!//opzionale
    var regioneVino: String!//opzionale
    var profumoVino: String!//opzionale
    var prezzoVino: Double?// se acquistabile non è opzionale
    var inBreveVino: String!
    var infoVino: String!//opzionale
    var statoVino: String!
    var urlLogoVino: String!//opzionale
    var utentiVino:[Utente]!//opzionale
    var aziendaVino:Azienda!
    var eventiVino:[Evento]!//opzionale
    var acquistabileVino:Int!
    var urlImmagineVino: String!//opzionale
    
    enum Stato: String{
        case preferito = "P"
        case acquistato = "A"
        case null = "N"
    }
    
    enum Acqistabile: Int{
        case si = 1
        case no = 0
    }
    
    func getPrezzoVino() -> String {
        if self.prezzoVino == 0 || self.prezzoVino==nil{
            return "Gratuito"
        }
        else{
            return String(format:" € %.2f",self.prezzoVino!)
        }
        
    }
}
