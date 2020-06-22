//
//  FirstViewController.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 26/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class FirstViewController: UIViewController {

    private var loginC:LoginViewController!

    @IBOutlet weak var buttonRegistrati: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        loginC = appDelegate.loginController

        self.navigationController?.navigationBar.isHidden=true
        buttonRegistrati.addCornerRadius()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @IBAction func buttonAccediPressed(){
       loginC.tipo=Tipo.accesso
        self.present(loginC, animated: true, completion: nil)
      //  performSegue(withIdentifier: "GoToLogin", sender: nil)
    }

    @IBAction func buttonRegistratiPressed(){
        loginC.tipo=Tipo.registrazione
        self.present(loginC, animated: true, completion: nil)
   //     performSegue(withIdentifier: "GoToLogin", sender: nil)
        
    }
    
}
