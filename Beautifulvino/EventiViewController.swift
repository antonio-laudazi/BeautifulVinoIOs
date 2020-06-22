//
//  FirstViewController.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 26/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSCognito
import Firebase

class EventiViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ConnectionManagerDelegate, ProvinciaDelegate, EventoDelegate {
    
    @IBOutlet weak var tableViewEventi: UITableView!
    @IBOutlet weak var buttonNomeProvincia: UIButton!
    @IBOutlet weak var buttonInfo: UIButton!
    @IBOutlet weak var labelEventiVuota: UILabel!
    @IBOutlet weak var constraintLabelVuota:NSLayoutConstraint!

    var caricamentoView=CaricamentoView.instanceFromNib()
    private let cManager = ConnectionManager()//AppDelegate.connectionManager
    private let refreshControl = UIRefreshControl()
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var viewRosa: UIView!
    private var viewGialla: UIView!
    private var animated=false
    var eventi:[Evento]!
    private var footerView:UIView!
    var numTotEventi = 0
    private var provinciaSelezionata:Provincia!
    private var requestType:RequestTypeList!
    private var loadedError:Bool!
    private var loaded:Bool!
    private var eventoSelezionato:Evento!
    var eventoCellSelezionato:EventoTableViewCell!
    var indexPathSelezionato:IndexPath!
    var yOfCellInSuperview:CGFloat!

