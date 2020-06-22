//
//  Badge.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 30/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit

class Badge: NSObject, Codable {
    var idBadge:String!
    var nomeBadge:String!
    var infoBadge:String!//opzionale
    var urlLogoBadge:String!
    var tuoBadge:String!
    var eventoBadge:Evento!
    
    enum Stato: String{
        case tuoBadge = "S"
        case null = "N"
    }
}
