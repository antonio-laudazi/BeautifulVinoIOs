//
//  Feed.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 16/11/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit
// non ho la chiamata del feed singolo
class Feed: NSObject, Codable {
    var idFeed:String!
    var dataFeed:Int!
    var dataEntitaHeaderFeed:Int!
    var headerFeed:String!
    var sottoHeaderFeed:String!
    var titoloFeed:String!
    var urlImmagineHeaderFeed:String!
    var urlImmagineFeed:String!
    var testoLabelFeed:String!
    var testoFeed:String!
    var vinoFeedInt:Vino!
    var eventoFeedInt:Evento!
    var aziendaFeed:Azienda!
    var tipoFeed:Int! //determina la dettaglioView che si apre cliccando sulla cella es. dettEventoView, determina il tipo di cella
    var idEntitaFeed:String!
    var tipoEntitaHeaderFeed:String!//determina la dettaglioView che si apre cliccando su header es. dettEventoView
    var idEntitaHeaderFeed:String!
    var urlVideoFeed:String!

    enum TipoFeed: Int{// nel caso del post ToGo è hidden
        case pubblicita = 1
        case azienda = 2
        case vino = 3 //azione
        case evento = 4 //azione
        case post = 5
    }
    
    enum TipoEntitaHeaderFeed: String{
        case azienda = "AZ"
        case profilo = "UT"
        case evento = "EV"
        case vino = "VI"
    }
    
}