    let transitionPresent = PresentAnimator()// will drive animated view controller transitions
    let transitionDismiss = DismissAnimator()
    var pool: AWSCognitoIdentityUserPool?
    var user: AWSCognitoIdentityUser?
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    
    func refresh() {
        self.addViews()
        if let p=UDManager.getProvincia() {
            self.provinciaSelezionata=p
        }else{
            self.provinciaSelezionata=Provincia(all: true)
        }
        self.refreshControl.addTarget(self, action: #selector(self.refreshEventi(_:)), for: .valueChanged)
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        if #available(iOS 10.0, *) {
            self.tableViewEventi.refreshControl = self.refreshControl
        } else {
            self.tableViewEventi.addSubview(self.refreshControl)
        }
        self.tableViewEventi.register(UINib(nibName: "EventoTableViewCell", bundle: nil), forCellReuseIdentifier: "CellIdentifierEvento")
        self.cManager.delegate=self
        
        self.buttonNomeProvincia.setTitle("\(self.provinciaSelezionata.nomeProvincia!)", for: .normal)
        self.tableViewEventi.alpha=0
        self.tableViewEventi.frame=CGRect(x: 0, y: self.view.frame.height, width: self.tableViewEventi.frame.size.width, height: self.tableViewEventi.frame.size.height)
        self.tabBarController?.tabBar.alpha=0
        self.tabBarController?.view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // buttonInfo.isHidden=true
        self.eventi=[Evento]()
        /*if UIScreen.main.bounds.height<=568 {
            labelEventiVuota.font = UIFont(name: labelEventiVuota.font.fontName, size: 20)
        }*/
        labelEventiVuota.isHidden=true
        cManager.delegate=self
        if UDManager.getIdentity()=="" {
            self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
            if (self.user == nil) {
                self.user = self.pool?.currentUser()
            //    print("self.user \(self.user)")
            }
        }
        self.refresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
         self.animateViews()
            Analytics.setScreenName("I_ListaEventi", screenClass: "EventiViewController")
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        setNeedsStatusBarAppearanceUpdate()
        cManager.delegate=self
        tableViewEventi.tableFooterView?.isHidden = true
        spinner.stopAnimating()
        requestType=RequestTypeList.refresh
        if UDManager.getIdentity() != "" {
            if self.eventi.count==0 {
                self.showLoading()
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                self.cManager.getEventi(ultimoEvento: nil)
            }
        }else{
            self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
                DispatchQueue.main.async(execute: {
              //      print("self.user \(self.user)")
                    self.response = task.result
                    UDManager.setIdUser(idUser: self.user!.username!)
                    if self.eventi.count==0 {
                        self.showLoading()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = true
                        self.cManager.getEventi(ultimoEvento: nil)
                    }
                })
                return nil
            }
            
        }
        
    }
    
    // MARK: - tableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.eventi.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return CGFloat(Height.eventoTableViewCell)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifierEvento", for: indexPath) as! EventoTableViewCell;
        if eventi != nil { //|| eventi.count > 0 {
            let ev=self.eventi[indexPath.row]
            cell.setData(ev: ev, tag: indexPath.row, prezzoHidden: false)
            return cell
        }
      return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (eventi.count < numTotEventi && indexPath.row==eventi.count-1 && !loadedError && !loaded) {
            loaded=true
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
            tableViewEventi.tableFooterView = spinner
            tableViewEventi.tableFooterView?.isHidden = false
            requestType=RequestTypeList.more
            cManager.getEventi(ultimoEvento: self.eventi[eventi.count-1])
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        eventoSelezionato=eventi[indexPath.row]
        eventoCellSelezionato=tableView.cellForRow(at: indexPath) as! EventoTableViewCell
        let rectOfCellInSuperview = tableViewEventi.convert(eventoCellSelezionato.frame, to: tableViewEventi.superview)
        yOfCellInSuperview=rectOfCellInSuperview.origin.y
        indexPathSelezionato=indexPath
        performSegue(withIdentifier: "GoToDettaglioEvento", sender: nil);
    }

    // MARK: - Private
    
    private func addViews(){
        viewRosa=UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.height*1.23, height: self.view.frame.height*1.23) )
        viewRosa.center=self.view.center
        self.viewRosa.layer.cornerRadius = self.viewRosa.frame.size.width / 2
        viewRosa.backgroundColor=UIColor.bvRedPink
        
        viewGialla=UIView(frame: CGRect(x: 0, y: 0, width:self.view.frame.size.height/1.35, height:self.view.frame.size.height/1.35))
        self.viewGialla.layer.cornerRadius = self.viewGialla.frame.size.width / 2
        viewGialla.center=CGPoint(x:0 , y: self.view.frame.size.height/3)
        viewGialla.backgroundColor=UIColor.bvDandelion
        self.view.insertSubview(viewRosa, at: 0)
        self.view.insertSubview(viewGialla, at: 0)
    }
    
    
    private func animateViews(){
        if animated==false {
            UIView.animate(withDuration: 0.5, animations:{
                self.viewRosa.frame = CGRect(x:self.view.frame.width/7.81, y:-self.view.frame.height/2.17, width:self.view.frame.size.height/1.35, height:self.view.frame.size.height/1.35)
                
                self.viewRosa.layer.cornerRadius=self.viewRosa.frame.size.width / 2
                
                self.viewGialla.frame = CGRect(x:self.view.frame.size.width/2-self.viewGialla.frame.size.width/2, y: -self.view.frame.size.height/2.5, width:self.viewGialla.frame.size.width, height:self.viewGialla.frame.size.height)
                self.tableViewEventi.frame=CGRect(x: 0, y:self.buttonNomeProvincia.frame.size.height+self.buttonNomeProvincia.frame.origin.y+6, width: self.tableViewEventi.frame.size.width, height: self.tableViewEventi.frame.size.height)
                
                self.tabBarController?.tabBar.alpha=1.0
                self.tableViewEventi.alpha=1.0
                
            })
            animated=true
        }
        constraintLabelVuota.constant=self.viewGialla.frame.origin.y+self.viewGialla.frame.size.height+10
    }
    
    
   /* @objc private func buttonPreferitoPressed(sender: UIButton){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        eventoSelezionato=eventi[sender.tag]
        var stato:Evento.Stato
        eventoSelezionato.statoEvento==Evento.Stato.null.rawValue ? (stato=Evento.Stato.preferito) : (stato=Evento.Stato.null)
        cManager.changeStatoEvento(evento:eventoSelezionato, stato: stato, numPartecipanti: 0)
    }*/
    
   private func showLoading(){
        caricamentoView.frame=CGRect(x:0,y:0,width:self.view.frame.size.width, height:self.view.frame.size.height)
        self.view.addSubview(caricamentoView)
        caricamentoView.activityIndicator?.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    private func hideLoading(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        caricamentoView.removeFromSuperview()
    }
    
    private func showAlert(titolo:String, msg:String){
        let alert = UIAlertController(title: titolo, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func requestIsFinished(){
        self.tableViewEventi.tableFooterView?.isHidden=true
        self.hideLoading()
        self.refreshControl.endRefreshing()
    }
    
    @objc private func refreshEventi(_ sender: Any) {
        requestType=RequestTypeList.refresh
        showLoading()
        cManager.getEventi(ultimoEvento: nil)
    }
    
    // MARK: - ProvinciaDelegate
    
    func provinciaChanged(provincia: Provincia) {
        requestType=RequestTypeList.refresh
        provinciaSelezionata=UDManager.getProvincia()
        refreshEventi(self)
        buttonNomeProvincia.setTitle("\(provinciaSelezionata.nomeProvincia!)", for: .normal)
    }
    
    // MARK: - EventoDelegate
    
    func statoEventoChanged(evento: Evento) {
        let e = eventi.filter( { return $0.idEvento == evento.idEvento })
        e[0].statoPreferitoEvento=evento.statoPreferitoEvento
        let indexPath=IndexPath(row: eventi.index(of: e[0])!, section: 0)
        tableViewEventi.reloadRows(at: [indexPath], with: .none)
    }
    
    // MARK: - ConnectionManagerDelegate
    
    func eventiDidReceive(ev:[Evento]?, numTotEventi:Int, errore:String){
        if errore==""{
            if(requestType==RequestTypeList.refresh){
                self.eventi=ev
                self.numTotEventi=numTotEventi
                DispatchQueue.main.async() {
                    self.tableViewEventi.reloadData()
                }
            }else{
                let c:Int=eventi.count
                self.eventi.append(contentsOf: ev!)
                let a:Int=eventi.count-1
                self.numTotEventi=numTotEventi
                var r: Array<IndexPath>=Array()
                for i in c...a {
                    let indexPath=IndexPath(row: i, section: 0)
                    r.append(indexPath)
                }
              DispatchQueue.main.async() {
                self.tableViewEventi.insertRows(at: r, with: .none)
            }
            }
           // print(self.eventi.count)
            loadedError=false
            DispatchQueue.main.async() {
                if self.numTotEventi==0{
                    self.labelEventiVuota.isHidden=false
                }else{
                    self.labelEventiVuota.isHidden=true
                }
            }
        }else{
            loadedError=true
            DispatchQueue.main.async() {
                self.showAlert(titolo: "Errore", msg: errore)
            }
        }
        DispatchQueue.main.async() {
            self.requestIsFinished()
        }
        loaded=false
    }
    
    func eventiDidReceiveWithError(error:Error){
        loadedError=true
        loaded=false
        DispatchQueue.main.async () {
            self.requestIsFinished()
            self.tableViewEventi.reloadData()
            self.showAlert(titolo: "Errore", msg: error.localizedDescription)
        }
    }
   
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToDettaglioEvento"{
            let edvc = segue.destination as! EventoDettaglioViewController
            edvc.evento=eventoSelezionato
            edvc.delegate=self
            edvc.transitioningDelegate = self
            edvc.fromEventi=true
        }else if segue.identifier=="GoToProvince"{
            let pvc = segue.destination as! ProvinceViewController
            pvc.delegate=self
        }
    }
}

extension EventiViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transitionPresent
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transitionDismiss
    }
    
}

