//
//  Utente.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 03/11/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit

class Utente: NSObject, Codable {
    var idUtente: String!
    var professioneUtente: String!//opzionale
    var cittaUtente: String!//opzionale
    var usernameUtente: String!
    var emailUtente: String!//opzionale
  //  var creditiUtente: Int!//opzionale
   // var esperienzaUtente: Int!//opzionale
    var livelloUtente:String!//opzionale
    var puntiMancantiProssimoLivelloUtente:String!//opzionale
    var biografiaUtente: String!//opzionale
    var urlFotoUtente: String!//opzionale
    var numTotEventi: Int!
    var numTotBadge: Int!
    var numTotAziende: Int!
    var eventiUtente:[Evento]!//opzionale
    var aziendeUtente:[Azienda]!//opzionale
    var badgeUtente:[Badge]!//opzionale
    var statoUtente:String!
    
    enum Stato: String{
        case seguito = "A"
        case null = "D"
    }

}
