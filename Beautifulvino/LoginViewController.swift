//
//  LoginViewController.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 26/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import GoogleSignIn
import MapKit
import AWSCognitoIdentityProvider
import AWSCore
import AWSCognito

class LoginViewController: UIViewController, ConnectionManagerDelegate, GIDSignInUIDelegate, CLLocationManagerDelegate {
    var tipo: Tipo!
    
    @IBOutlet weak var labelTitle:UILabel!
    @IBOutlet weak var labelEmail:UILabel!
    @IBOutlet weak var labelUsernamePsw:UILabel!
    @IBOutlet weak var labelPsw:UILabel!
    
    @IBOutlet weak var textFieldEmail:UITextField!
    @IBOutlet weak var textFieldUsernamePsw:UITextField!
    @IBOutlet weak var textFieldPsw:UITextField!
    
    @IBOutlet weak var buttonShowPsw:UIButton!
    @IBOutlet weak var buttonShowUsernamePsw:UIButton!
    
    @IBOutlet weak var buttonPrivacy:UIButton!
    @IBOutlet weak var buttonDimenticatoPsw:UIButton!
    @IBOutlet weak var buttonGo:UIButton!
    @IBOutlet weak var buttonFb:UIButton!
    @IBOutlet weak var buttonGoogle: UIButton!
    
    private let cManager = ConnectionManager()//AppDelegate.connectionManager
    private weak var caricamentoView:CaricamentoView!
    private var utente:Utente!
    private let locationManager = CLLocationManager()
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    var pool: AWSCognitoIdentityUserPool?
    var user:AWSCognitoIdentityUser?
    
    private var utenteId:String!
    private var utenteIdentity:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
        if CLLocationManager.authorizationStatus() != .authorizedAlways     {
            locationManager.requestAlwaysAuthorization()
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        }
        
        textFieldEmail.setBottomBorder()
        textFieldUsernamePsw.setBottomBorder()
        textFieldPsw.setBottomBorder()
        
