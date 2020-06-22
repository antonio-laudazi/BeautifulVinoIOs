//
//  UDManager.swift
//  Tamoil
//
//  Created by Antonio Laudazi on 30/06/16.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//


import UIKit

class UDManager: NSObject {
    
    static private let KEY_AUTENTICATO = "autenticato";
    static private let KEY_ID_USER = "idUser";
    static private let KEY_TOKEN = "token";
    static private let KEY_PROVINCIA = "provincia";
    static private let KEY_IDENTITY = "Identity";
    static private let KEY_FIRST = "First";
    
    class func setAutenticato(autenticato: Bool)
    {
        let defaults = UserDefaults.standard
        defaults.set(autenticato, forKey: KEY_AUTENTICATO)
    }
    
    class func getAutenticato()->Bool
    {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: KEY_AUTENTICATO)
    }
    
    class func setToken(token: String)
    {
        let defaults = UserDefaults.standard
        defaults.set(token, forKey: KEY_TOKEN)
    }
    
    class func getToken()->String
    {
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: KEY_TOKEN){
            return token
        }
        return ""
    }
    
    class func setIdUser(idUser: String)
    {
        let defaults = UserDefaults.standard
        
        // defaults.set("1511887612956", forKey: KEY_ID_USER)
        defaults.set(idUser, forKey: KEY_ID_USER)
    }
    
    class func getIdUser()->String
    {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: KEY_ID_USER)!
    }
    
    class func setIdentity(identity: String)
    {
        let defaults = UserDefaults.standard
        defaults.set(identity, forKey: KEY_IDENTITY)
    }
    
    class func getIdentity()->String
    {
        let defaults = UserDefaults.standard
        if let identity = defaults.string(forKey: KEY_IDENTITY){
            return identity
        }
        return ""
    }
    
    class func setProvincia(provincia: Provincia)
    {
        let defaults = UserDefaults.standard
        if let encoded = try? JSONEncoder().encode(provincia) {
            defaults.set(encoded, forKey: KEY_PROVINCIA)
        }
    }
    
    class func getProvincia()->Provincia?
    {
        let defaults = UserDefaults.standard
        if let userData = defaults.data(forKey: KEY_PROVINCIA),
            let pr = try? JSONDecoder().decode(Provincia.self, from: userData) {
            return pr
        }
        return nil
    }
    
    class func setFirstLaunch(first: Bool)
    {
        let defaults = UserDefaults.standard
        defaults.set(first, forKey: KEY_FIRST)
    }
    
    class func getFirstLaunch()->Bool?
    {
        let defaults = UserDefaults.standard
        return  defaults.bool(forKey:KEY_FIRST)
    }
    
    
}

