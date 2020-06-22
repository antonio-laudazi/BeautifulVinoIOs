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

class AziendaDettaglioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, ConnectionManagerDelegate, MFMailComposeViewControllerDelegate {
    
    public var azienda:Azienda!
    private var vinoSelezionato:Vino!
    private var eventoSelezionato:Evento!
    private let cManager = ConnectionManager()//AppDelegate.connectionManager
  //  var caricamentoView=CaricamentoView.instanceFromNib()
    private var viewTitleHiddenAzienda=HiddenTitleView.instanceFromNib()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelNome: UILabel!
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var labelCittaRegione: UILabel!
    @IBOutlet weak var textViewTesto: UITextView!
    @IBOutlet weak var viewCardDove: UIView!
    @IBOutlet weak var tableViewVini: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelCitta: UILabel!
    @IBOutlet weak var labelIndirizzo: UILabel!
    @IBOutlet weak var labelTelefono: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var labelSito: UILabel!
    @IBOutlet weak var tableViewEventi: UITableView!
    @IBOutlet weak var viewDoveShadow:UIView!
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var viewCardEventi:UIView!
    @IBOutlet weak var heightConstraintContentView:NSLayoutConstraint!
    
    private var marginSmall:CGFloat=20.0
    private var marginBig:CGFloat=80.0
    private var lastContentOffset: CGFloat = 0
    private var statusBarStyle=UIStatusBarStyle.lightContent
    private var hiddenTitleViewMargin:CGFloat!
    private var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436{
            imageView.addBlackGradientLayer(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: imageView.frame.size.height), colors: [ UIColor(red: 0, green: 0, blue: 0, alpha: 0.5), UIColor(red: 0, green: 0, blue: 0, alpha: 0.4), UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), .clear, UIColor(red: 0, green: 0, blue: 0, alpha: 0.2), UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), .clear])
            hiddenTitleViewMargin=30
        } else{
            imageView.addBlackGradientLayer(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: imageView.frame.size.height), colors: [ UIColor(red: 0, green: 0, blue: 0, alpha: 0.5), UIColor(red: 0, green: 0, blue: 0, alpha: 0.4), .clear, UIColor(red: 0, green: 0, blue: 0, alpha: 0.2), UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), .clear])
            hiddenTitleViewMargin=20
        }
        tableViewEventi.register(UINib(nibName: "EventoTableViewCell", bundle: nil), forCellReuseIdentifier: "CellIdentifierEvento")
        tableViewVini.register(UINib(nibName: "VinoTableViewCell", bundle: nil), forCellReuseIdentifier: "CellIdentifierVino")
        let nib = UINib(nibName: "TableSectionHeaderAzienda", bundle: nil)
        tableViewVini.register(nib, forHeaderFooterViewReuseIdentifier: "IdentifierSectionHeaderAzienda")
        if(azienda.viniAzienda==nil){
            azienda.viniAzienda=[Vino]()
        }
        if(azienda.eventiAzienda==nil){
            azienda.eventiAzienda=[Evento]()
        }
        cManager.delegate=self
        showLoading()
        
        self.viewShadow.frame=CGRect(x: viewShadow.frame.origin.x, y: viewShadow.frame.origin.y, width: self.view.frame.size.width-(viewShadow.frame.origin.x*2), height: viewShadow.frame.size.height)
        self.viewDoveShadow.frame=CGRect(x: viewDoveShadow.frame.origin.x, y: viewDoveShadow.frame.origin.y, width: self.view.frame.size.width-(viewDoveShadow.frame.origin.x*2), height: viewDoveShadow.frame.size.height)
        
        viewShadow.setShadowAndCorners(corners: [.allCorners], x:0, y:0, offsetW: 0, offsetH: 0, cornerRadius: 4, colorBg: .white)
        viewDoveShadow.setShadowAndCorners(corners: [.allCorners], x:0, y:0, offsetW: 0, offsetH: 0, cornerRadius: 4, colorBg: .white)
        
        cManager.getAzienda(aziendaId: azienda.idAzienda)
        reloadView()
        
        self.addHiddenTitleView()
        mapView.delegate=self
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(dismiss(fromGesture:)))
        view.addGestureRecognizer(gesture)
        
        labelEmail.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(AziendaDettaglioViewController.tapSendMail)))
        labelTelefono.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(AziendaDettaglioViewController.tapChiamaTelefono)))
        labelSito.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(AziendaDettaglioViewController.tapOpenSito)))
    }
    
    @objc
    func tapChiamaTelefono(sender:UITapGestureRecognizer) {
        let newString = azienda.telefonoAzienda.replacingOccurrences(of: " ", with: "")
        guard let number = URL(string: "tel://" + newString) else { return }
        UIApplication.shared.openURL(number)
    }
    
    @objc
    func tapOpenSito(sender:UITapGestureRecognizer) {
        if azienda.sitoAzienda != nil {
            let validUrlString = azienda.sitoAzienda.contains("https") ? azienda.sitoAzienda : "https://\(azienda.sitoAzienda!)"
            if let url = URL(string: validUrlString!) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @objc
    func tapSendMail(sender:UITapGestureRecognizer) {
        if azienda.emailAzienda != nil && azienda.emailAzienda != ""  {
            sendEmail()
        }
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
    
    @objc func dismiss(fromGesture gesture: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
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
    
    // MARK: - IBAction
    
    @IBAction func buttonChiudiPressed(){
        dismiss(animated: true, completion: nil);
    }
    
    // MARK: - ScrollView
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var yPos:CGFloat = -scrollView.contentOffset.y
        if (yPos > 0) {
            var imgRect:CGRect = imageView.frame
            imgRect.origin.y = scrollView.contentOffset.y
            imgRect.size.height = 200.0+yPos
            imageView.frame = imgRect
        }
        else {
            yPos = scrollView.contentOffset.y
            var imgRect: CGRect = imageView.frame
            imgRect.origin.y = scrollView.contentOffset.y/2
            imageView.frame = imgRect
        }
        
        // vertical
        //   let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
        let currentVerticalOffset:CGFloat = scrollView.contentOffset.y
        
        // percentages
        // CGFloat percentageHorizontalOffset = currentHorizontalOffset / maximumHorizontalOffset;
        //   let percentageOffset:CGFloat = currentVerticalOffset / maximumVerticalOffset
        didScrollToPercentageOffset(currentVerticalOffset: currentVerticalOffset, moveUp:self.lastContentOffset > scrollView.contentOffset.y)
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func didScrollToPercentageOffset(currentVerticalOffset: CGFloat, moveUp:Bool){
        if currentVerticalOffset >= viewShadow.frame.origin.y {
            animateViews(hidden: false)
        }else if currentVerticalOffset <= viewShadow.frame.origin.y{
            animateViews(hidden: true)
        }
        
        if currentVerticalOffset >= viewCardDove.frame.origin.y-self.view.frame.size.height && !moveUp && viewCardDove.alpha==0{
            viewCardDove.fadeIn(y:textViewTesto.frame.origin.y+textViewTesto.frame.size.height+marginSmall)
        }
        if currentVerticalOffset <= viewCardDove.frame.origin.y-self.view.frame.size.height+marginBig*2 && moveUp && viewCardDove.alpha==1{
            viewCardDove.fadeOut(y:textViewTesto.frame.origin.y+textViewTesto.frame.size.height+marginBig)
        }
        if currentVerticalOffset >= tableViewVini.frame.origin.y-self.view.frame.size.height && !moveUp && tableViewVini.alpha==0{
            tableViewVini.fadeIn( y:viewCardDove.frame.origin.y+viewCardDove.frame.size.height)
        }
        if currentVerticalOffset <= tableViewVini.frame.origin.y-self.view.frame.size.height+marginBig*2 && moveUp && tableViewVini.alpha==1{
            tableViewVini.fadeOut(y:viewCardDove.frame.origin.y+viewCardDove.frame.size.height+marginBig)
        }
        if currentVerticalOffset >= viewCardEventi.frame.origin.y-self.view.frame.size.height && !moveUp && viewCardEventi.alpha==0{
            viewCardEventi.fadeIn(y:tableViewVini.frame.origin.y+tableViewVini.frame.size.height+marginSmall)
        }
        if currentVerticalOffset <= viewCardEventi.frame.origin.y-self.view.frame.size.height+marginBig*2 && moveUp && viewCardEventi.alpha==1{
            viewCardEventi.fadeOut(y:tableViewVini.frame.origin.y+tableViewVini.frame.size.height+marginBig)
        }
        
    }
    
    private func animateViews(hidden:Bool){
        if (hidden==true && viewTitleHiddenAzienda.frame.origin.y == 0) {
            viewTitleHiddenAzienda.isHidden=true
            statusBarStyle = .lightContent
            UIApplication.shared.statusBarStyle = statusBarStyle
            setNeedsStatusBarAppearanceUpdate()
            UIView.animate(withDuration: 0.3, animations:{
                if #available(iOS 11.0, *) {
                    self.viewTitleHiddenAzienda.frame=CGRect(x:0, y:-self.viewTitleHiddenAzienda.frame.size.height, width:self.viewTitleHiddenAzienda.frame.size.width, height:self.viewTitleHiddenAzienda.frame.size.height)
                } else {
                    self.viewTitleHiddenAzienda.frame=CGRect(x:0, y:-self.viewTitleHiddenAzienda.frame.size.height, width:self.viewTitleHiddenAzienda.frame.size.width, height:self.viewTitleHiddenAzienda.frame.size.height)
                    
                }
                
            })
        }else if (hidden==false && viewTitleHiddenAzienda.frame.origin.y < 0) {
            statusBarStyle = .default
            UIApplication.shared.statusBarStyle = statusBarStyle
            setNeedsStatusBarAppearanceUpdate()
            viewTitleHiddenAzienda.isHidden=false
            UIView.animate(withDuration: 0.3, animations:{
                self.viewTitleHiddenAzienda.frame=CGRect(x:0, y:0, width:self.viewTitleHiddenAzienda.frame.size.width, height:self.viewTitleHiddenAzienda.frame.size.height)
            })
        }
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView==tableViewEventi {
            return azienda.eventiAzienda.count
        }else{
            return azienda.viniAzienda.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == tableViewVini  {
            // Dequeue with the reuse identifier
            let cell = self.tableViewVini.dequeueReusableHeaderFooterView(withIdentifier: "IdentifierSectionHeaderAzienda")
            let header = cell as! TableSectionHeaderAzienda
            header.labelNomeAzienda.text="Lista dei Vini"
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if tableView==tableViewEventi {
            return CGFloat(Height.eventoTableViewCell)
        }else{
            return CGFloat(Height.vinoTableViewCell)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView==tableViewEventi {
            return 0
        }
        else{
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView==tableViewVini {
            let vw = UIView()
            vw.backgroundColor = UIColor.clear
            let viewShadow = UIView(frame: CGRect(x: 15, y: 0, width: self.view.frame.size.width-31, height: 30))
            viewShadow.setShadowAndCorners(corners: [.bottomLeft, .bottomRight], x:0, y:20, offsetW: 0, offsetH: -20, cornerRadius: 10, colorBg: .white)
            vw.addSubview(viewShadow)
            return vw
        }else {
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView==tableViewEventi {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifierEvento", for: indexPath) as! EventoTableViewCell
            let ev=azienda.eventiAzienda[indexPath.row]
            cell.setData(ev: ev, tag: indexPath.row, prezzoHidden: false)
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifierVino", for: indexPath) as! VinoTableViewCell
            let vino=azienda.viniAzienda[indexPath.row]
            cell.setData(vino: vino)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView==tableViewVini {
            vinoSelezionato=azienda.viniAzienda[indexPath.row]
            performSegue(withIdentifier: "GoToVinoFromAzienda", sender: nil);
        }else{
            eventoSelezionato=azienda.eventiAzienda[indexPath.row]
            performSegue(withIdentifier: "GoToEventoFromAzienda", sender: nil);
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }    
    
    // MARK: - Private
    
    private func addHiddenTitleView(){
        viewTitleHiddenAzienda.frame=CGRect(x:0, y:-self.viewTitleHiddenAzienda.frame.size.height-hiddenTitleViewMargin, width:self.view.frame.size.width, height:self.viewTitleHiddenAzienda.frame.size.height+hiddenTitleViewMargin)
        viewTitleHiddenAzienda.create(title: azienda.nomeAzienda, action: #selector(AziendaDettaglioViewController.buttonChiudiPressed))
        view.addSubview(viewTitleHiddenAzienda)
        viewTitleHiddenAzienda.isHidden=true
    }
    
    private func showAlert(titolo:String, msg:String){
        let alert = UIAlertController(title: titolo, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showLoading(){
        actInd.frame=CGRect(x:0,y:0,width:40.0, height:40.0)
        actInd.center = view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        actInd.color=UIColor.bvRedPink
        view.addSubview(actInd)
        actInd.isHidden=false
        actInd.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    private func hideLoading(){
        actInd.isHidden=true
        actInd.removeFromSuperview()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    private func reloadView(){
        imageView.imageFromServerURL(urlString: azienda.urlImmagineAzienda, imagePlaceholder: UIImage(named: "placeholder")!, completionBlock: {_ in })
        labelNome.text=azienda.nomeAzienda//"l’elemento in alto pin città"
        viewTitleHiddenAzienda.labelTitle?.text=azienda.nomeAzienda
        var cittaAz=""
        var regioneAz=""
        if azienda.cittaAzienda != nil{
            cittaAz=azienda.cittaAzienda
        }
        if azienda.regioneAzienda != nil{
            regioneAz=azienda.regioneAzienda
        }
        if cittaAz=="" && regioneAz=="" {
            labelCittaRegione.text=" "
        }else{
            labelCittaRegione.text="\(cittaAz), \(regioneAz)"
        }
        
        /* var htmlstring=htmlTextStyle
         htmlstring.append(azienda.infoAzienda)
         textViewTesto.attributedText=htmlstring.htmlToAttributedString*/
        textViewTesto.text=azienda.infoAzienda
        textViewTesto.addCharacterLineSpacingText()
        textViewTesto.textContainerInset = .zero
        textViewTesto.textContainer.lineFragmentPadding = 0
        
        let sizeThatFitsTextView = textViewTesto.sizeThatFits(CGSize(width: textViewTesto.frame.size.width, height: CGFloat(MAXFLOAT)))
        let heightOfText = sizeThatFitsTextView.height
        textViewTesto.frame.size.height = heightOfText
        
        var transitionHeight:CGFloat=marginBig
        
        //DOVE
        if textViewTesto.frame.origin.y+textViewTesto.frame.size.height <= self.view.frame.size.height {
            viewCardDove.alpha=1
            viewCardDove.frame=CGRect(x:viewCardDove.frame.origin.x, y:textViewTesto.frame.origin.y+textViewTesto.frame.size.height+marginSmall, width:viewCardDove.frame.size.width, height:viewCardDove.frame.size.height)
            
        }else{
            viewCardDove.alpha=0
            viewCardDove.frame=CGRect(x:viewCardDove.frame.origin.x, y:textViewTesto.frame.origin.y+textViewTesto.frame.size.height+marginBig, width:viewCardDove.frame.size.width, height:viewCardDove.frame.size.height)
            transitionHeight=0.0
        }
        
        labelCitta.frame=CGRect(x:labelCitta.frame.origin.x, y:labelCitta.frame.origin.y, width:view.frame.size.width-36*2, height:labelCitta.frame.size.height)
        labelCitta.text=azienda.cittaAzienda
        
        //viewCardDove ha le stesse dimensioni di self.view
        labelIndirizzo.frame=CGRect(x:labelIndirizzo.frame.origin.x, y:labelIndirizzo.frame.origin.y, width:view.frame.size.width-36*2, height:labelIndirizzo.frame.size.height)
        labelIndirizzo.text=azienda.indirizzoAzienda
        
        labelSito.frame=CGRect(x:labelSito.frame.origin.x, y:labelSito.frame.origin.y, width:view.frame.size.width-36*2, height:labelSito.frame.size.height)
        labelSito.text=azienda.sitoAzienda
        
        labelEmail.frame=CGRect(x:labelEmail.frame.origin.x, y:labelEmail.frame.origin.y, width:view.frame.size.width-36*2, height:labelEmail.frame.size.height)
        labelEmail.text=azienda.emailAzienda
        
        labelTelefono.frame=CGRect(x:labelTelefono.frame.origin.x, y:labelTelefono.frame.origin.y, width:view.frame.size.width-36*2, height:labelTelefono.frame.size.height)
        labelTelefono.text=azienda.telefonoAzienda
        
        //VINI
        tableViewVini.alpha=0
        tableViewVini.reloadData()
        //   tableViewVini.frame=CGRect(x:tableViewVini.frame.origin.x, y:viewCardDove.frame.origin.y+viewCardDove.frame.size.height+transitionHeight, width:tableViewVini.frame.size.width, height:CGFloat(30.0+Height.tableSectionHeaderAzienda)+(CGFloat(Height.vinoTableViewCell)*CGFloat(tableViewVini.numberOfRows(inSection: 0)))+marginSmall)
        tableViewVini.backgroundColor=UIColor.clear
        
        if azienda.viniAzienda.count == 0 {
            tableViewVini.isHidden=true
            tableViewVini.frame=CGRect(x:tableViewVini.frame.origin.x, y:viewCardDove.frame.origin.y+viewCardDove.frame.size.height+transitionHeight, width:tableViewVini.frame.size.width, height:marginSmall)
        }else{
            tableViewVini.isHidden=false
            tableViewVini.frame=CGRect(x:tableViewVini.frame.origin.x, y:viewCardDove.frame.origin.y+viewCardDove.frame.size.height+transitionHeight, width:tableViewVini.frame.size.width, height:CGFloat(30.0+Height.tableSectionHeaderAzienda)+(CGFloat(Height.vinoTableViewCell)*CGFloat(tableViewVini.numberOfRows(inSection: 0)))+marginSmall)
        }
        
        //EVENTI
        viewCardEventi.backgroundColor=UIColor.clear
        
        viewCardEventi.alpha=0
        tableViewEventi.reloadData()
        tableViewEventi.frame=CGRect(x:tableViewEventi.frame.origin.x, y:tableViewEventi.frame.origin.y, width:tableViewEventi.frame.size.width, height:(CGFloat(Height.eventoTableViewCell) * CGFloat(tableViewEventi.numberOfRows(inSection: 0))))
        if azienda.eventiAzienda.count == 0 {
            viewCardEventi.isHidden=true
            viewCardEventi.frame=CGRect(x:viewCardEventi.frame.origin.x, y:tableViewVini.frame.origin.y+tableViewVini.frame.size.height, width:viewCardEventi.frame.size.width, height:0)
        }else{
            viewCardEventi.isHidden=false
            viewCardEventi.frame=CGRect(x:viewCardEventi.frame.origin.x, y:tableViewVini.frame.origin.y+tableViewVini.frame.size.height, width:viewCardEventi.frame.size.width, height:tableViewEventi.frame.origin.y+tableViewEventi.frame.height)
        }
        
        contentView.frame.size=CGSize(width:self.view.frame.width, height:viewCardEventi.frame.origin.y+viewCardEventi.frame.size.height)
        self.scrollView.contentSize = contentView.frame.size
        heightConstraintContentView.constant=contentView.frame.size.height
        addPinToMapView()
    }
    
    // MARK: - Map
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        openAppMap(coordinate:view.annotation!.coordinate)
    }
    
    private func addPinToMapView(){
        if azienda.latitudineAzienda != nil && azienda.longitudineAzienda != nil {
            let annotation = MKPointAnnotation()
            let coordinate=CLLocationCoordinate2D(latitude: azienda.latitudineAzienda, longitude: azienda.longitudineAzienda)
            annotation.coordinate=coordinate
            mapView.addAnnotation(annotation)
            let span = MKCoordinateSpanMake(0.00075, 0.00075)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: false)
        }
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
    
    private func openAppMap(coordinate:CLLocationCoordinate2D){
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = azienda.indirizzoAzienda
        mapItem.openInMaps(launchOptions: nil)//[MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    // MARK: - ConnectionManagerDelegate
    
    func aziendaDidReceive(azienda:Azienda?, errore:String){
        if errore=="" {
            self.azienda=azienda
        }else{
            showAlert(titolo: "Errore", msg: errore)
        }
        DispatchQueue.main.async() {
            self.reloadView()
            self.hideLoading()
        }
    }
    
    func aziendaDidReceiveWithError(error:Error){
        DispatchQueue.main.async() {
            
            self.hideLoading()
            self.showAlert(titolo: "Errore", msg: error.localizedDescription)
            
        }
    }
    
    func statoEventoError(error:Error){
        DispatchQueue.main.async () {
            self.hideLoading()
            self.showAlert(titolo: "Errore", msg: error.localizedDescription)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "GoToVinoFromAzienda"{
            let vdvc = segue.destination as! VinoDettaglioViewController
            vdvc.vino=vinoSelezionato
        }else if segue.identifier == "GoToEventoFromAzienda"{
            let edvc = segue.destination as! EventoDettaglioViewController
            edvc.evento=eventoSelezionato
        }
    }
    
}