        buttonDimenticatoPsw.titleLabel?.adjustsFontSizeToFitWidth = true
        labelEmail.adjustsFontSizeToFitWidth = true
        labelUsernamePsw.adjustsFontSizeToFitWidth = true
        labelPsw.adjustsFontSizeToFitWidth = true
        textFieldDidChange(textFieldEmail)
        cManager.delegate=self
        GIDSignIn.sharedInstance().uiDelegate = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(LoginViewController.receiveToggleAuthUINotification(_:)),
                                               name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
                                                  object: nil)
    }
    
    @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
        if notification.name.rawValue == "ToggleAuthUINotification" {
            if notification.userInfo != nil {
                guard let userInfo = notification.userInfo as? [String:String] else { return }
                let user = notification.object as! GIDGoogleUser
                
                let idToken = user.authentication.idToken
                let customProvider = CustomIdentityProvider(tokens: [AWSIdentityProviderGoogle: idToken!])
                let googlecredentialsProvider = AWSCognitoCredentialsProvider(regionType: .EUCentral1, identityPoolId: CognitoIdentityPoolId, identityProviderManager: customProvider)
                let configuration = AWSServiceConfiguration(region: .EUCentral1, credentialsProvider:googlecredentialsProvider)
                googlecredentialsProvider.clearKeychain()
                AWSServiceManager.default().defaultServiceConfiguration = configuration
                customProvider.logins().continueWith {[weak self] (task) -> Any? in
                    DispatchQueue.main.async(execute: {
                        if let error = task.error as NSError? {
                            self?.showAlert(titolo: (error.userInfo["__type"] as? String)!, msg: (error.userInfo["message"] as? String)!)} else {
                            googlecredentialsProvider.getIdentityId().continueWith(block: { (taskTask: AWSTask<NSString>) -> Any? in
                                if taskTask.error == nil  {
                                    self?.utenteId=taskTask.result! as String
                                    self?.utenteIdentity=taskTask.result! as String
                                    self?.saveUtenteFromGoogle(user: user)
                                } else {
                                    self?.hideLoading()
                                }
                                return nil
                            })}}) }
            }else{
                self.hideLoading()
            }}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        setNeedsStatusBarAppearanceUpdate()
        cManager.delegate=self
        buttonGo.addCornerRadius()
        buttonFb.addCornerRadius()
        buttonGoogle.addCornerRadius()
        
        textFieldPsw.text=nil
        textFieldUsernamePsw.text=nil
        textFieldEmail.text=nil
        
        if(tipo==Tipo.accesso){
            labelTitle.text="Accedi"
            buttonGo.setTitle("ACCEDI", for: .normal)
            buttonFb.setTitle("ACCEDI CON FACEBOOK", for: .normal)
            buttonGoogle.setTitle("ACCEDI CON GOOGLE", for: .normal)
            labelUsernamePsw.text="password"
            buttonShowUsernamePsw.isHidden=false
            textFieldUsernamePsw.isSecureTextEntry=true
            textFieldPsw.isHidden=true
            labelPsw.isHidden=true
            buttonShowPsw.isHidden=true
            buttonDimenticatoPsw.isHidden=false
            buttonPrivacy.isHidden=true
        }else{
            labelTitle.text="Registrati"
            buttonGo.setTitle("REGISTRATI", for: .normal)
            buttonFb.setTitle("REGISTRATI CON FACEBOOK", for: .normal)
            buttonGoogle.setTitle("REGISTRATI CON GOOGLE", for: .normal)
            labelUsernamePsw.text="nome         "//lasciato i caratteri vuoti altrimenti non scala la dimensione del testo
            buttonShowUsernamePsw.isHidden=true
            textFieldUsernamePsw.isSecureTextEntry=false
            textFieldPsw.isHidden=false
            labelPsw.isHidden=false
            buttonShowPsw.isHidden=false
            buttonDimenticatoPsw.isHidden=true
            buttonPrivacy.isHidden=false
            
            let attributedString = NSMutableAttributedString(string: "cliccando \"Registrati\" indicherai di accettare i ", attributes: [
                .font: UIFont(name: "InterUI-Regular", size: 10.0)!,
                .foregroundColor: UIColor.white])
            let attrStr = NSMutableAttributedString(string: "Termini d'uso", attributes: [
                .font: UIFont(name: "InterUI-Bold", size: 10.0)!,
                .foregroundColor: UIColor.white])
            attributedString.append(attrStr)
            buttonPrivacy.setAttributedTitle(attributedString, for: .normal)
        }
    }
    
    // MARK: - CLLocationManager
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        locationManager.stopUpdatingLocation()
        //let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: textFieldEmail.text!, password: textFieldPsw.text! )
        // self.passwordAuthenticationCompletion?.set(result: authDetails)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        //  let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: textFieldEmail.text!, password: textFieldPsw.text! )
        //  self.passwordAuthenticationCompletion?.set(result: authDetails)
    }
    
    // MARK: - IBAction
    
    @IBAction func buttonBackPressed(){
        view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonShowPswPressed(){
        if(tipo==Tipo.registrazione){
            textFieldPsw.isSecureTextEntry = !textFieldPsw.isSecureTextEntry
        }
        else{
            textFieldUsernamePsw.isSecureTextEntry = !textFieldUsernamePsw.isSecureTextEntry
        }
    }
    
    @IBAction func buttonPrivacyPressed(){
        UIApplication.shared.openURL(URL(string: "http://www.beautifulvino.com/privacy-policy/")!)
    }
    
    @IBAction func buttonGoPressed(){
        view.endEditing(true)
        
        if controllaTextField(email:textFieldEmail.text!, usernamePsw: textFieldUsernamePsw.text!, psw:textFieldPsw.text!) {
            showLoading()
            // locationManager.startUpdatingLocation()
            if(tipo==Tipo.accesso){
                let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: textFieldEmail.text!, password: textFieldUsernamePsw.text! )
                self.passwordAuthenticationCompletion?.set(result: authDetails)}
            else{
                signUp()
            }
        }
    }
    
    @IBAction func buttonGooglePressed(){
        tipo=Tipo.accesso
        view.endEditing(true)
        showLoading()
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    @IBAction func dimenticatoPswPressed(){
        guard let email = textFieldEmail.text, !email.isEmpty else {
            showAlert(titolo: "Email mancante", msg: "Inserisci un indirizzo email valido.")
            return
        }
        
        self.user = self.pool?.getUser(textFieldEmail.text!)
        self.user?.forgotPassword().continueWith{[weak self] (task: AWSTask) -> AnyObject? in
            //    guard let strongSelf = self else {return nil}
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    self?.showAlert(titolo: error.userInfo["__type"] as! String, msg: error.userInfo["message"] as! String)
                }else{
                    self?.showAlert(titolo:"Password dimenticata", msg:"Ti abbiamo mandato una mail per il ripristino della password. Se non la vedi controlla nella casella di Spam")
                }
            })
            return nil
        }
    }
    
    @IBAction func buttonFbPressed(){
        view.endEditing(true)
        tipo=Tipo.accesso
        showLoading()
        let loginManager = LoginManager()
        loginManager.logOut()
        loginManager.logIn(readPermissions: [ .publicProfile, .email], viewController: self) { loginResult in // .userAboutMe, obsoleta
            switch loginResult {
            case .failed(let error):
                self.hideLoading()
            case .cancelled:
                self.hideLoading()
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                if declinedPermissions.count == 0{
                    let token:String = accessToken.authenticationToken
                    let fbProvider = CustomIdentityProvider(tokens: [AWSIdentityProviderFacebook: accessToken.authenticationToken])
                    let fbcredentialsProvider = AWSCognitoCredentialsProvider(regionType: .EUCentral1, identityPoolId: CognitoIdentityPoolId, identityProviderManager: fbProvider)
                    let configuration = AWSServiceConfiguration(region: .EUCentral1, credentialsProvider:fbcredentialsProvider)
                    fbcredentialsProvider.clearKeychain()
                    AWSServiceManager.default().defaultServiceConfiguration = configuration
                    fbProvider.logins().continueWith {[weak self] (task) -> Any? in
                        DispatchQueue.main.async(execute: {
                            if let error = task.error as NSError? {
                                self?.hideLoading()
                                self?.showAlert(titolo: error.userInfo["__type"] as! String, msg: error.userInfo["message"] as! String )
                            } else {
                                let result = task.result
                                fbcredentialsProvider.getIdentityId().continueWith(block: { (taskTask: AWSTask<NSString>) -> Any? in
                                    if taskTask.error == nil  {
                                        //   UDManager.setIdentity(identity: taskTask.result! as String)
                                        //   UDManager.setIdUser(idUser: taskTask.result! as String)
                                        self?.utenteId=taskTask.result! as String
                                        self?.utenteIdentity=taskTask.result! as String
                                        self?.saveUtenteFromFacebook()
                                        /* fbcredentialsProvider.credentials().continueWith(block: { (taskTask: AWSTask<AWSCredentials>) -> Any? in
                                         if taskTask.error == nil  {
                                         DispatchQueue.main.async(execute: {
                                         let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                         let eventiVC = storyBoard.instantiateViewController(withIdentifier: "EventiViewController")
                                         UIApplication.shared.keyWindow?.rootViewController = eventiVC
                                         })
                                         
                                         } else {
                                         }
                                         return nil
                                         })*/
                                    } else {
                                        self?.hideLoading()
                                    }
                                    return nil
                                })
                            }
                            
                        })
                    }
                }else{
                    print("declinedPermissions")
                }
            }
        }
    }
    
    private func saveUtenteFromFacebook(){
        let params = ["fields" : "email, name, last_name, first_name, about"] //, location"]
        let graphRequest = GraphRequest(graphPath: "me", parameters: params)
        graphRequest.start {
            (urlResponse, requestResult) in
            switch requestResult {
            case .failed(let error):
                print("error in graph request:", error)
                break
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    var bio=""
                    var citta=""
                    if  responseDictionary["about"] as? String != nil {
                        bio=responseDictionary["about"] as! String
                    }
                   /* if  responseDictionary["location"] != nil {//hometown
                        var city: Dictionary = responseDictionary["location"] as! Dictionary<String,String>
                        citta=city["name"]!
                    }*/
                    let FBid = responseDictionary["id"]
                    let urlStr = "https://graph.facebook.com/\(FBid!)/picture?type=large&return_ssl_resources=1"
                    URLSession.shared.dataTask(with: NSURL(string: urlStr)! as URL, completionHandler: { (data, response, error) -> Void in
                        let image = UIImage(data: data!)
                        self.cManager.sendUtente(idUtente: self.utenteId, foto: image, citta: citta, professione: "", biografia:bio, username: responseDictionary["name"] as! String, email: responseDictionary["email"] as! String)
                    }).resume()
                }
            }
            
        }
    }
    
    private func saveUtenteFromGoogle(user: GIDGoogleUser){
        if user.profile.hasImage{
            URLSession.shared.dataTask(with: user.profile.imageURL(withDimension: 200), completionHandler: { (data, response, error) -> Void in
                self.cManager.sendUtente(idUtente: self.utenteId, foto:  UIImage(data: data!), citta: "", professione: "", biografia: "", username: user.profile.name, email: user.profile.email)
            }).resume()
        }  else{
            cManager.sendUtente(idUtente: self.utenteId, foto: nil, citta: "", professione: "", biografia: "", username: user.profile.name, email: user.profile.email)
            
        }
        
    }
    
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        if (tipo==Tipo.accesso && (textFieldUsernamePsw.text == "" || textFieldEmail.text == "")) || (tipo==Tipo.registrazione && (textFieldPsw.text == "" || textFieldUsernamePsw.text == "" || textFieldEmail.text == "")) {
            buttonGo.isEnabled=false
            buttonGo.backgroundColor=UIColor(white: 1, alpha: 0.4)
        } else{
            buttonGo.isEnabled=true
            buttonGo.backgroundColor=UIColor.bvDandelion
        }
    }
    
    @IBAction func viewTapped() {
        view.endEditing(true)
    }
    
    // MARK: - Private
    
    private func signUp(){
        
        var attributes = [AWSCognitoIdentityUserAttributeType]()
        if let usernameValue = textFieldUsernamePsw.text, !usernameValue.isEmpty {
            let username = AWSCognitoIdentityUserAttributeType()
            username?.name = "nickname"
            username?.value = usernameValue
            attributes.append(username!)
        }
        
        //sign up the user
        
        self.pool?.signUp(textFieldEmail.text!, password: textFieldPsw.text!, userAttributes: attributes, validationData: nil).continueWith {[weak self] (task) -> Any? in
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    self?.hideLoading()
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let retryAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(retryAction)
                    self?.present(alertController, animated: true, completion:  nil)
                } else {
                    let result = task.result
                    self?.user=result?.user
                    if self?.user?.isSignedIn == false {
                        self!.user!.getSession(self!.textFieldEmail.text!, password: self!.textFieldPsw.text!, validationData: nil)
                            .continueWith { (task) -> AnyObject? in
                                if task.error == nil {
                                    self!.user!.getDetails().continueWith { (task) -> AnyObject? in
                                        if task.error == nil {
                                            self?.utenteId=self?.user!.username!
                                            self?.utenteIdentity=""
                                            //  UDManager.setIdUser(idUser: (self?.user!.username!)!)
                                            DispatchQueue.main.async() {
                                                self?.cManager.sendUtente(idUtente: (self?.utenteId)!, foto: nil, citta: "", professione: "", biografia: "", username: (self?.textFieldUsernamePsw.text)!, email: (self?.textFieldEmail.text)!)
                                                
                                            }
                                        }else{
                                            self?.hideLoading()
                                        }
                                        return nil
                                    }
                                }else{
                                    self?.hideLoading()
                                }
                                return nil
                        }
                    }
                    
                }
                
            })
            return nil
        }
    }
    
    private func showLoading(){
        if caricamentoView==nil {
            caricamentoView=CaricamentoView.instanceFromNib()
            caricamentoView.frame=CGRect(x:0,y:0,width:self.view.frame.size.width,height:self.view.frame.size.height)
            self.view.addSubview(caricamentoView)
        }
        caricamentoView.activityIndicator?.startAnimating()
        caricamentoView.isHidden=false
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    private func hideLoading(){
        if caricamentoView != nil && caricamentoView.isHidden==false {
            caricamentoView.activityIndicator?.stopAnimating()
            caricamentoView.isHidden=true
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    private func controllaTextField(email:String, usernamePsw:String, psw:String)->Bool{
        
        if !validateEmail(emailAddress:email) {
            showAlert(titolo: "Errore", msg: "Email non è valida")
            return false
        } else if usernamePsw==""{
            showAlert(titolo: "Errore", msg: "Devi riempire tutti i campi")
            return false
        }else if tipo==Tipo.registrazione && psw==""{
            showAlert(titolo: "Errore", msg: "Devi riempire tutti i campi")
            return false
        } else{
            return true
        }
    }
    
    private func validateEmail(emailAddress:String)->Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailAddress)
    }
    
    private func showAlert(titolo:String, msg:String){
        let alert = UIAlertController(title: titolo, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func utenteIsSaved(errore: String) {
        if errore=="" {
            UDManager.setIdentity(identity: utenteIdentity)
            UDManager.setIdUser(idUser: utenteId)
            if(tipo==Tipo.accesso){
                DispatchQueue.main.async() {
                    self.hideLoading()
                    if UDManager.getFirstLaunch()==false {
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let boardingVC : UIViewController = storyBoard.instantiateViewController(withIdentifier: "StoryboardIdBoarding")
                        UIApplication.shared.keyWindow?.rootViewController = boardingVC
                    }else{
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let eventiVC = storyBoard.instantiateViewController(withIdentifier: "EventiViewController")
                        UIApplication.shared.keyWindow?.rootViewController = eventiVC
                    }
                }
            }else{
                DispatchQueue.main.async(execute: {
                    self.performSegue(withIdentifier: "GoToRegistrazioneOpt", sender: nil)
                })
            }
        }else{
            DispatchQueue.main.async() {
                self.hideLoading()
                self.showAlert(titolo: "Errore", msg: errore)
            }
        }
    }
    
    func utenteIsSavedWithError(error: Error) {
        DispatchQueue.main.async() {
            self.hideLoading()
            self.showAlert(titolo: "Errore", msg: error.localizedDescription)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToTabBarController"{
            let tbc = segue.destination as! UITabBarController
            let evc=tbc.viewControllers![0] as! EventiViewController
            evc.eventi=utente.eventiUtente
            evc.numTotEventi=utente.numTotEventi!
        }
        if let rvc = segue.destination as? RegistrazioneOptViewController {
            rvc.user = user
            rvc.email=textFieldEmail.text
            rvc.username=textFieldUsernamePsw.text
        }
    }
}

extension LoginViewController: AWSCognitoIdentityPasswordAuthentication {
    
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
    }
    
    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            self.hideLoading()
            if let error = error as NSError? {
                self.showAlert(titolo: "Errore!", msg: error.localizedDescription)
            } else {
                if UDManager.getFirstLaunch()==false {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let boardingVC : UIViewController = storyBoard.instantiateViewController(withIdentifier: "StoryboardIdBoarding")
                   UIApplication.shared.keyWindow?.rootViewController = boardingVC
                }else{
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let eventiVC = storyBoard.instantiateViewController(withIdentifier: "EventiViewController")
                    UIApplication.shared.keyWindow?.rootViewController = eventiVC
                }
            }
        }
    }
}



