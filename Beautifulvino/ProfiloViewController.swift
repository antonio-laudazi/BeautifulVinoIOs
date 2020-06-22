//
//  ProfiloViewController.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 27/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSCognito
import Firebase

class ProfiloViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ConnectionManagerDelegate, UtenteDelegate
{
    
    @IBOutlet weak var buttonChiudi:UIButton!
    @IBOutlet weak var labelTitoloTableViewVuota:UILabel!
    @IBOutlet weak var labelTestoTableViewVuota:UILabel!

    @IBOutlet weak var segmentedControl:UISegmentedControl!
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var tableViewVini:UITableView!
    @IBOutlet weak var pageControl:UIPageControl!
    @IBOutlet weak var constraintLabelVuota:NSLayoutConstraint!

    var contentViewFirst=ViewContentProfiloF.instanceFromNib()
    var contentViewSecond=ViewContentProfiloS.instanceFromNib()
    
    private var sectionEventi:[String]=["",""]
    private var sectionBadge:[String]=["",""]
    private var vinoSelezionato:Vino!
    private var aziendaSelezionata:Azienda!
    private var eventoSelezionato:Evento!
    private var badgeArrayOrdinati=[[Badge](),[Badge]()]
   // private var eventiArrayOrdinati=[[Evento](),[Evento]()]
    private var statoUtenteOld:String!
    
    private var viewRosa=UIView()
    private var viewGialla=UIView()
    
