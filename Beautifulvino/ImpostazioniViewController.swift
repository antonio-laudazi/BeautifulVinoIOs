//
//  ImpostazioniViewController.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 27/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSCognito
import FacebookLogin
import GoogleSignIn


protocol UtenteDelegate {
    func utenteChanged()
}


class ImpostazioniViewController: UIViewController, ConnectionManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imageViewFoto:UIImageView!
    @IBOutlet var labelNome:UILabel!
    @IBOutlet var labelCitta:UILabel!
    @IBOutlet var labelProfessione:UILabel!
    @IBOutlet var labelBiografia:UILabel!
    @IBOutlet var labelEmail:UILabel!
    @IBOutlet var buttonModifica:UIButton!
    
    @IBOutlet var textFieldNome:UITextField!
    @IBOutlet var textFieldCitta:UITextField!
    @IBOutlet var textFieldEmail:UITextField!
    @IBOutlet var textFieldProfessione:UITextField!
    @IBOutlet var textViewBiografia:UITextView!
    
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var buttonTakeFoto:UIButton!
    @IBOutlet weak var contentView:UIView!

    private var scrollViewHeight:CGFloat!

    var imagePicker: UIImagePickerController!
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var utente:Utente!
    private let cManager = ConnectionManager()
    private weak var caricamentoView:CaricamentoView!
    var delegate: UtenteDelegate!

    //button modifica del mockup è pulsante salva, buttonsalvapressed invia le info al server buttonchiudi chiude il tutto... textfield sono sempre attive
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldEmail.setBottomBorderForWhite()
        textFieldNome.setBottomBorderForWhite()
        textFieldCitta.setBottomBorderForWhite()
        textFieldProfessione.setBottomBorderForWhite()
        self.imageViewFoto.layer.cornerRadius = self.imageViewFoto.frame.size.width / 2
        self.imageViewFoto.layer.borderWidth = 3
        self.imageViewFoto.layer.borderColor = UIColor.white.cgColor
        self.imageViewFoto.clipsToBounds = true
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        if (self.user == nil) {
            self.user = self.pool?.currentUser()
        }
        cManager.getUtente(idUtente: UDManager.getIdUser())
        showLoading()
        buttonModifica.isHidden=true
        
        NotificationCenter.default.addObserver(self, selector: #selector(ImpostazioniViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ImpostazioniViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        setNeedsStatusBarAppearanceUpdate()
        cManager.delegate=self
        labelEmail.adjustsFontSizeToFitWidth = true
        labelNome.adjustsFontSizeToFitWidth = true
        labelCitta.adjustsFontSizeToFitWidth = true
        labelBiografia.adjustsFontSizeToFitWidth = true
        labelProfessione.adjustsFontSizeToFitWidth = true
        buttonTakeFoto.addCornerRadius()
        scrollViewHeight=contentView.frame.size.height
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentSize=CGSize(width: self.view.frame.size.width, height: scrollViewHeight+keyboardSize.height)
        }
     buttonModifica.isHidden=false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillHide,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillShow,
                                                  object: nil)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentSize=CGSize(width: self.view.frame.size.width, height:scrollViewHeight)
    }
    
    @IBAction func buttonChiudiPressed(){
        view.endEditing(true)
        delegate.utenteChanged()
        dismiss(animated: true, completion: nil);
    }
    
    @IBAction func viewTapped() {
        view.endEditing(true)
    }
    
    @IBAction func buttonLogoutPressed(){
        if UDManager.getIdentity() != "" {
            UDManager.setIdentity(identity: "")
            let loginManager = LoginManager()
            loginManager.logOut()
            GIDSignIn.sharedInstance().signOut()    
        }
        UDManager.setIdUser(idUser: "")
        self.user?.signOut()
        self.refresh()
    }
    
    @IBAction func buttonModificaPressed(){
        view.endEditing(true)
        showLoading()
        cManager.sendUtente(idUtente: UDManager.getIdUser(), foto: imageViewFoto.image, citta: textFieldCitta.text!, professione: textFieldProfessione.text!, biografia: textViewBiografia.text, username: textFieldNome.text!, email: textFieldEmail.text!)
    }
    
    @IBAction func buttonTakeFotoPressed(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
       // imageViewFoto.image = image
        imageViewFoto.image = resizeImage(image: image, targetSize: CGSize(width: 300, height: 300))
        buttonModifica.isHidden=false
        dismiss(animated:true, completion: nil)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width:size.width * heightRatio,height: size.height * heightRatio)
        } else {
            newSize = CGSize(width:size.width * widthRatio, height:  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x:0, y:0, width:newSize.width, height:newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
    
    private func showAlert(titolo:String, msg:String){
        let alert = UIAlertController(title: titolo, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showLoading(){
        if caricamentoView==nil {
            caricamentoView=CaricamentoView.instanceFromNib()
            caricamentoView.frame=CGRect(x:0, y:0, width:self.view.frame.size.width, height:self.view.frame.size.height)
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
    
    private func reloadView(){
        textFieldNome.text=utente.usernameUtente
        textFieldCitta.text=utente.cittaUtente
        textFieldProfessione.text=utente.professioneUtente
        textViewBiografia.text=utente.biografiaUtente
        textFieldEmail.text=utente.emailUtente
        imageViewFoto.imageFromServerURL(urlString: utente.urlFotoUtente, imagePlaceholder: UIImage(named: "placeholderUser")!, completionBlock: {_ in})
    }
    
    func utenteDidReceive(utente:Utente?, errore:String){
        if errore=="" {
            self.utente=utente
            DispatchQueue.main.async() {
                self.reloadView()
            }
        }else{
            DispatchQueue.main.async() {
                self.showAlert(titolo: "Errore", msg: errore)
            }
        }
        DispatchQueue.main.async() {
            self.hideLoading()
        }
    }
    
    func utenteDidReceiveWithError(error:Error){
        DispatchQueue.main.async() {
            self.hideLoading()
            self.showAlert(titolo: "Errore", msg: error.localizedDescription)
        }
    }
    
    func utenteIsSaved(errore: String) {
        if errore=="" {
            DispatchQueue.main.async() {
                self.hideLoading()
                self.buttonModifica.isHidden=true
                self.showAlert(titolo: "", msg:"Profilo salvato correttamente" )
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
    
    
    /*func googleLogout() {
        self.gppSignIn?.disconnect()
        self.googleAuth = nil
        self.keyChain[GOOGLE_PROVIDER] = nil
    }*/
    
    
    func refresh() {
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
            })
            return nil
        }
    }
}
