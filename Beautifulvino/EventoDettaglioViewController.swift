//
//  EventoDettaglioViewController.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 27/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit
import MapKit
import MessageUI
import Firebase

protocol EventoDelegate {
    func statoEventoChanged(evento: Evento)
}

class EventoDettaglioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ConnectionManagerDelegate, MFMailComposeViewControllerDelegate {
    
    var evento:Evento!
    var imageEvento:UIImage!
    private var vinoSelezionato:Vino!
    private var aziendaSelezionata:Azienda!
    private var iscrittoSelezionato:Utente!
    private var statoEventoAcqOld:String!
    private var statoEventoPrefOld:String!
    private let cManager = ConnectionManager() //AppDelegate.connectionManager
    var caricamentoView=CaricamentoView.instanceFromNib()
    private var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    private var viewTitleHiddenEvento=HiddenTitleView.instanceFromNib()
    var delegate: EventoDelegate!
    private var marginBig:CGFloat=80.0
    private var lastContentOffset: CGFloat = 0
    var fromEventi:Bool=false
    private var statusBarStyle=UIStatusBarStyle.lightContent
    private var altezzaViewBadgePiena:CGFloat=0
    private var pickerTextField:UITextField!
    
    private var hiddenTitleViewMargin:CGFloat!
    private var numPartecipanti=0
    private var acquisto=false
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewEvento: UIImageView!
    @IBOutlet weak var labelPrezzo: UILabel!
    @IBOutlet weak var buttonPreferito: UIButton!
    @IBOutlet weak var labelData: UILabel!
    @IBOutlet weak var labelLuogo: UILabel!
    @IBOutlet weak var labelTitolo: UILabel!
    @IBOutlet weak var textViewTema: UITextView!
    @IBOutlet weak var textViewTesto: UITextView!
    @IBOutlet weak var tableViewAziendaOspitante: UITableView!
    @IBOutlet weak var tableViewVini: UITableView!
    @IBOutlet weak var viewCardDove: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelCitta: UILabel!
    @IBOutlet weak var labelIndirizzo: UILabel!
    @IBOutlet weak var labelTelefono: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var labelMaxNumPartecipanti: UILabel!
    @IBOutlet weak var labelPostiDisponibili: UILabel!
    @IBOutlet weak var tableViewIscritti: UITableView!
    @IBOutlet weak var labelNomeBadge: UILabel!
    @IBOutlet weak var imageViewBadge: UIImageView!
    @IBOutlet weak var viewCardLocation: UIView!
    @IBOutlet weak var viewCardVini: UIView!
    @IBOutlet weak var viewCardBadge: UIView!
    @IBOutlet weak var viewCardPartecipanti: UIView!
    @IBOutlet weak var viewCardIscritti: UIView!
    @IBOutlet weak var buttonAcquistaPrenota: UIButton!
    @IBOutlet weak var viewTitleShadowEvento:UIView!
    @IBOutlet weak var viewDoveShadowEvento:UIView!
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var imageViewPin:UIImageView!
    
