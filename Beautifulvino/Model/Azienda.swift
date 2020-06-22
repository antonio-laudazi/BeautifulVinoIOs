//
//  Azienda.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 30/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit

class Azienda: NSObject, Codable {
    var idAzienda:String!
    var nomeAzienda:String!
    var infoAzienda:String!//nella preview testo breve
    var descrizioneAzienda:String!//dovrebbe essere testo lungo, ma non è mai usato, è usato sempre l'attributo infoAzienda
    var regioneAzienda:String!
    var cittaAzienda:String!
    var indirizzoAzienda:String!//opzionale
    var sitoAzienda:String!//opzionale
    var emailAzienda:String!//opzionale
    var telefonoAzienda:String!//opzionale
    var latitudineAzienda:Double!//opzionale
    var longitudineAzienda:Double!//opzionale
    var urlLogoAzienda:String!//opzionale
    var urlImmagineAzienda:String!//opzionale
    var eventiAzienda:[Evento]!//opzionale
    var viniAzienda:[Vino]!//opzionale
    
   /* init(nomeAzienda: String, zoneAzienda: String, descrizioneAzienda: String, lat:Double, lon:Double, eventi: [Evento], vini: [Vino]) {
        self.nomeAzienda = nomeAzienda
        self.zoneAzienda=zoneAzienda
        self.descrizioneAzienda=descrizioneAzienda
        self.lat=lat
        self.lon=lon
        self.eventiAzienda = eventi
        self.viniAzienda=vini
    }*/
}