    private var mioProfilo=true
    private let cManager = ConnectionManager()//AppDelegate.connectionManager
    var caricamentoView=CaricamentoView.instanceFromNib()
    private var requestType:RequestTypeList!
    var utente:Utente!
    var fromTabBar:Bool=true
    
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelTitoloTableViewVuota.isHidden=true
        labelTestoTableViewVuota.isHidden=true
        if utente==nil {
            self.utente=Utente()
        }
       /* if UIScreen.main.bounds.height<=568 {
            labelTableViewVuota.font = UIFont(name: labelTableViewVuota.font.fontName, size: 20)
        }*/
        if UDManager.getIdentity()=="" {
            self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
            if (self.user == nil) {
                self.user = self.pool?.currentUser()
            }
        }
        self.refresh()
        createArrays()
    }
    
    func refresh() {
        tableView.register(UINib(nibName: "EventoTableViewCell", bundle: nil), forCellReuseIdentifier: "CellIdentifierEvento");
        tableView.register(UINib(nibName: "BadgeTableViewCell", bundle: nil), forCellReuseIdentifier: "CellIdentifierBadge");
        tableViewVini.register(UINib(nibName: "VinoTableViewCell", bundle: nil), forCellReuseIdentifier: "CellIdentifierVino");
        let nib = UINib(nibName: "TableSectionHeaderAzienda", bundle: nil)
        tableViewVini.register(nib, forHeaderFooterViewReuseIdentifier: "IdentifierSectionHeaderAzienda")
        createSegmentedControl()
        contentViewFirst.frame=CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.scrollView.frame.height)
        contentViewSecond.frame=CGRect(x:  self.view.frame.width, y:0, width: self.view.frame.width, height: self.scrollView.frame.height)
        scrollView.frame=CGRect(x: 0, y:0, width: self.view.frame.width, height: self.scrollView.frame.height)
        
        scrollView.addSubview(contentViewFirst)
        scrollView.addSubview(contentViewSecond)
        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.width * 2, height:self.scrollView.frame.height)
        self.scrollView.delegate = self
        
        if segmentedControl.selectedSegmentIndex != 1 {
            tableViewVini.isHidden=true
            tableView.isHidden=false
        }else {
            tableViewVini.isHidden=false
            tableView.isHidden=true
        }
        contentViewFirst.buttonSegui.addTarget(self, action:#selector(buttonSeguiPressed), for: .touchUpInside)
        contentViewFirst.buttonModifica.addTarget(self, action:#selector(buttonModificaPressed), for: .touchUpInside)
        
        self.pageControl.currentPage = 0
        cManager.delegate=self
        addViews()
        viewRosa.isHidden=true
        viewGialla.isHidden=true
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(dismiss(fromGesture:)))
        view.addGestureRecognizer(gesture)
    }
    
    @objc func dismiss(fromGesture gesture: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewRosa.isHidden=true
        viewGialla.isHidden=true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewRosa.isHidden=false
        viewGialla.isHidden=false
        Analytics.setScreenName("I_Profilo", screenClass: "ProfiloViewController")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        setNeedsStatusBarAppearanceUpdate()
        if segmentedControl.selectedSegmentIndex != 1 {
            tableViewVini.isHidden=true
            tableView.isHidden=false
        }else {
            tableViewVini.isHidden=false
            tableView.isHidden=true
        }
        
        cManager.delegate=self
        showLoading()
        if UDManager.getIdentity() != "" {
            if utente.idUtente==nil || utente.idUtente==UDManager.getIdUser(){
                mioProfilo=true
                cManager.getUtente(idUtente: UDManager.getIdUser())
            }else{
                mioProfilo=false
                labelTitoloTableViewVuota.isHidden=true
                labelTestoTableViewVuota.isHidden=true
                setButtonSegui()
                cManager.getUtente(idUtente: utente.idUtente)
            }
            self.buttonChiudi.isHidden=fromTabBar
            self.contentViewFirst.buttonModifica.isHidden = !self.mioProfilo
            self.contentViewFirst.buttonSegui.isHidden=self.mioProfilo
        }else{
            self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
                DispatchQueue.main.async(execute: {
                    self.response = task.result
                    UDManager.setIdUser(idUser: self.user!.username!)
                    if self.utente.idUtente==nil || self.utente.idUtente==UDManager.getIdUser(){
                        self.mioProfilo=true
                        self.cManager.getUtente(idUtente: UDManager.getIdUser())
                    }else{
                        self.mioProfilo=false
                        self.cManager.getUtente(idUtente: self.utente.idUtente)
                    }
                    self.buttonChiudi.isHidden=self.fromTabBar
                    self.contentViewFirst.buttonModifica.isHidden = !self.mioProfilo
                    self.contentViewFirst.buttonSegui.isHidden=self.mioProfilo
                })
                return nil
            }
        }
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView==tableViewVini {
            return utente.aziendeUtente[section].viniAzienda.count
        }else{
            if segmentedControl.selectedSegmentIndex==0 {
                return utente.eventiUtente.count//eventiArrayOrdinati[section].count
            }else{
                return badgeArrayOrdinati[section].count
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        if tableView==tableViewVini {
            return utente.aziendeUtente.count
        }else{
            if segmentedControl.selectedSegmentIndex==0 {
                return 1
            }else{
                return sectionBadge.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView==tableViewVini{
            return 30
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView==tableViewVini{
            let vw = UIView()
            vw.backgroundColor = UIColor.clear
            let viewShadow = UIView(frame: CGRect(x: 15, y: 0, width: self.view.frame.size.width-31, height: 30))
            viewShadow.setShadowAndCorners(corners: [.bottomLeft, .bottomRight], x:0, y:20, offsetW: 0, offsetH: -20, cornerRadius: 10, colorBg: .white)
            vw.addSubview(viewShadow)
            return vw
        }else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView==tableViewVini  {
            let cell = self.tableViewVini.dequeueReusableHeaderFooterView(withIdentifier: "IdentifierSectionHeaderAzienda")
            let header = cell as! TableSectionHeaderAzienda
            header.labelNomeAzienda.text=utente.aziendeUtente[section].nomeAzienda
            let headerTapGesture = UITapGestureRecognizer()
            headerTapGesture.addTarget(self, action: #selector(ProfiloViewController.sectionAziendaPressed(sender:)))
            cell?.addGestureRecognizer(headerTapGesture)
            cell?.tag=section
            return cell
        } else {
            let vw = UIView()
            vw.backgroundColor = UIColor.white
            let label = UILabel(frame: CGRect(x: 25, y: 32, width: self.view.frame.size.width-10, height: 25))
            label.textColor=UIColor.bvRedPink
            label.font = UIFont.bvUiTextTitoloListaViniFont()
            if segmentedControl.selectedSegmentIndex==0{
                label.text=sectionEventi[section]
                if sectionEventi[section]==""{
                    return nil
                }
            }else{
                label.text=sectionBadge[section]
                if sectionBadge[section]==""{
                    return nil
                }
            }
            vw.addSubview(label)
            return vw
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView != tableViewVini  {
            if segmentedControl.selectedSegmentIndex==0{
                if sectionEventi[section]==""{
                    return 0
                }
            }else{
                if sectionBadge[section]==""{
                    return 0
                }
            }
        }
        return CGFloat(Height.tableSectionHeaderAzienda)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if tableView==tableViewVini {
            return CGFloat(Height.vinoTableViewCell)
        }else{
            if segmentedControl.selectedSegmentIndex==0{
                return CGFloat(Height.eventoTableViewCell)
            }else{
                return CGFloat(Height.badgeTableViewCell)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView==tableViewVini {
            let cell = tableViewVini.dequeueReusableCell(withIdentifier: "CellIdentifierVino", for: indexPath) as! VinoTableViewCell
            let az=utente.aziendeUtente[indexPath.section]
            let vino=az.viniAzienda[indexPath.row]
            cell.setData(vino: vino)
            return cell
        }else if segmentedControl.selectedSegmentIndex==0 && tableView==self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifierEvento", for: indexPath) as! EventoTableViewCell
            let ev=utente.eventiUtente[indexPath.row]
            cell.setData(ev: ev, tag: indexPath.row, prezzoHidden: mioProfilo)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifierBadge", for: indexPath) as! BadgeTableViewCell
            let b=badgeArrayOrdinati[indexPath.section][indexPath.row]
            cell.setData(badge: b)
            if indexPath.section != 0{
                cell.viewOpacityBadge.isHidden=false
            }else{
                cell.viewOpacityBadge.isHidden=true
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView==self.tableView && segmentedControl.selectedSegmentIndex==0{
            eventoSelezionato=utente.eventiUtente[indexPath.row]
            performSegue(withIdentifier: "GoToDettaglioEventoFromProfilo", sender: nil)
            tableView.deselectRow(at: indexPath, animated: false)
        }else if segmentedControl.selectedSegmentIndex==1{
            let az=utente.aziendeUtente[indexPath.section]
            vinoSelezionato=az.viniAzienda[indexPath.row]
            performSegue(withIdentifier: "GoToDettaglioVinoFromProfilo", sender: nil)
            tableViewVini.deselectRow(at: indexPath, animated: false)
        }else if segmentedControl.selectedSegmentIndex==2{
           let badgeSelezionato=badgeArrayOrdinati[indexPath.section][indexPath.row]
            eventoSelezionato=badgeSelezionato.eventoBadge
            if eventoSelezionato != nil{
                performSegue(withIdentifier: "GoToDettaglioEventoFromProfilo", sender: nil)
            }
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        self.pageControl.currentPage = Int(currentPage);
    }
    
    // MARK: - IBAction
    
    @objc func sectionAziendaPressed(sender: UITapGestureRecognizer) {
        let senderView = sender.view as! TableSectionHeaderAzienda
        aziendaSelezionata=utente.aziendeUtente[senderView.tag]
        performSegue(withIdentifier: "GoToDettaglioAziendaFromProfilo", sender: nil)
    }
    
    @IBAction func buttonModificaPressed(){
        performSegue(withIdentifier: "GoToImpostazioniFromProfilo", sender: nil)
    }
    
    @IBAction func buttonSeguiPressed(){
        showLoading()
        statoUtenteOld=utente.statoUtente
        if utente.statoUtente==nil || utente.statoUtente==Utente.Stato.null.rawValue {
            utente.statoUtente=Utente.Stato.seguito.rawValue
            cManager.changeStatoUtente(idUtente:utente.idUtente, stato: Utente.Stato.seguito)
        }else{
            utente.statoUtente=Utente.Stato.null.rawValue
            cManager.changeStatoUtente(idUtente:utente.idUtente, stato: Utente.Stato.null)
        }
        setButtonSegui()
    }
    
    @IBAction func segmentedControlValueChange(){
        var tableV=tableView!
        if segmentedControl.selectedSegmentIndex != 1 {
            tableViewVini.isHidden=true
            tableView.isHidden=false
        }else {
            tableViewVini.isHidden=false
            tableView.isHidden=true
            tableV=tableViewVini
        }
        
        if mioProfilo {
            if segmentedControl.selectedSegmentIndex == 0 {
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: "id-Profilo",
                    AnalyticsParameterItemName: "Profilo",
                    AnalyticsParameterContentType: "EventiProfilo"
                    ])
                if(utente.eventiUtente==nil || utente.eventiUtente.count==0){
                    labelTitoloTableViewVuota.isHidden=false
                    labelTestoTableViewVuota.isHidden=false
                    labelTitoloTableViewVuota.text="Non hai ancora partecipato a nessun evento e non hai eventi in programma.\n"
                    labelTestoTableViewVuota.text="Che ne dici di dare un’occhiata ai prossimi eventi?"
                }else{
                    labelTitoloTableViewVuota.isHidden=true
                    labelTestoTableViewVuota.isHidden=true
                }
            }else if segmentedControl.selectedSegmentIndex == 1  {
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: "id-Profilo",
                    AnalyticsParameterItemName: "Profilo",
                    AnalyticsParameterContentType: "ViniProfilo"
                    ])
                if(utente.aziendeUtente==nil || utente.aziendeUtente.count==0){
                    labelTitoloTableViewVuota.isHidden=false
                    labelTestoTableViewVuota.isHidden=false
                    labelTitoloTableViewVuota.text="La tua carta dei vini è vuota… sei astemio per caso?\n"
                    labelTestoTableViewVuota.text="Inizia a degustare partecipando ai nostri eventi e tieni traccia dei vini: finalmente saprai cosa ordinare al ristorante!"
                }else{
                    labelTitoloTableViewVuota.isHidden=true
                    labelTestoTableViewVuota.isHidden=true
                }
            }else{
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: "id-Profilo",
                    AnalyticsParameterItemName: "Profilo",
                    AnalyticsParameterContentType: "BadgeProfilo"
                    ])
                if(utente.badgeUtente==nil || utente.badgeUtente.count==0){
                    labelTitoloTableViewVuota.isHidden=false
                    labelTestoTableViewVuota.isHidden=false
                    labelTitoloTableViewVuota.text="Non hai ancora guadagnato nessun badge.\n"
                    labelTestoTableViewVuota.text="Partecipa agli eventi e colleziona esperienze.\nSalirai di livello e diventerai un degustatore sempre migliore!"
                }else{
                    labelTitoloTableViewVuota.isHidden=true
                    labelTestoTableViewVuota.isHidden=true
                }
            }
        }else{
            labelTitoloTableViewVuota.isHidden=true
            labelTestoTableViewVuota.isHidden=true
        }
        segmentedControl.changeUnderlinePosition()
        tableV.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        if tableV.numberOfSections != 0  && tableV.numberOfRows(inSection: 0) != 0{
            tableV.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        
    }
    
    @IBAction func buttonChiudiPressed(){
        dismiss(animated: true, completion: nil);
    }
    
    // MARK: - Private
    
    private func addViews(){
        viewRosa.frame = CGRect(x:0, y:-self.view.frame.height/2.13, width: self.view.frame.height/1.26, height: self.view.frame.height/1.26)
        viewRosa.backgroundColor=UIColor.bvRedPink
        self.viewGialla.frame = CGRect(x:self.viewGialla.frame.size.width/2-self.view.frame.size.width/2, y: -self.view.frame.size.height/3, width:self.view.frame.size.height/1.26, height:self.view.frame.size.height/1.26)
        self.viewGialla.center=CGPoint(x:self.view.frame.size.width/2, y:viewGialla.center.y)
        self.viewRosa.center=CGPoint(x:self.view.frame.size.width/2, y:viewRosa.center.y)
        viewGialla.backgroundColor=UIColor.bvDandelion
        
        self.viewRosa.layer.cornerRadius = self.viewRosa.frame.size.width / 2
        self.viewGialla.layer.cornerRadius = self.viewGialla.frame.size.width / 2
        
        self.view.insertSubview(viewRosa, at: 0)
        self.view.insertSubview(viewGialla, at: 0)
        constraintLabelVuota.constant=self.viewGialla.frame.origin.y+self.viewGialla.frame.size.height+10
    }
    
    private func setButtonSegui(){
        if utente.statoUtente != nil && utente.statoUtente != Utente.Stato.null.rawValue {
            contentViewFirst.buttonSegui.setTitleColor(UIColor.white, for: .normal)
            contentViewFirst.buttonSegui.setTitle("SEGUITO", for: .normal)
            contentViewFirst.buttonSegui.backgroundColor = UIColor.bvRedPink
            contentViewFirst.buttonSegui.layer.cornerRadius = contentViewFirst.buttonSegui.frame.size.height/2
            contentViewFirst.buttonSegui.layer.borderWidth = 2
            contentViewFirst.buttonSegui.layer.borderColor = UIColor.white.cgColor
            contentViewFirst.buttonSegui.clipsToBounds = true
        }else{
            contentViewFirst.buttonSegui.setTitleColor(UIColor.bvRedPink, for: .normal)
            contentViewFirst.buttonSegui.setTitle("SEGUI", for: .normal)
            contentViewFirst.buttonSegui.backgroundColor = UIColor.white
            contentViewFirst.buttonSegui.layer.cornerRadius = contentViewFirst.buttonSegui.frame.size.height/2
            contentViewFirst.buttonSegui.layer.borderWidth = 0
            contentViewFirst.buttonSegui.clipsToBounds = true
        }
    }
    
    private func createSegmentedControl(){
        segmentedControl.tintColor = UIColor.clear
        segmentedControl.backgroundColor = UIColor.white
        segmentedControl.layer.cornerRadius = 25
        
        segmentedControl.layer.shadowColor = UIColor.black.cgColor
        segmentedControl.layer.shadowOpacity = 0.1
        segmentedControl.layer.shadowOffset = CGSize(width: 0, height: 4.0)
        segmentedControl.layer.shadowRadius = 17//blur
        segmentedControl.layer.shadowPath = UIBezierPath(roundedRect: segmentedControl.bounds, cornerRadius: 25).cgPath
        
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor(red: 70.0 / 255.0, green: 43.0 / 255.0, blue: 53.0 / 255.0, alpha: 0.4), NSAttributedStringKey.font: UIFont(name: "Larsseit-Medium", size: 11.0)!], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor(red: 70.0 / 255.0, green: 43.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0), NSAttributedStringKey.font: UIFont(name: "Larsseit-Medium", size: 11.0)!], for: .selected)
        segmentedControl.addUnderlineForSelectedSegment()
        
    }
    
    private func createSectionString(){
        if badgeArrayOrdinati[0].count==0 {
            //    mioProfilo==true ? (sectionBadge[0]="") : (sectionBadge[0]="")
        }else{
            //  mioProfilo==true ? (sectionBadge[0]="") : (sectionBadge[0]="")
        }
        if badgeArrayOrdinati[1].count==0 {
            sectionBadge[1]=""
        }else{
            mioProfilo==true ? (sectionBadge[1]="Guadagna altri badge") : (sectionBadge[1]="")
        }
        
       /* if eventiArrayOrdinati[0].count==0 {
            //     mioProfilo==true ? (sectionEventi[0]="") : (sectionEventi[0]="")
        }else{
            //    mioProfilo==true ? (sectionEventi[0]="") : (sectionEventi[0]="")
        }
        
        if eventiArrayOrdinati[1].count==0 {
            sectionEventi[1] = ""
        }else{
            sectionEventi[1] = "Eventi passati"
        }*/
    }
    
    private func createArrays(){
        if(utente.aziendeUtente==nil){
            utente.aziendeUtente=[Azienda]()
        }
        if(utente.badgeUtente==nil){
            utente.badgeUtente=[Badge]()
        }
        if(utente.eventiUtente==nil){
            utente.eventiUtente=[Evento]()
        }
        badgeArrayOrdinati[0].removeAll()
        badgeArrayOrdinati[1].removeAll()
        for b in utente.badgeUtente {
            if b.tuoBadge == Badge.Stato.tuoBadge.rawValue{
                badgeArrayOrdinati[0].append(b)
            }else{
                if mioProfilo{
                    badgeArrayOrdinati[1].append(b)
                }
            }
        }
    }
    
    private func reloadView(){
        createArrays()
        createSectionString()
        //segmentedControl.selected va impostato a 0 ?
        tableView.reloadData()
        tableViewVini.reloadData()
        contentViewFirst.create(utente:utente, mioProfilo: mioProfilo)
        contentViewSecond.create(utente:utente)
        if !mioProfilo {
            setButtonSegui()
        }
    }
    
    private func showAlert(titolo:String, msg:String){
        let alert = UIAlertController(title: titolo, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showLoading(){
        /*  caricamentoView.frame=CGRect(x:0,y:0,width:self.view.frame.size.width,height:self.view.frame.size.height)
         self.view.addSubview(caricamentoView)
         caricamentoView.activityIndicator?.startAnimating()*/
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    private func hideLoading(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        //    caricamentoView.removeFromSuperview()
    }
    
    // MARK: - ConnectionManagerDelegate
    
    func utenteChanged() {
        //   showLoading()
        //   cManager.getUtente(idUtente: UDManager.getIdUser())
    }
    
    // MARK: - ConnectionManagerDelegate
    
    func utenteDidReceive(utente:Utente?, errore:String){
        if errore=="" {
            self.utente=utente
        }else{
            showAlert(titolo: "Errore", msg: errore)
        }
        DispatchQueue.main.async() {
            self.segmentedControlValueChange()
            self.reloadView()
            self.hideLoading()
        }
    }
    
    func utenteDidReceiveWithError(error:Error){
        DispatchQueue.main.async() {
            self.hideLoading()
            self.showAlert(titolo: "Errore", msg: error.localizedDescription)
            self.reloadView()
        }
    }
    
    func statoUtenteIsChanged(errore:String){
        if errore != "" {
            utente.statoUtente=statoUtenteOld
            DispatchQueue.main.async() {
                self.setButtonSegui()
                self.showAlert(titolo: "Errore", msg: errore)
            }
        }
        DispatchQueue.main.async() {
            self.hideLoading()
        }
    }
    
    func statoUtenteError(error:Error){
        utente.statoUtente=statoUtenteOld
        DispatchQueue.main.async () {
            self.setButtonSegui()
            self.hideLoading()
            self.showAlert(titolo: "Errore", msg: error.localizedDescription)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "GoToDettaglioVinoFromProfilo"{
            let vdvc = segue.destination as? VinoDettaglioViewController
            vdvc?.vino=vinoSelezionato
        }else if segue.identifier == "GoToDettaglioEventoFromProfilo"{
            let edvc = segue.destination as? EventoDettaglioViewController
            edvc?.evento=eventoSelezionato
        }else if segue.identifier == "GoToDettaglioAziendaFromProfilo"{
            let advc = segue.destination as? AziendaDettaglioViewController
            advc?.azienda=aziendaSelezionata
        }else if segue.identifier == "GoToImpostazioniFromProfilo"{
            let ivc = segue.destination as? ImpostazioniViewController
            ivc?.delegate=self
        }
    }
    
    
}
