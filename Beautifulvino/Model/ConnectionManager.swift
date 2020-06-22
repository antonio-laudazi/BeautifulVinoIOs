//
//  ConnectionManager.swift
//  Timoil
//
//  Created by Antonio Laudazi on 04/07/16.
//  Copyright © 2016 Maria Tourbanova. All rights reserved.
//

import UIKit

@objc protocol ConnectionManagerDelegate {
    
    // @objc optional func loginDidReceive(utente:Utente?, errore: String)
    //  @objc optional func loginDidReceiveWithError(error:Error)
    
    @objc optional func utenteIsSaved(errore: String)
    @objc optional func utenteIsSavedWithError(error:Error)
    
    @objc optional func fetchingServerTokenWithError(errore:String)
    
    @objc optional func eventiDidReceive(ev:[Evento]?, numTotEventi:Int, errore:String)
    @objc optional func eventiDidReceiveWithError(error:Error)
    
    @objc optional func provinceDidReceive(province:[Provincia]?, errore:String)
    @objc optional func provinceDidReceiveWithError(error:Error)
    
    @objc optional func feedArrayDidReceive(feedA:[Feed]?, numTotFeed:Int, errore:String)
    @objc optional func feedArrayDidReceiveWithError(error:Error)
    
    @objc optional func eventoDidReceive(evento:Evento?, errore:String)
    @objc optional func eventoDidReceiveWithError(error:Error)
    
    @objc optional func statoEventoIsChanged(errore:String)
    @objc optional func statoEventoError(error:Error)
    
    @objc optional func statoUtenteIsChanged(errore:String)
    @objc optional func statoUtenteError(error:Error)
    
    @objc optional func aziendaDidReceive(azienda:Azienda?, errore:String)
    @objc optional func aziendaDidReceiveWithError(error:Error)
    
    @objc optional func vinoDidReceive(vino:Vino?, errore:String)
    @objc optional func vinoDidReceiveWithError(error:Error)
    
    @objc optional func statoVinoIsChanged(errore:String)
    @objc optional func statoVinoError(error:Error)
    
    @objc optional func badgesDidReceive(badges:[Badge]?, errore:String)
    @objc optional func badgesDidReceiveWithError(error:Error)
    
    @objc optional func viniDidReceive(vini:[Vino]?, errore:String)
    @objc optional func viniDidReceiveWithError(error:Error)
    
    @objc optional func viniEventoDidReceive(aziende:[Azienda]?, errore:String)
    @objc optional func viniEventoDidReceiveWithError(error:Error)
    
    @objc optional func utenteDidReceive(utente:Utente?, errore:String)
    @objc optional func utenteDidReceiveWithError(error:Error)
    
    @objc optional func puntiGuadagnati(esito:Esito)
    @objc optional func puntiGuadagnatiError(error:Error)
    
}