    @IBOutlet weak var heightConstraintContentView:NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cManager.delegate=self
        altezzaViewBadgePiena=viewCardBadge.frame.height
        showLoading(blocca: false, indicatorVisible: true)
        reloadView()
        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436{
            imageViewEvento.addBlackGradientLayer(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: imageViewEvento.frame.size.height), colors: [ UIColor(red: 0, green: 0, blue: 0, alpha: 0.5), UIColor(red: 0, green: 0, blue: 0, alpha: 0.4), UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), .clear, UIColor(red: 0, green: 0, blue: 0, alpha: 0.2), UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), .clear])
            hiddenTitleViewMargin=30
        } else{
            imageViewEvento.addBlackGradientLayer(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: imageViewEvento.frame.size.height), colors: [ UIColor(red: 0, green: 0, blue: 0, alpha: 0.5), UIColor(red: 0, green: 0, blue: 0, alpha: 0.4), .clear, UIColor(red: 0, green: 0, blue: 0, alpha: 0.2), UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), .clear])
            hiddenTitleViewMargin=20
        }
        tableViewAziendaOspitante.register(UINib(nibName: "FeedAziendaTableViewCell", bundle: nil), forCellReuseIdentifier: "CellIdentifierFeedAzienda")
        tableViewVini.register(UINib(nibName: "VinoTableViewCell", bundle: nil), forCellReuseIdentifier: "CellIdentifierVino")
        tableViewIscritti.register(UINib(nibName: "UtenteTableViewCell", bundle: nil), forCellReuseIdentifier: "CellIdentifierUtente")
        let nib = UINib(nibName: "TableSectionHeaderAzienda", bundle: nil)
        tableViewVini.register(nib, forHeaderFooterViewReuseIdentifier: "IdentifierSectionHeaderAzienda")
        let nibFooter = UINib(nibName: "TableSectionFooterVino", bundle: nil)
        tableViewVini.register(nibFooter, forHeaderFooterViewReuseIdentifier: "IdentifierSectionFooterVino")
        
        cManager.getEvento(eventoId: evento.idEvento, dataEvento: evento.dataEvento)
        self.viewTitleShadowEvento.frame=CGRect(x: viewTitleShadowEvento.frame.origin.x, y: viewTitleShadowEvento.frame.origin.y, width: self.view.frame.size.width-(viewTitleShadowEvento.frame.origin.x*2), height: viewTitleShadowEvento.frame.size.height)
        self.viewDoveShadowEvento.frame=CGRect(x: viewDoveShadowEvento.frame.origin.x, y: viewDoveShadowEvento.frame.origin.y, width: self.view.frame.size.width-(viewDoveShadowEvento.frame.origin.x*2), height: viewDoveShadowEvento.frame.size.height)
        
        self.viewTitleShadowEvento.setShadowAndCorners(corners: [.allCorners], x:0, y:0, offsetW: 0, offsetH: 0, cornerRadius: 4, colorBg: .white)
        self.viewDoveShadowEvento.setShadowAndCorners(corners: [.allCorners], x:0, y:0, offsetW: 0, offsetH: 0, cornerRadius: 4, colorBg: .white)
        
        labelPrezzo.layer.cornerRadius = 12.0
        labelPrezzo.clipsToBounds = true
        
        self.setButtonAcquista()
        if evento.titoloEvento==nil {
            evento.titoloEvento=""
        }
        self.addHiddenTitleView()
        
        self.buttonPreferito.setImage(#imageLiteral(resourceName: "buttonPreferitoOn"), for: .disabled)
        mapView.delegate=self
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(dismiss(fromGesture:)))
        view.addGestureRecognizer(gesture)
        
        labelEmail.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(EventoDettaglioViewController.tapSendMail)))
        labelTelefono.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(EventoDettaglioViewController.tapChiamaTelefono)))
        
    }
    
    @objc
    func tapSendMail(sender:UITapGestureRecognizer) {
        if evento.emailEvento != nil && evento.emailEvento != ""  {
            sendEmail()
        }
    }
    
    @objc
    func tapChiamaTelefono(sender:UITapGestureRecognizer) {
        guard let number = URL(string: "tel://" + evento.telefonoEvento) else { return }
        UIApplication.shared.openURL(number)
    }
    
    private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([labelEmail.text!])
            present(mail, animated: true)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cManager.delegate=self
        UIApplication.shared.statusBarStyle = statusBarStyle
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if evento.titoloEvento != "" {
            Analytics.setScreenName(evento.titoloEvento, screenClass: "EventoDettaglioViewController")
        }else{
            Analytics.setScreenName("EventoDettaglioViewController", screenClass: "EventoDettaglioViewController")
        }
    }
    
    // MARK: - ScrollView
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var yPos:CGFloat = -scrollView.contentOffset.y
        if (yPos > 0) {
            var imgRect:CGRect = imageViewEvento.frame
            imgRect.origin.y = scrollView.contentOffset.y
            imgRect.size.height = 200.0+yPos
            imageViewEvento.frame = imgRect
        }
        else {
            yPos = scrollView.contentOffset.y
            var imgRect: CGRect = imageViewEvento.frame
            imgRect.origin.y = scrollView.contentOffset.y/2
            imageViewEvento.frame = imgRect
        }
        
        // vertical
        //   let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
        let currentVerticalOffset:CGFloat = scrollView.contentOffset.y
        
        // percentages
        // CGFloat percentageHorizontalOffset = currentHorizontalOffset / maximumHorizontalOffset;
        // let percentageOffset:CGFloat = currentVerticalOffset / maximumVerticalOffset
        didScrollToPercentageOffset(currentVerticalOffset: currentVerticalOffset, moveUp:self.lastContentOffset > scrollView.contentOffset.y)
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func didScrollToPercentageOffset(currentVerticalOffset: CGFloat, moveUp:Bool){
        if currentVerticalOffset >= viewTitleShadowEvento.frame.origin.y {
            animateViews(hidden: false)
        }else if currentVerticalOffset < viewTitleShadowEvento.frame.origin.y{
            animateViews(hidden: true)
        }
        
        if currentVerticalOffset >= viewCardLocation.frame.origin.y-self.view.frame.size.height && !moveUp && viewCardLocation.alpha==0{
            viewCardLocation.fadeIn(y:textViewTesto.frame.origin.y+textViewTesto.frame.size.height)
        }
        
        if currentVerticalOffset <= viewCardLocation.frame.origin.y-self.view.frame.size.height+marginBig*2 && moveUp && viewCardLocation.alpha==1{
            viewCardLocation.fadeOut(y:textViewTesto.frame.origin.y+textViewTesto.frame.size.height+marginBig)
        }
        
        if currentVerticalOffset >= viewCardVini.frame.origin.y-self.view.frame.size.height && !moveUp && viewCardVini.alpha==0{
            viewCardVini.fadeIn( y:viewCardLocation.frame.origin.y+viewCardLocation.frame.size.height)
        }
        
        if currentVerticalOffset < viewCardVini.frame.origin.y-self.view.frame.size.height+marginBig*2 && moveUp && viewCardVini.alpha==1{
            viewCardVini.fadeOut(y:viewCardLocation.frame.origin.y+viewCardLocation.frame.size.height+marginBig)
        }
        
        if currentVerticalOffset >= viewCardDove.frame.origin.y-self.view.frame.size.height && !moveUp && viewCardDove.alpha==0 {
            viewCardDove.fadeIn(y:viewCardVini.frame.origin.y+viewCardVini.frame.size.height)
        }
        
        if currentVerticalOffset < viewCardDove.frame.origin.y-self.view.frame.size.height+marginBig*2 && moveUp && viewCardDove.alpha==1{
            viewCardDove.fadeOut(y:viewCardVini.frame.origin.y+viewCardVini.frame.size.height+marginBig)
        }
        
        if currentVerticalOffset > viewCardDove.frame.origin.y+viewCardDove.frame.size.height-self.view.frame.size.height+marginBig && !moveUp && viewCardPartecipanti.alpha==0{
            viewCardPartecipanti.fadeIn(y:viewCardDove.frame.origin.y+viewCardDove.frame.size.height)
        }
        
        if currentVerticalOffset <= viewCardDove.frame.origin.y+viewCardDove.frame.size.height-self.view.frame.size.height+marginBig*2 && moveUp && viewCardPartecipanti.alpha==1{
            viewCardPartecipanti.fadeOut(y:viewCardDove.frame.origin.y+viewCardDove.frame.size.height+marginBig)
        }
        
        if currentVerticalOffset >= viewCardPartecipanti.frame.origin.y+viewCardPartecipanti.frame.size.height-self.view.frame.size.height+marginBig  && !moveUp && viewCardIscritti.alpha==0{
            viewCardIscritti.fadeIn(y:viewCardPartecipanti.frame.origin.y+viewCardPartecipanti.frame.size.height)
        }
        
        if currentVerticalOffset <= viewCardPartecipanti.frame.origin.y+viewCardPartecipanti.frame.size.height-self.view.frame.size.height+marginBig*2 && moveUp && viewCardIscritti.alpha==1{
            viewCardIscritti.fadeOut(y:viewCardPartecipanti.frame.origin.y+viewCardPartecipanti.frame.size.height+marginBig)
        }
        
        if currentVerticalOffset >= viewCardIscritti.frame.origin.y+viewCardIscritti.frame.size.height-self.view.frame.size.height+marginBig && !moveUp && viewCardBadge.alpha==0{
            viewCardBadge.fadeIn(y:viewCardIscritti.frame.origin.y+viewCardIscritti.frame.size.height)
        }
        
        if currentVerticalOffset < viewCardIscritti.frame.origin.y+viewCardIscritti.frame.size.height-self.view.frame.size.height+marginBig*2 && moveUp && viewCardBadge.alpha==1{
            viewCardBadge.fadeOut(y:viewCardIscritti.frame.origin.y+viewCardIscritti.frame.size.height+marginBig)
        }

            self.contentView.frame.size=CGSize(width:self.view.frame.width, height:self.viewCardBadge.frame.origin.y+self.viewCardBadge.frame.size.height+10+self.marginBig)
            
            self.heightConstraintContentView.constant=self.contentView.frame.size.height
            self.scrollView.contentSize = self.contentView.frame.size
    }
    
    private func animateViews(hidden:Bool){
        if (hidden==true && viewTitleHiddenEvento.frame.origin.y == 0) {
            statusBarStyle = .lightContent
            UIApplication.shared.statusBarStyle = statusBarStyle
            setNeedsStatusBarAppearanceUpdate()
            UIView.animate(withDuration: 0.3, animations:{
                if self.evento.eventoAcquistabile(){
                    self.buttonAcquistaPrenota.isHidden=true
                    self.buttonAcquistaPrenota.frame = CGRect(x:self.buttonAcquistaPrenota.frame.origin.x, y:self.view.frame.size.height, width:self.buttonAcquistaPrenota.frame.size.width, height:self.buttonAcquistaPrenota.frame.size.height)
                }
                self.viewTitleHiddenEvento.isHidden=true
                self.viewTitleHiddenEvento.frame=CGRect(x:0, y:-self.viewTitleHiddenEvento.frame.size.height, width:self.viewTitleHiddenEvento.frame.size.width, height:self.viewTitleHiddenEvento.frame.size.height)
            })
        }else if (hidden==false && viewTitleHiddenEvento.frame.origin.y < 0) {
            statusBarStyle = .default
            UIApplication.shared.statusBarStyle = statusBarStyle
            setNeedsStatusBarAppearanceUpdate()
            UIView.animate(withDuration: 0.3, animations:{
                if self.evento.eventoAcquistabile(){
                    self.buttonAcquistaPrenota.isHidden=false
                    var bottom=CGFloat(0)
                    if #available(iOS 11.0, *) {
                        bottom = self.view.safeAreaInsets.bottom
                    }
                    self.buttonAcquistaPrenota.frame = CGRect(x:self.buttonAcquistaPrenota.frame.origin.x, y:self.view.frame.size.height - bottom - 12 - self.buttonAcquistaPrenota.frame.size.height, width:self.buttonAcquistaPrenota.frame.size.width, height:self.buttonAcquistaPrenota.frame.size.height)
                }
                self.viewTitleHiddenEvento.isHidden=false
                self.viewTitleHiddenEvento.frame=CGRect(x:0, y:0, width:self.viewTitleHiddenEvento.frame.size.width, height:self.viewTitleHiddenEvento.frame.size.height)
            })
        }
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView==tableViewAziendaOspitante {
            return 1
        }else if tableView==tableViewVini {
            //al massimo visualizzo 3 vini di un'azienda
            if evento.aziendeViniEvento[section].viniAzienda.count>3{
                return 3
            }else{
                return evento.aziendeViniEvento[section].viniAzienda.count
                
            }
        }else{
            return evento.iscrittiEvento.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        if tableView==tableViewVini{
            return evento.aziendeViniEvento.count
        }
        else{
            return 1
            
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView==tableViewVini {
            let cell = self.tableViewVini.dequeueReusableHeaderFooterView(withIdentifier: "IdentifierSectionHeaderAzienda")
            let header = cell as! TableSectionHeaderAzienda
            let az=evento.aziendeViniEvento[section]
            header.labelNomeAzienda.text=az.nomeAzienda
            header.tag=section
            let headerTapGesture = UITapGestureRecognizer()
            headerTapGesture.addTarget(self, action: #selector(EventoDettaglioViewController.sectionAziendaPressed(sender:)))
            cell?.addGestureRecognizer(headerTapGesture)
            return cell
        }else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView==tableViewVini {
            return CGFloat(Height.tableSectionHeaderAzienda)
        }else{
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView==tableViewVini {
            let cell = self.tableViewVini.dequeueReusableHeaderFooterView(withIdentifier: "IdentifierSectionFooterVino")
            // let footer = cell as! TableSectionFooterVino
            let headerTapGesture = UITapGestureRecognizer()
            headerTapGesture.addTarget(self, action: #selector(EventoDettaglioViewController.footerMostraAltriPressed(sender:)))
            cell?.addGestureRecognizer(headerTapGesture)
            return cell
        }else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView==tableViewVini {
            return CGFloat(Height.tableSectionFooterVino)
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if tableView == tableViewAziendaOspitante {
            return CGFloat(Height.feedAziendaTableViewCell)
        }else if tableView==tableViewVini {
            return CGFloat(Height.vinoTableViewCell)
        }else{
            return CGFloat(Height.utenteTableViewCell)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView==tableViewAziendaOspitante {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifierFeedAzienda", for: indexPath) as! FeedAziendaTableViewCell
            let azOs=evento.aziendaOspitanteEvento
            cell.setData(azienda:azOs!)
            return cell
        } else if tableView==tableViewVini {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifierVino", for: indexPath) as! VinoTableViewCell
            let v=evento.aziendeViniEvento[indexPath.section].viniAzienda[indexPath.row]
            cell.setData(vino: v)
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifierUtente", for: indexPath) as! UtenteTableViewCell
            let iscr=evento.iscrittiEvento[indexPath.row]
            cell.setData(utente: iscr)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if tableView==tableViewAziendaOspitante{
            aziendaSelezionata=evento.aziendaOspitanteEvento
            performSegue(withIdentifier: "GoToAziendaFromEvento", sender: nil);
        }else if tableView==tableViewVini{
            vinoSelezionato=evento.aziendeViniEvento[indexPath.section].viniAzienda[indexPath.row]
            performSegue(withIdentifier: "GoToVinoFromEvento", sender: nil);
        }else{
            iscrittoSelezionato=evento.iscrittiEvento[indexPath.row]
            performSegue(withIdentifier: "GoToUtenteFromEvento", sender: nil);
        }
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    // MARK: - IBAction
    
    @objc func dismiss(fromGesture gesture: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func sectionAziendaPressed(sender: UITapGestureRecognizer) {
        let tag = sender.view!.tag
        aziendaSelezionata=evento.aziendeViniEvento[tag]
        performSegue(withIdentifier: "GoToAziendaFromEvento", sender: nil)
    }
    
    @objc func footerMostraAltriPressed(sender: UITapGestureRecognizer) {
        let lvvc = ListaViniViewController(nibName: "ListaViniViewController", bundle: nil)
        lvvc.evento=evento
        self.present(lvvc, animated: true, completion: nil)
    }
    
    @IBAction func buttonChiudiPressed(){
        if fromEventi {
            delegate.statoEventoChanged(evento: evento)
        }
        dismiss(animated: true, completion: nil);
    }
    
    @IBAction func buttonAcquistaPressed(){
        if evento.numPostiDisponibiliEvento! <= 0 && evento.numMaxPartecipantiEvento! > 0 {
            let message="Che peccato, sei arrivato tardi! I posti disponibili per questo evento sono terminati. Ma non tutto è perduto: salva l'evento tra i preferiti e ti avvertiremo nel caso in cui ci fosse una maggiore disponibilità. Grazie!"
            let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title:"Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            showAlertsBiglietti()
        }
    }
    
    private func showAlertsBiglietti(){
        if (evento.numPostiDisponibiliEvento! > 0) {
            let pickerView = UIPickerView()
            pickerView.dataSource=self
            pickerView.delegate=self
            var strPrenotaAcquista="prenotare"
            var strPagherai="(pagherai direttamente all'evento)"
            if evento.acquistabileEvento != nil && evento.acquistabileEvento==Evento.Acqistabile.si.rawValue {
                strPrenotaAcquista="acquistare"
                strPagherai=""
            }
            let alert = UIAlertController(title: "", message: "Quanti biglietti desideri \(strPrenotaAcquista)?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField { (textField) in
                self.pickerTextField=textField
                textField.inputView = pickerView
                textField.text="1"
            }
            let action = UIAlertAction(title: "Conferma", style: .default) { (alertAction) in
                self.numPartecipanti=Int(self.pickerTextField.text!)!
                let totPrezzo=String(format:"%.2f",self.evento.prezzoEvento! * Double(self.numPartecipanti))
                let alert = UIAlertController(title: "", message: "Confermi di voler \(strPrenotaAcquista) \(self.numPartecipanti) posti per questo evento al prezzo di € \(totPrezzo)?\n\(strPagherai)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Sì", style: UIAlertActionStyle.default, handler: {_ in
                    self.acquisto=true
                    self.showLoading(blocca: true, indicatorVisible: false)
                    self.statoEventoAcqOld=self.evento.statoEvento
                    self.statoEventoPrefOld=self.evento.statoPreferitoEvento
                    if self.evento.acquistabileEvento != nil && self.evento.acquistabileEvento==Evento.Acqistabile.si.rawValue{
                        self.evento.statoEvento=Evento.StatoEvento.acquistato.rawValue
                    }else{
                        self.evento.statoEvento=Evento.StatoEvento.prenotato.rawValue
                    }
                    self.evento.statoPreferitoEvento=Evento.StatoPreferitoEvento.preferito.rawValue
                    self.setButtonsAcquistaPreferito()
                    self.cManager.changeStatoEvento(evento: self.evento, statoP: Evento.StatoPreferitoEvento.preferito.rawValue, statoA: Evento.StatoEvento.acquistato.rawValue, numPartecipanti: self.numPartecipanti)
                }))
                alert.addAction(UIAlertAction(title:"No", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            alert.addAction(action)
            alert.addAction(UIAlertAction(title:"Annulla", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func buttonPreferitoPressed(){
        if evento.statoEventoModificabile() {
            if evento.statoPreferitoEvento == Evento.StatoPreferitoEvento.preferito.rawValue {
                let alert = UIAlertController(title: "", message: "Sicuro di voler rimuovere questo evento dai preferiti?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Sì", style: .default, handler: {_ in
                    self.changePreferito()
                }))
                alert.addAction(UIAlertAction(title: "Annulla", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                changePreferito()
            }
        }else{
            var prenotati="prenotati"
            if (evento.acquistabileEvento==Evento.Acqistabile.si.rawValue){
                prenotati="acquistati"
            }
            self.showAlert(titolo: "Attenzione!", msg: "Non puoi cancellare gli eventi \(prenotati) fino alle ore 12:00 del giorno successivo all'evento.")
        }
    }
    
    
    private func changePreferito(){
        acquisto=false
        showLoading(blocca: false, indicatorVisible: false)
        statoEventoPrefOld=evento.statoPreferitoEvento
        statoEventoAcqOld=evento.statoEvento
        if(statoEventoPrefOld==nil || statoEventoPrefOld==Evento.StatoPreferitoEvento.null.rawValue){
            evento.statoPreferitoEvento=Evento.StatoPreferitoEvento.preferito.rawValue
            cManager.changeStatoEvento(evento:evento, statoP: Evento.StatoPreferitoEvento.preferito.rawValue, statoA: evento.statoEvento, numPartecipanti: 0)
        }else{
            evento.statoPreferitoEvento=Evento.StatoPreferitoEvento.null.rawValue
            cManager.changeStatoEvento(evento:evento, statoP: Evento.StatoPreferitoEvento.null.rawValue, statoA: evento.statoEvento, numPartecipanti: 0)
        }
        setButtonsAcquistaPreferito()
    }
    
    // MARK: - UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if  evento.numPostiDisponibiliEvento! <= 0 {
            return evento.numMaxPartecipantiEvento!
        }else{
            return evento.numPostiDisponibiliEvento!
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row+1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = String(row+1)
    }
    
    // MARK: - ConnectionManagerDelegate
    
    func eventoDidReceive(evento:Evento?, errore:String){
        if errore=="" {
            self.evento=evento
        }else{
            DispatchQueue.main.async() {
                self.showAlert(titolo: "Errore", msg: errore)
            }
        }
        DispatchQueue.main.async() {
            self.reloadView()
            self.hideLoading()
        }
    }
    
    func eventoDidReceiveWithError(error:Error){
        DispatchQueue.main.async() {
            self.hideLoading()
            self.showAlert(titolo: "Errore", msg: error.localizedDescription)
        }
    }
    
    func statoEventoIsChanged(errore:String){
        if errore != ""{
            evento.statoPreferitoEvento=statoEventoPrefOld
            evento.statoEvento=statoEventoAcqOld
            DispatchQueue.main.async() {
                self.setButtonsAcquistaPreferito()
                self.showAlert(titolo: "Errore", msg: errore)
            }
        }else{
            var prenotazione = "prenotazione"
            var prenotato = "prenotato"
            if evento.acquistabileEvento==Evento.Acqistabile.si.rawValue{
                prenotazione = "acquisto"
                prenotato = "acquistato"
            }
            if(self.acquisto){
                self.showAlert(titolo: "Conferma \(prenotazione)", msg: "Hai \(prenotato) \(self.numPartecipanti) posti per questo evento. Grazie!")
            }}
        DispatchQueue.main.async() {
            self.hideLoading()
        }
    }
    
    func statoEventoError(error:Error){
        evento.statoPreferitoEvento=statoEventoPrefOld
        evento.statoEvento=statoEventoAcqOld
        DispatchQueue.main.async () {
            self.hideLoading()
            self.setButtonsAcquistaPreferito()
            self.showAlert(titolo: "Errore", msg: error.localizedDescription)
        }
    }
    
    // MARK: - Private
    
    private func showAlert(titolo:String, msg:String){
        let alert = UIAlertController(title: titolo, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showLoading(blocca:Bool, indicatorVisible:Bool){
        if blocca {
            caricamentoView.frame=CGRect(x:0,y:0,width:self.view.frame.size.width,height:self.view.frame.size.height)
            self.view.addSubview(caricamentoView)
            caricamentoView.activityIndicator?.startAnimating()
        }else if indicatorVisible {
            actInd.frame=CGRect(x:0,y:0,width:40.0, height:40.0)
            actInd.center = view.center
            actInd.hidesWhenStopped = true
            actInd.activityIndicatorViewStyle =
                UIActivityIndicatorViewStyle.whiteLarge
            actInd.color=UIColor.bvRedPink
            view.addSubview(actInd)
            actInd.isHidden=false
            actInd.startAnimating()
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    private func hideLoading(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        actInd.isHidden=true
        actInd.removeFromSuperview()
        caricamentoView.removeFromSuperview()
    }
    
    private func setButtonsAcquistaPreferito(){
        evento.statoPreferitoEvento==nil || evento.statoPreferitoEvento==Evento.StatoPreferitoEvento.null.rawValue ? (self.buttonPreferito.setImage(#imageLiteral(resourceName: "buttonPreferitoOff"), for: .normal)) : (self.buttonPreferito.setImage(#imageLiteral(resourceName: "buttonPreferitoOn"), for: .normal))
        setAcquistaButtonTitle()
    }
    
    private func addHiddenTitleView(){
        viewTitleHiddenEvento.frame=CGRect(x:0, y:-self.viewTitleHiddenEvento.frame.size.height-hiddenTitleViewMargin, width:self.view.frame.size.width, height:self.viewTitleHiddenEvento.frame.size.height+hiddenTitleViewMargin)
        viewTitleHiddenEvento.create(title: evento.titoloEvento, action: #selector(EventoDettaglioViewController.buttonChiudiPressed))
        view.addSubview(viewTitleHiddenEvento)
        viewTitleHiddenEvento.isHidden=true
    }
    
    private func setButtonAcquista(){
        buttonAcquistaPrenota.isHidden=true
        buttonAcquistaPrenota.frame = CGRect(x:self.view.frame.origin.x+11, y:self.view.frame.size.height, width:self.view.frame.size.width-22, height:self.buttonAcquistaPrenota.frame.size.height)
        buttonAcquistaPrenota.addCornerRadius()
    }
    
    private func reloadView(){
        if(evento.aziendeViniEvento==nil){
            evento.aziendeViniEvento=[Azienda]()
            let az=Azienda()
            az.viniAzienda=[Vino]()
            evento.aziendeViniEvento.append(az)
        }
        if(evento.iscrittiEvento==nil){
            evento.iscrittiEvento=[Utente]()
        }
        if(evento.aziendaOspitanteEvento==nil){
            evento.aziendaOspitanteEvento=Azienda()
        }
        
        viewTitleHiddenEvento.labelTitle?.text=evento.titoloEvento
        if evento.imageEvento==nil{
            imageViewEvento.imageFromServerURL(urlString: evento.urlFotoEvento, imagePlaceholder: UIImage(named: "placeholder")!, completionBlock: {(data) in
                self.evento.imageEvento=data
            })
        }else{
            imageViewEvento.image=UIImage(data: evento.imageEvento)
        }
        
        labelPrezzo.text=evento.getPrezzoEvento()
        setButtonsAcquistaPreferito()
        labelLuogo.text=evento.cittaEvento
        labelData.text="\(evento.dataEvento.fromIntSince1970ToStringDate())"
        labelTitolo.text=evento.titoloEvento//"Degustazione di vino con l’oca Bianca"//
        var temaString=""
        if evento.temaEvento != nil {
            temaString=evento.temaEvento
        }
        let attributedString = NSMutableAttributedString(string: "Tema: \(temaString)", attributes: [
            .font: UIFont(name: "InterUI-Regular", size: 18.0)!,
            .foregroundColor: UIColor.bvPurpleBrown])
        attributedString.addAttribute(.font, value: UIFont(name: "InterUI-Bold", size: 18.0)!, range: NSRange(location: 0, length: 4))
        attributedString.addAttribute(.kern , value: 0.6, range: NSRange(location: 0, length: attributedString.length))
        textViewTema.attributedText=attributedString
        textViewTema.textContainerInset = .zero
        textViewTema.textContainer.lineFragmentPadding = 0
        
        var sizeThatFitsTextView = textViewTema.sizeThatFits(CGSize(width: textViewTema.frame.size.width, height: CGFloat(MAXFLOAT)))
        var heightOfText = sizeThatFitsTextView.height
        textViewTema.frame.size.height = heightOfText
        var htmlstring=htmlTextStyle
        if evento.testoEvento != nil {
            htmlstring.append(evento.testoEvento)
        }
        textViewTesto.attributedText=htmlstring.htmlToAttributedString
        textViewTesto.textContainerInset = .zero
        textViewTesto.textContainer.lineFragmentPadding = 0
        
        sizeThatFitsTextView = textViewTesto.sizeThatFits(CGSize(width: textViewTesto.frame.size.width, height: CGFloat(MAXFLOAT)))
        heightOfText = sizeThatFitsTextView.height
        textViewTesto.frame=CGRect(x:textViewTesto.frame.origin.x, y:textViewTema.frame.origin.y+textViewTema.frame.size.height+16.0, width:textViewTesto.frame.size.width, height:heightOfText)
        
        tableViewAziendaOspitante.reloadData()
        
        var transitionHeight:CGFloat=0
        
        if evento.aziendaOspitanteEvento.idAzienda != nil && evento.aziendaOspitanteEvento.idAzienda != "" {
            viewCardLocation.isHidden=false
            if textViewTesto.frame.origin.y+textViewTesto.frame.size.height <= self.view.frame.size.height {
                viewCardLocation.alpha=1
                viewCardLocation.frame=CGRect(x:viewCardLocation.frame.origin.x, y:textViewTesto.frame.origin.y+textViewTesto.frame.size.height, width:viewCardLocation.frame.size.width, height: CGFloat(Height.feedAziendaTableViewCell)+tableViewAziendaOspitante.frame.origin.y)
            }else{
                viewCardLocation.alpha=0
                viewCardLocation.frame=CGRect(x:viewCardLocation.frame.origin.x, y:textViewTesto.frame.origin.y+textViewTesto.frame.size.height+marginBig, width:viewCardLocation.frame.size.width, height: CGFloat(Height.feedAziendaTableViewCell)+tableViewAziendaOspitante.frame.origin.y)
            }
        }else{
            viewCardLocation.isHidden=true
            viewCardLocation.frame=CGRect(x:viewCardLocation.frame.origin.x, y:textViewTesto.frame.origin.y+textViewTesto.frame.size.height, width:tableViewAziendaOspitante.frame.size.width, height:0)
        }
        
        //VINI
        
        tableViewVini.reloadData()
        if evento.aziendeViniEvento.count == 0 {
            viewCardVini.isHidden=true
            viewCardVini.frame=CGRect(x:viewCardVini.frame.origin.x, y:viewCardLocation.frame.origin.y+viewCardLocation.frame.size.height, width:viewCardVini.frame.size.width, height:0.0)
        }else{
            var totalRows=0
            for i in 0..<tableViewVini.numberOfSections {
                totalRows=totalRows+tableViewVini.numberOfRows(inSection: i)
            }
            tableViewVini.frame=CGRect(x:tableViewVini.frame.origin.x, y:tableViewVini.frame.origin.y, width:tableViewVini.frame.size.width, height:23+(CGFloat(Height.tableSectionHeaderAzienda * Double(evento.aziendeViniEvento.count))+CGFloat(Height.tableSectionFooterVino*Double(evento.aziendeViniEvento.count))+(CGFloat(Height.vinoTableViewCell)*CGFloat(totalRows))))
            
            if viewCardLocation.frame.origin.y+viewCardLocation.frame.size.height <= self.view.frame.size.height {
                viewCardVini.alpha=1
                viewCardVini.frame=CGRect(x:viewCardVini.frame.origin.x, y:viewCardLocation.frame.origin.y+viewCardLocation.frame.size.height+transitionHeight-marginBig, width:viewCardVini.frame.size.width, height:tableViewVini.frame.origin.y+tableViewVini.frame.height)
            }else{
                viewCardVini.alpha=0
                viewCardVini.frame=CGRect(x:viewCardVini.frame.origin.x, y:viewCardLocation.frame.origin.y+viewCardLocation.frame.size.height+marginBig+transitionHeight, width:viewCardVini.frame.size.width, height:tableViewVini.frame.origin.y+tableViewVini.frame.height)
                transitionHeight=0.0
            }
        }
        //DOVE
        
        if viewCardVini.frame.origin.y+viewCardVini.frame.size.height <= self.view.frame.size.height {
            viewCardDove.alpha=1
            viewCardDove.frame=CGRect(x:viewCardDove.frame.origin.x, y:viewCardVini.frame.origin.y, width:viewCardDove.frame.size.width, height:viewCardDove.frame.size.height)
        }else{
            viewCardDove.alpha=0
            viewCardDove.frame=CGRect(x:viewCardDove.frame.origin.x, y:viewCardVini.frame.origin.y+viewCardVini.frame.size.height+marginBig, width:viewCardDove.frame.size.width, height:viewCardDove.frame.size.height)
            transitionHeight=0.0
        }
        
        addPinToMapView()
        labelIndirizzo.text=evento.indirizzoEvento
        labelCitta.text=evento.cittaEvento
        labelTelefono.text=evento.telefonoEvento
        labelEmail.text=evento.emailEvento
        
        //PARTECIPANTI
        viewCardPartecipanti.alpha=0
        
        viewCardPartecipanti.frame=CGRect(x:viewCardPartecipanti.frame.origin.x, y:viewCardDove.frame.origin.y+viewCardDove.frame.size.height+marginBig, width:viewCardPartecipanti.frame.size.width, height:viewCardPartecipanti.frame.size.height)
        if evento.numMaxPartecipantiEvento==nil || evento.numMaxPartecipantiEvento! < 0 {
            evento.numMaxPartecipantiEvento=0
        }
        
        if evento.numPostiDisponibiliEvento==nil || evento.numPostiDisponibiliEvento! < 0 {
            evento.numPostiDisponibiliEvento=0
        }
        
        if evento.numMaxPartecipantiEvento==0 && evento.numPostiDisponibiliEvento==0{
            evento.numPostiDisponibiliEvento=10
        }
        
        if evento.numMaxPartecipantiEvento==0 {
            labelMaxNumPartecipanti.text="Max: illimitati"
            labelPostiDisponibili.text="Disponibili: illimitati"
        }else{
            labelMaxNumPartecipanti.text="Max \(evento.numMaxPartecipantiEvento!)"
            labelPostiDisponibili.text="Disponibili ancora \(evento.numPostiDisponibiliEvento!) posti"
            
        }
        
        //ISCRITTI
        
        tableViewIscritti.reloadData()
        tableViewIscritti.frame=CGRect(x:tableViewIscritti.frame.origin.x, y:tableViewIscritti.frame.origin.y, width:tableViewIscritti.frame.size.width, height:(73.0 * CGFloat(tableViewIscritti.numberOfRows(inSection: 0))))
        
        viewCardIscritti.alpha=0
        if evento.iscrittiEvento.count == 0 {
            viewCardIscritti.isHidden=true
            viewCardIscritti.frame=CGRect(x:viewCardIscritti.frame.origin.x, y:viewCardPartecipanti.frame.origin.y+viewCardPartecipanti.frame.size.height, width:viewCardIscritti.frame.size.width, height:0.0)
        }else{
            viewCardIscritti.isHidden=false
            viewCardIscritti.frame=CGRect(x:viewCardIscritti.frame.origin.x, y:viewCardPartecipanti.frame.origin.y+viewCardPartecipanti.frame.size.height+marginBig, width:viewCardIscritti.frame.size.width, height:tableViewIscritti.frame.origin.y+tableViewIscritti.frame.height)
        }
        
        //BADGE
        if evento.badgeEvento==nil {
            viewCardBadge.isHidden=true
            viewCardBadge.frame=CGRect(x:viewCardBadge.frame.origin.x, y:viewCardIscritti.frame.origin.y+viewCardIscritti.frame.size.height, width:viewCardBadge.frame.size.width, height:0)
        }else{
            viewCardBadge.isHidden=false
            viewCardBadge.alpha=0
            viewCardBadge.frame=CGRect(x:viewCardBadge.frame.origin.x, y:viewCardIscritti.frame.origin.y+viewCardIscritti.frame.size.height, width:viewCardBadge.frame.size.width, height:altezzaViewBadgePiena)
            labelNomeBadge.text=evento.badgeEvento.nomeBadge
            imageViewBadge.imageFromServerURL(urlString: evento.badgeEvento.urlLogoBadge, imagePlaceholder: UIImage(named: "placeholder")!, completionBlock: {_ in })
        }
        
        contentView.frame.size=CGSize(width:self.view.frame.width, height:viewCardBadge.frame.origin.y+viewCardBadge.frame.size.height+10+marginBig)
        heightConstraintContentView.constant=contentView.frame.size.height
        self.scrollView.contentSize = contentView.frame.size
    }
    
    // MARK: - Map
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        openAppMap(coordinate:view.annotation!.coordinate)
    }
    
    func mapView(_ mapView: MKMapView!, viewFor annotation: MKAnnotation!) -> MKAnnotationView! {
        let annotationReuseId = "Place"
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationReuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationReuseId)
        } else {
            anView?.annotation = annotation
        }
        anView?.image = UIImage(named: "pinBig")
        anView?.backgroundColor = UIColor.clear
        anView?.canShowCallout = false
        return anView
    }
    
    
    private func addPinToMapView(){
        if evento.latitudineEvento != nil && evento.longitudineEvento != nil {
            let annotation = MKPointAnnotation()
            let coordinate=CLLocationCoordinate2D(latitude: evento.latitudineEvento, longitude: evento.longitudineEvento)
            annotation.coordinate=coordinate
            mapView.addAnnotation(annotation)
            let span = MKCoordinateSpanMake(0.00075, 0.00075)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: false)
            
        }
    }
    
    private func openAppMap(coordinate:CLLocationCoordinate2D){
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = evento.indirizzoEvento
        mapItem.openInMaps(launchOptions: nil)//[MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    private func setAcquistaButtonTitle(){
        var title=""
        var attributedString: NSMutableAttributedString
        if evento.acquistabileEvento != nil && evento.acquistabileEvento==Evento.Acqistabile.si.rawValue{
            title="Acquista"
        }else{
            title="Prenota"
        }
        attributedString = NSMutableAttributedString(string: "\(title) (\(evento.getPrezzoEvento()) )", attributes: [
            .font: UIFont(name: "Larsseit", size: 16.0)!,
            .foregroundColor: UIColor(red: 70.0 / 255.0, green: 43.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0),
            .kern: 0.5
            ])
        attributedString.addAttribute(.font, value: UIFont(name: "Larsseit-Bold", size: 18.0)!, range: NSRange(location: 0, length: title.count))
        
        buttonAcquistaPrenota.setAttributedTitle(attributedString, for: .normal)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "GoToVinoFromEvento"{
            let vdvc = segue.destination as! VinoDettaglioViewController
            vdvc.vino=vinoSelezionato
        }else if segue.identifier == "GoToUtenteFromEvento"{
            let pvc = segue.destination as! ProfiloViewController
            pvc.utente=iscrittoSelezionato
            pvc.fromTabBar=false
        }else if segue.identifier == "GoToAziendaFromEvento"{
            let advc = segue.destination as! AziendaDettaglioViewController
            advc.azienda=aziendaSelezionata
        }
    }
    
}
