//
//  Evento.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 27/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit

class Evento: NSObject, Codable {
    var idEvento:String!
    var dataEvento:Int!
    var cittaEvento:String!//da mettere anche in indirizzo
    var titoloEvento:String!
    var prezzoEvento:Double?
    var urlFotoEvento:String!
    var statoPreferitoEvento:String?//P=preferito, N=other
    var statoEvento:String?//P=prenotato,A=acquistato,N=other
    var temaEvento:String!//opzionale Ok
    var testoEvento:String!//opzionale Ok
    var latitudineEvento:Double!//opzionale Ok
    var longitudineEvento:Double!//opzionale Ok
    var indirizzoEvento:String!//opzionale Ok
    var telefonoEvento:String!//opzionale Ok
    var emailEvento:String!//opzionale OK
    var numMaxPartecipantiEvento:Int?//opzionale ok
    var numPostiDisponibiliEvento:Int?//opzionale Ok
    var aziendaOspitanteEvento:Azienda!//opzionale Ok
    var aziendeViniEvento:[Azienda]!
    var badgeEvento:Badge!//opzionale ok
    var iscrittiEvento:[Utente]!//opzionale
    var acquistabileEvento:Int! //=1 evento è acquistabile, =0 evento è prenotabile

    var imageEvento:Data!

   /* enum StatoUtente: Int{
        case null = 0
        case prefAcq = 1
    }*/
    
    enum StatoEvento: String{
        case null = "N"
        case acquistato = "A"
        case prenotato = "P"
    }
    
    enum StatoPreferitoEvento: String{
        case null = "N"
        case preferito = "P"
    }
    
    enum Acqistabile: Int{
        case si = 1
        case no = 0
    }
    
    func getPrezzoEvento() -> String {
        if self.prezzoEvento == 0 || self.prezzoEvento==nil{
            return "Gratuito"
        }
        else{
            return String(format:" € %.2f",self.prezzoEvento!)
        }
    }
    
    func statoEventoModificabile()->Bool{
        if self.statoEvento==Evento.StatoEvento.null.rawValue{
            return true
        }else{
            let tomorrowTime = afterDateEvento()
            if(tomorrowTime.compare(Date()) == ComparisonResult.orderedAscending){
                return true
            } else{
                return false
            }
        }
    }
    
    func eventoAcquistabile()->Bool{
        let tomorrowTime = afterDateEvento()
        if(tomorrowTime.compare(Date()) == ComparisonResult.orderedAscending){
            return false
        } else{
            return true
        }
    }
    
    private func afterDateEvento()->Date{
        let date = Date(timeIntervalSince1970: TimeInterval(self.dataEvento/1000))
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date)
        let tomorrowTime = Calendar.current.date(bySettingHour: 12, minute: 00, second: 0, of: tomorrow!)!
        return tomorrowTime
    }
    
    
    
}