class ConnectionManager: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    struct Token: Codable {
        var token:String?
    }
    
    struct Root: Codable {
        var esito: Esito
        var utente:Utente?
        var azienda:Azienda?
        var aziende:[Azienda]?
        var evento:Evento?
        var eventi:[Evento]?
        var feed:[Feed]?
        var numTotEventi:Int?
        var numTotFeed:Int?
        var vino:Vino?
        var vini:[Vino]?
        var badges:[Badge]?
        var province:[Provincia]?
        let token: Token?
    }
    
    private var request:URLRequest!
    private var typeRequest:NSInteger!
    
    private var request_type:RequestType!
    
    
    private var requestServerToken=false
    private var responseData:Data!
    private var defaultSession:URLSession!
    private var oldUrlRequest:URLRequest!
    private var oldParams:Dictionary<String, Any>!
    let stringUrlGet="https://gmnh1plxq7.execute-api.eu-central-1.amazonaws.com/BeautifulVinoGet"
    let stringUrlPut="https://4aqjw0dwx0.execute-api.eu-central-1.amazonaws.com/BeautifulVinoPut"
    let stringUrlConnect="https://ivbkaplee3.execute-api.eu-central-1.amazonaws.com/BeautifulVinoConnect"
    
    var delegate:ConnectionManagerDelegate!
    
    override init()
    {
        super.init()
        self.createSession()
    }
    
    func createSession() {
        if (defaultSession == nil) {
            defaultSession=URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        }
    }
    
    /*  func login(email: String, psw: String, lat: Double, lon: Double) {
     request_type=RequestType.request_login
     let stringUrl="https://46qot5fakj.execute-api.eu-central-1.amazonaws.com/BeautifulVinoLogin"
     let params = ["emailUtente": email, "passwordUtente": psw, "latitudineUtente": lat, "longitudineUtente": lon] as Dictionary<String, Any>
     if let request=createRequest(url: stringUrl, params: params){
     oldUrlRequest=request
     oldParams=params
     let dataTask=defaultSession.dataTask(with: request)
     dataTask.resume()
     }
     }
     
     func loginWithFb(){
     request_type=RequestType.request_login
     let stringUrl="https://46qot5fakj.execute-api.eu-central-1.amazonaws.com/BeautifulVinoLogin"
     let params = ["loginFb": "email"] as Dictionary<String, Any>
     if let request=createRequest(url: stringUrl, params: params){
     oldUrlRequest=request
     oldParams=params
     let dataTask=defaultSession.dataTask(with: request)
     dataTask.resume()
     }
     }*/
    
    private func getServerToken(){
        let userId=UDManager.getIdUser()
        let oldToken=UDManager.getToken()
        requestServerToken=true
        let params = ["idUtente":userId, "oldToken":oldToken, "functionName":"getTokenGen"] as Dictionary<String, Any>
        if let request=createRequest(url: stringUrlGet, params: params){
            let dataTask=defaultSession.dataTask(with: request)
            dataTask.resume()
        }
    }
    
    func getEventi(ultimoEvento:Evento?){
        request_type=RequestType.request_get_eventi
        let userId=UDManager.getIdUser()
        let idProvincia=UDManager.getProvincia()?.idProvincia
        let params:Dictionary<String, Any>
        
        if  let ev=ultimoEvento {
            params = ["idUtente":userId, "idProvincia": idProvincia ?? "X", "idUltimoEvento":ev.idEvento, "dataUltimoEvento":ev.dataEvento, "token":createToken(), "functionName":"getEventiGen"] as Dictionary<String, Any>//"idProvincia":UDManager.getIdProvincia().intValue,
        }else{
            params = ["idUtente":userId, "idProvincia": idProvincia ?? "X", "token":createToken(), "functionName":"getEventiGen"] as Dictionary<String, Any>
        }
        if let request=createRequest(url: stringUrlGet, params: params){
            oldUrlRequest=request
            oldParams=params
            let dataTask=defaultSession.dataTask(with: request)
            dataTask.resume()
        }
    }
    
    func getProvince(){
        request_type=RequestType.request_get_province
        let userId=UDManager.getIdUser()
        let params = ["idUtente":userId, "token":createToken(), "functionName":"getProvinceGen"] as Dictionary<String, Any>
        if let request=createRequest(url: stringUrlGet, params: params){
            oldUrlRequest=request
            oldParams=params
            let dataTask=defaultSession.dataTask(with: request)
            dataTask.resume()
        }
    }
    
    func getFeed(ultimoFeed:Feed?){
        request_type=RequestType.request_get_feed
        let userId=UDManager.getIdUser()
        let params:Dictionary<String, Any>
        if  let f=ultimoFeed {
            params = ["idUtente":userId, "idUltimoFeed":f.idFeed, "dataUltimoFeed":f.dataFeed, "functionName":"getFeedGen"] as Dictionary<String, Any>
        }else{
            params = ["idUtente":userId, "functionName":"getFeedGen"] as Dictionary<String, Any>
        }
        if let request=createRequest(url: stringUrlGet, params: params){
            oldUrlRequest=request
            oldParams=params
            let dataTask=defaultSession.dataTask(with: request)
            dataTask.resume()
        }
    }
    
    func getPuntiEsperienza(idFeed:String){
        request_type=RequestType.request_get_punti
        let userId=UDManager.getIdUser()
        let params = ["idUtente":userId, "functionName":"putPuntiEsperienza", "idFeed":idFeed] as Dictionary<String, Any>
        if let request=createRequest(url: stringUrlPut, params: params){
            oldUrlRequest=request
            oldParams=params
            let dataTask=defaultSession.dataTask(with: request)
            dataTask.resume()
        }
    }
    
    //dataEvento serve al db come chiave secondaria
    func getEvento(eventoId:String, dataEvento:Int){
        request_type=RequestType.request_get_evento
        let userId=UDManager.getIdUser()
        let params = ["idEvento":eventoId, "dataEvento":dataEvento, "idUtente":userId, "token":createToken(), "functionName":"getEventoGen"] as Dictionary<String, Any>
        if let request=createRequest(url: stringUrlGet, params: params){
            oldUrlRequest=request
            oldParams=params
            let dataTask=defaultSession.dataTask(with: request)
            dataTask.resume()
        }
    }
    
    func changeStatoEvento(evento: Evento, statoP:String?, statoA:String?, numPartecipanti:Int){
        request_type=RequestType.request_change_stato_evento
        var pref=0
        var acq=0
        if statoA==Evento.StatoEvento.acquistato.rawValue || statoA==Evento.StatoEvento.prenotato.rawValue{
            acq=1
        }
        if statoP==Evento.StatoPreferitoEvento.preferito.rawValue {
            pref=1
        }
        let params = ["idEvento":evento.idEvento, "dataEvento":evento.dataEvento, "idUtente":UDManager.getIdUser(),"statoPreferitoEvento":pref, "statoAcquistatoEvento":acq, "functionName":"connectEventoAUtenteGen1", "numeroPartecipanti":numPartecipanti] as Dictionary<String, Any>
        if let request=createRequest(url: stringUrlConnect, params: params){
            oldUrlRequest=request
            oldParams=params
            let dataTask=defaultSession.dataTask(with: request)
            dataTask.resume()
        }
    }
    
    func changeStatoUtente(idUtente:String, stato:Utente.Stato){
        request_type=RequestType.request_change_stato_utente
        let paramUtenti:[String:Any] = ["idUtente":idUtente]
        let params = ["utenti":[paramUtenti], "idUtente":UDManager.getIdUser(),"statoUtente":stato.rawValue, "functionName":"connectUtentiAUtenteGen"] as Dictionary<String, Any>
        if let request=createRequest(url: stringUrlConnect, params: params){
            oldUrlRequest=request
            oldParams=params
            let dataTask=defaultSession.dataTask(with: request)
            dataTask.resume()
        }
    }
    
    func getAzienda(aziendaId:String){
        request_type=RequestType.request_get_azienda
        let params = ["idAzienda":aziendaId, "functionName":"getAziendaGen"] as Dictionary<String, Any>
        if let request=createRequest(url: stringUrlGet, params: params){
            oldUrlRequest=request
            oldParams=params
            let dataTask=defaultSession.dataTask(with: request)
            dataTask.resume()
        }
    }
    
    func getVino(vinoId:String){
        request_type=RequestType.request_get_vino
        let params = ["idVino":vinoId, "idUtente":UDManager.getIdUser(), "functionName":"getVinoGen"] as Dictionary<String, Any>
        if let request=createRequest(url: stringUrlGet, params: params){
            oldUrlRequest=request
            oldParams=params
            let dataTask=defaultSession.dataTask(with: request)
            dataTask.resume()
        }
    }
    
    func changeStatoVino(idVino:String, stato:Vino.Stato){
        request_type=RequestType.request_change_stato_vino
        let params = ["idVino":idVino, "idUtente":UDManager.getIdUser(),"statoVino":stato.rawValue, "functionName":"connectViniAUtenteGen"] as Dictionary<String, Any>
        if let request=createRequest(url: stringUrlConnect, params: params){
            oldUrlRequest=request
            oldParams=params
            let dataTask=defaultSession.dataTask(with: request)
            dataTask.resume()
        }
    }
    
    func getViniEvento(evento:Evento){
        request_type=RequestType.request_get_aziende_evento
        let params = ["idEvento":evento.idEvento, "dataEvento":evento.dataEvento, "functionName":"getViniEventoGen"] as Dictionary<String, Any>
        if let request=createRequest(url: stringUrlGet, params: params){
            oldUrlRequest=request
            oldParams=params
            let dataTask=defaultSession.dataTask(with: request)
            dataTask.resume()
        }
    }
    
    func getUtente(idUtente:String){
        request_type=RequestType.request_get_utente
        let params = ["idUtente":idUtente, "idUtentePadre":UDManager.getIdUser(), "functionName":"getUtenteGen"] as Dictionary<String, Any>
        if let request=createRequest(url: stringUrlGet, params: params){
            oldUrlRequest=request
            oldParams=params
            let dataTask=defaultSession.dataTask(with: request)
            dataTask.resume()
        }
    }
    
    func sendUtente(idUtente:String, foto:UIImage?, citta:String, professione:String, biografia:String, username:String, email:String){
        request_type=RequestType.request_save_utente
        let image64String = encodeImage(foto: foto)
        let utenteParams = ["idUtente":idUtente, "biografiaUtente":biografia, "professioneUtente":professione, "usernameUtente":username, "emailUtente":email, "cittaUtente":citta] as Dictionary<String, Any>
        let params = ["utente":utenteParams, "base64Image":image64String, "functionName":"putUserProfileImageWithUserGen"] as Dictionary<String, Any>
        if let request=createRequest(url: stringUrlPut, params: params){
            oldUrlRequest=request
            oldParams=params
            let dataTask=defaultSession.dataTask(with: request)
            dataTask.resume()
        }
    }
    
    private func encodeImage(foto:UIImage?)->String{
        // let jsonImage: NSMutableDictionary = NSMutableDictionary()
        if let f = foto {
            let data = UIImageJPEGRepresentation(f, 0)
            let strBase64:String = (data?.base64EncodedString())!
            //   jsonImage.setValue(strBase64, forKey: "base64Image")
            return strBase64//getJsonData(from: jsonImage)
        }else{
            return ""
        }
        
    }
    
    /*func getJsonData(from:NSMutableDictionary)->Data?
     {
     let jsonData: Data
     do {
     jsonData = try JSONSerialization.data(withJSONObject: from, options: JSONSerialization.WritingOptions())
     let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
     return jsonData
     } catch _ {
     }
     return nil
     }*/
    
    
    //MARK: Aiuti
    
    private func createToken()->Dictionary<String,Any>{
        var t = Dictionary<String, Any>()
        t.updateValue(UDManager.getToken(), forKey: "token")
        return t
    }
    
    private func createRequest(url: String, params:Dictionary<String, Any>)->URLRequest?{
        let urlStr=url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        var request=URLRequest(url: URL(string:urlStr)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            var jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
           //  print(String(data: jsonData, encoding: .utf8)!)
            
            let postLength = String(jsonData.count)
            request.addValue(postLength, forHTTPHeaderField: "Content-Length")
            request.httpBody = jsonData
            return request
        }
        catch {
            return nil
        }
    }
    
    /* func cancelRequest(typeRequest:Int){
     if request_type==typeRequest {
     request_type = -1
     setRequestCancel()
     }
     }*/
    
    private func setRequestCancel(){
        request = nil
        responseData=nil
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data){
        if responseData != nil{
            responseData.append(data)
        }
        else{
            responseData=Data(data)
        }
    }
    
    private func resendRequestToServerWithNewToken(){
        setRequestCancel()
        oldParams.updateValue(createToken(), forKey: "token")
        do {
            var jsonData = try JSONSerialization.data(withJSONObject: oldParams, options: .prettyPrinted)
            let postLength = String(jsonData.count)
            oldUrlRequest.addValue(postLength, forHTTPHeaderField: "Content-Length")
            oldUrlRequest.httpBody = jsonData
            let dataTask=defaultSession.dataTask(with: oldUrlRequest)
            dataTask.resume()
        }
        catch {
            print("Invalid data for JSON.")
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?){
        var messErrore=""
        //  sleep(4)
        let decoder=JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
       /* if responseData != nil{
            print(String(data: responseData, encoding: .utf8)!)
        }*/
        do {
            if error == nil {
                let decoder=JSONDecoder()
                decoder.dateDecodingStrategy = .millisecondsSince1970
                let r=try decoder.decode(Root.self, from: responseData)
                if (requestServerToken) {
                    requestServerToken=false
                    let token = r.token?.token
                    if (token=="") {
                        delegate.fetchingServerTokenWithError!(errore: r.esito.message)
                    }else{
                        UDManager.setToken(token: token!)
                        resendRequestToServerWithNewToken()
                    }
                }else{
                    if(r.esito.codice==110){//token scaduto
                        getServerToken()
                    }else{
                        if r.esito.codice != 100{
                            messErrore=r.esito.message
                        }
                        if request_type==RequestType.request_login {
                            //     print(r.esito)
                            //  UDManager.setToken(token: r.token!.token!)
                        }else if request_type==RequestType.request_get_eventi {
                            delegate.eventiDidReceive!(ev:r.eventi, numTotEventi:r.numTotEventi!, errore: messErrore)
                        }else if request_type==RequestType.request_get_feed {
                            delegate.feedArrayDidReceive!(feedA:r.feed, numTotFeed:r.numTotFeed!, errore: messErrore)
                        }else if request_type==RequestType.request_get_province {
                            delegate.provinceDidReceive!(province:r.province, errore: messErrore)
                        }else if request_type==RequestType.request_change_stato_evento {
                            delegate.statoEventoIsChanged!(errore: messErrore)
                        }else if request_type==RequestType.request_change_stato_utente {
                            delegate.statoUtenteIsChanged!(errore: messErrore)
                        }else if request_type==RequestType.request_get_evento {
                            delegate.eventoDidReceive!(evento:r.evento, errore: messErrore)
                        }else if request_type==RequestType.request_get_azienda {
                            delegate.aziendaDidReceive!(azienda:r.azienda, errore: messErrore)
                        }else if request_type==RequestType.request_get_vino {
                            delegate.vinoDidReceive!(vino:r.vino, errore: messErrore)
                        }else if request_type==RequestType.request_change_stato_vino {
                            delegate.statoVinoIsChanged!(errore: messErrore)
                        }else if request_type==RequestType.request_get_utente {
                            delegate.utenteDidReceive!(utente: r.utente, errore: messErrore)
                        }else if request_type==RequestType.request_get_aziende_evento {
                            delegate.viniEventoDidReceive!(aziende: r.aziende, errore: messErrore)
                        }else if request_type==RequestType.request_save_utente {
                            delegate.utenteIsSaved!(errore: messErrore)
                        }else if request_type==RequestType.request_get_punti {
                            delegate.puntiGuadagnati!(esito: r.esito)
                        }
                    }
                }
            } else {
                if request_type==RequestType.request_get_eventi {
                    delegate.eventiDidReceiveWithError!(error: error!)
                }else if request_type==RequestType.request_change_stato_evento {
                    delegate.statoEventoError!(error: error!)
                }else if request_type==RequestType.request_change_stato_utente {
                    delegate.statoUtenteError!(error: error!)
                }else if request_type==RequestType.request_get_feed {
                    delegate.feedArrayDidReceiveWithError!(error: error!)
                }else if request_type==RequestType.request_get_province {
                    delegate.provinceDidReceiveWithError!(error: error!)
                }else if request_type==RequestType.request_get_evento{
                    delegate.eventoDidReceiveWithError!(error: error!)
                }else if request_type==RequestType.request_get_azienda{
                    delegate.aziendaDidReceiveWithError!(error: error!)
                }else if request_type==RequestType.request_get_vino{
                    delegate.vinoDidReceiveWithError!(error: error!)
                }else if request_type==RequestType.request_change_stato_vino {
                    delegate.statoVinoError!(error: error!)
                }else if request_type==RequestType.request_login {
                    // delegate.loginDidReceiveWithError!(error: error!)
                }else if request_type==RequestType.request_get_utente {
                    delegate.utenteDidReceiveWithError!(error: error!)
                }else if request_type==RequestType.request_get_aziende_evento {
                    delegate.viniEventoDidReceiveWithError!(error: error!)
                }else if request_type==RequestType.request_save_utente {
                    delegate.utenteIsSavedWithError!(error: error!)
                }else if request_type==RequestType.request_get_punti {
                    delegate.puntiGuadagnatiError!(error: error!)
                }
                print("session \(session) download failed with error \(error?.localizedDescription ?? "")")
            }
            
        }catch {
            self.urlSession(session, task: task, didCompleteWithError: error)
        }
        setRequestCancel()
    }
    
}

