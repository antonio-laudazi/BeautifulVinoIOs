//
//  RegistrazioneOptViewController.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 31/01/18.
//  Copyright © 2018 Maria Tourbanova. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class RegistrazioneOptViewController: UIViewController, UITextViewDelegate, ConnectionManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var labelBiografia:UILabel!
    @IBOutlet weak var labelCitta:UILabel!
    @IBOutlet weak var labelMess:UILabel!
    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var scrollView:UIScrollView!
    
    @IBOutlet weak var textViewBiografia:UITextView!
    @IBOutlet weak var textFieldCitta:UITextField!
    @IBOutlet weak var buttonGo:UIButton!
    @IBOutlet weak var buttonTakeFoto:UIButton!
    @IBOutlet weak var buttonSkip:UIButton!
    @IBOutlet weak var buttonPrivacy:UIButton!
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var heightConstraintContentView:NSLayoutConstraint!
    
    //   private var scrollViewHeight:CGFloat!
    
    var imagePicker: UIImagePickerController!
    
    var user: AWSCognitoIdentityUser?
    var email:String!
    var username:String!
    private weak var caricamentoView:CaricamentoView!
    private let cManager = ConnectionManager()//AppDelegate.connectionManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonGo()
        textFieldCitta.setBottomBorder()
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.clipsToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrazioneOptViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrazioneOptViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let attributedString = NSMutableAttributedString(string: "cliccando \"Avanti\" indicherai di accettare i ", attributes: [
            .font: UIFont(name: "InterUI-Regular", size: 10.0)!,
            .foregroundColor: UIColor.white])
        let attrStr = NSMutableAttributedString(string: "Termini d'uso", attributes: [
            .font: UIFont(name: "InterUI-Bold", size: 10.0)!,
            .foregroundColor: UIColor.white])
        attributedString.append(attrStr)
        buttonPrivacy.setAttributedTitle(attributedString, for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        setNeedsStatusBarAppearanceUpdate()
        cManager.delegate=self
        labelCitta.adjustsFontSizeToFitWidth = true
        labelBiografia.adjustsFontSizeToFitWidth = true
        labelMess.adjustsFontSizeToFitWidth = true
        buttonSkip.titleLabel?.adjustsFontSizeToFitWidth = true
        buttonGo.addCornerRadius()
        buttonTakeFoto.addCornerRadius()
        
        // scrollViewHeight=self.view.frame.size.height//scrollView.frame.size.height
        heightConstraintContentView.constant=view.frame.height
        scrollView.contentSize=CGSize(width: self.view.frame.size.width, height:self.view.frame.size.height)
        scrollView.isScrollEnabled=false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillHide,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillShow,
                                                  object: nil)
    }
    
    
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentSize=CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height+keyboardSize.height)
        }
        scrollView.isScrollEnabled=true
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentSize=CGSize(width: self.view.frame.size.width, height:self.view.frame.size.height)
        scrollView.isScrollEnabled=false
    }
    
    
    @IBAction private func textFieldDidChange() {
        setButtonGo()
    }
    
    @IBAction func viewTapped() {
        view.endEditing(true)
    }
    
    @IBAction func buttonGoPressed(){
        view.endEditing(true)
        showLoading()
        saveUserAttributes()
    }
    
    @IBAction private func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
            
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        setButtonGo()
        dismiss(animated:true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
        setButtonGo()
    }
    
    @IBAction func buttonPrivacyPressed(){
        UIApplication.shared.openURL(URL(string: "http://www.beautifulvino.com/privacy-policy/")!)
    }
    
    @IBAction func buttonSkipPressed(){
        view.endEditing(true)
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
    
    private func saveUserAttributes(){
        cManager.sendUtente(idUtente: UDManager.getIdUser(),foto: imageView.image, citta: textFieldCitta.text!, professione: "", biografia: textViewBiografia.text, username: username, email: email)
    }
    
    func textViewDidChange(_ textView: UITextView){
        setButtonGo()
    }
    
    private func setButtonGo(){
        if (textFieldCitta.text != "" || textViewBiografia.text != "" || imageView.image != nil) {
            buttonGo.isEnabled=true
            buttonGo.backgroundColor=UIColor.bvDandelion
        } else{
            buttonGo.isEnabled=false
            buttonGo.backgroundColor=UIColor(white: 1, alpha: 0.4)
        }
    }
    
    private func showAlert(titolo:String, msg:String){
        let alert = UIAlertController(title: titolo, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    private func showLoading(){
        caricamentoView=CaricamentoView.instanceFromNib()
        caricamentoView.frame=CGRect(x:0,y:0,width:self.view.frame.size.width,height:self.view.frame.size.height)
        self.view.addSubview(caricamentoView)
        caricamentoView.activityIndicator?.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    private func hideLoading(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        caricamentoView.removeFromSuperview()
    }
    
    func utenteIsSaved(errore: String) {
        if errore=="" {
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
