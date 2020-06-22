//
//  EventoDettaglioViewController.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 27/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit

class VinoDettaglioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ConnectionManagerDelegate {
    
    public var vino:Vino!
    private var utenteSelezionato:Utente!
    private let cManager = ConnectionManager() 
    private var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    private var eventoSelezionato:Evento!
    private var viewTitleHiddenVino=HiddenTitleView.instanceFromNib()
    private var marginSmall:CGFloat=20.0
    private var marginBig:CGFloat=80.0
    private var lastContentOffset: CGFloat = 0
    private var statoVinoOld:String!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buttonAggiunto: UIButton!
    @IBOutlet weak var labelNomeVino: UILabel!
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var labelNomeAzienda: UILabel!
    
    /* @IBOutlet weak var labelUvaggio: UILabel!
     @IBOutlet weak var labelRegione: UILabel!
     @IBOutlet weak var labelProfumo: UILabel!*/
    
    @IBOutlet weak var textViewUvaggio: UITextView!
    @IBOutlet weak var textViewRegione: UITextView!
    
    @IBOutlet weak var textViewInBreve: UITextView!
    @IBOutlet weak var textViewInfo: UITextView!
    @IBOutlet weak var tableViewAzienda: UITableView!
    @IBOutlet weak var tableViewEventi: UITableView!
    @IBOutlet weak var tableViewUtenti: UITableView!
    @IBOutlet weak var imageViewVino: UIImageView!
    @IBOutlet weak var buttonAcquista: UIButton!
    @IBOutlet weak var viewCardAzienda:UIView!
    @IBOutlet weak var viewCardEventi:UIView!
    @IBOutlet weak var viewCardCarta:UIView!
    @IBOutlet weak var contentView:UIView!
    
    @IBOutlet weak var heightConstraintContentView:NSLayoutConstraint!
    private var statusBarStyle=UIStatusBarStyle.lightContent
    private var hiddenTitleViewMargin:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436{
            imageViewVino.addBlackGradientLayer(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: imageViewVino.frame.size.height), colors: [ UIColor(red: 0, green: 0, blue: 0, alpha: 0.5), UIColor(red: 0, green: 0, blue: 0, alpha: 0.4), UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), .clear, UIColor(red: 0, green: 0, blue: 0, alpha: 0.2), UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), .clear])
            hiddenTitleViewMargin=30
        } else{
            imageViewVino.addBlackGradientLayer(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: imageViewVino.frame.size.height), colors: [ UIColor(red: 0, green: 0, blue: 0, alpha: 0.5), UIColor(red: 0, green: 0, blue: 0, alpha: 0.4), .clear, UIColor(red: 0, green: 0, blue: 0, alpha: 0.2), UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), .clear])
            hiddenTitleViewMargin=20
        }
        tableViewEventi.register(UINib(nibName: "EventoTableViewCell", bundle: nil), forCellReuseIdentifier: "CellIdentifierEvento");
        tableViewUtenti.register(UINib(nibName: "UtenteTableViewCell", bundle: nil), forCellReuseIdentifier: "CellIdentifierUtente");
        tableViewAzienda.register(UINib(nibName: "FeedAziendaTableViewCell", bundle: nil), forCellReuseIdentifier: "CellIdentifierFeedAzienda")
        
        if vino.aziendaVino==nil {
            vino.aziendaVino=Azienda()
        }
        if vino.eventiVino==nil {
            vino.eventiVino=[Evento]()
        }
        if vino.utentiVino==nil {
            vino.utentiVino=[Utente]()
        }
        vino.acquistabileVino=Vino.Acqistabile.no.rawValue
        showLoading(indicatorVisible: true)
        cManager.delegate=self
        cManager.getVino(vinoId: vino.idVino)
        self.viewShadow.frame=CGRect(x: viewShadow.frame.origin.x, y: viewShadow.frame.origin.y, width: self.view.frame.size.width-(viewShadow.frame.origin.x*2), height: viewShadow.frame.size.height)
        
        viewShadow.setShadowAndCorners(corners: [.allCorners], x:0, y:0, offsetW: 0, offsetH: 0, cornerRadius: 4, colorBg: .white)
        self.setButtonAcquista()
        setButtonAggiungi()
        self.addHiddenTitleView()
        reloadView()
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
    
    override func viewWillAppear(_ animated: Bool) {
        cManager.delegate=self
        UIApplication.shared.statusBarStyle = statusBarStyle
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - ScrollView
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var yPos:CGFloat = -scrollView.contentOffset.y
        if (yPos > 0) {
            var imgRect:CGRect = imageViewVino.frame
            imgRect.origin.y = scrollView.contentOffset.y
            imgRect.size.height = 200.0+yPos
            imageViewVino.frame = imgRect
        }
        else {
            yPos = scrollView.contentOffset.y
            var imgRect: CGRect = imageViewVino.frame
            imgRect.origin.y = scrollView.contentOffset.y/2
            imageViewVino.frame = imgRect
        }
        
        // vertical
        //      let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
        let currentVerticalOffset:CGFloat = scrollView.contentOffset.y
        
        // percentages
        // CGFloat percentageHorizontalOffset = currentHorizontalOffset / maximumHorizontalOffset;
        // let percentageOffset:CGFloat = currentVerticalOffset / maximumVerticalOffset
        didScrollToPercentageOffset(currentVerticalOffset: currentVerticalOffset, moveUp:self.lastContentOffset > scrollView.contentOffset.y)
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func didScrollToPercentageOffset(currentVerticalOffset: CGFloat, moveUp:Bool){
        if currentVerticalOffset >= viewShadow.frame.origin.y {
            animateViews(hidden: false)
        }else if currentVerticalOffset <= viewShadow.frame.origin.y{
            animateViews(hidden: true)
        }
        
        if currentVerticalOffset >= viewCardAzienda.frame.origin.y-self.view.frame.size.height && !moveUp && viewCardAzienda.alpha==0{
            viewCardAzienda.fadeIn(y:textViewInfo.frame.origin.y+textViewInfo.frame.size.height+marginSmall*2)
        }
        
        if currentVerticalOffset <= viewCardAzienda.frame.origin.y-self.view.frame.size.height+marginBig*2 && moveUp && viewCardAzienda.alpha==1{
            viewCardAzienda.fadeOut(y:textViewInfo.frame.origin.y+textViewInfo.frame.size.height+marginBig)
        }
        
        if currentVerticalOffset >= viewCardEventi.frame.origin.y-self.view.frame.size.height && !moveUp && viewCardEventi.alpha==0{
            viewCardEventi.fadeIn(y:viewCardAzienda.frame.origin.y+viewCardAzienda.frame.size.height)
        }
        if currentVerticalOffset <= viewCardEventi.frame.origin.y-self.view.frame.size.height+marginBig*2 && moveUp && viewCardEventi.alpha==1{
            viewCardEventi.fadeOut(y:viewCardAzienda.frame.origin.y+viewCardAzienda.frame.size.height+marginBig)
        }
        
        if currentVerticalOffset >= viewCardCarta.frame.origin.y-self.view.frame.size.height{
            viewCardCarta.fadeIn(y:viewCardEventi.frame.origin.y+viewCardEventi.frame.size.height)
        }
        if currentVerticalOffset <= viewCardCarta.frame.origin.y-self.view.frame.size.height+marginBig*2 && moveUp && viewCardCarta.alpha==1{
            viewCardCarta.fadeOut(y:viewCardEventi.frame.origin.y+viewCardEventi.frame.size.height+marginBig)
        }
    }
    
    private func animateViews(hidden:Bool){
        if (hidden==true && viewTitleHiddenVino.isHidden==false) {
            statusBarStyle = .lightContent
            UIApplication.shared.statusBarStyle = statusBarStyle
            setNeedsStatusBarAppearanceUpdate()
            UIView.animate(withDuration: 0.3, animations:{
                if(self.vino.acquistabileVino==Vino.Acqistabile.si.rawValue){
                    self.buttonAcquista.isHidden=true
                    self.buttonAcquista.frame = CGRect(x:self.buttonAcquista.frame.origin.x, y:self.view.frame.size.height, width:self.buttonAcquista.frame.size.width, height:self.buttonAcquista.frame.size.height)
                }
                self.viewTitleHiddenVino.isHidden=true
                if #available(iOS 11.0, *) {
                    self.viewTitleHiddenVino.frame=CGRect(x:0, y:-self.viewTitleHiddenVino.frame.size.height, width:self.viewTitleHiddenVino.frame.size.width, height:self.viewTitleHiddenVino.frame.size.height)
                } else {
                    self.viewTitleHiddenVino.frame=CGRect(x:0, y:-self.viewTitleHiddenVino.frame.size.height, width:self.viewTitleHiddenVino.frame.size.width, height:self.viewTitleHiddenVino.frame.size.height)
                }
                
            })
        }else if (hidden==false && buttonAcquista.frame.origin.y == self.view.frame.size.height) {
            statusBarStyle = .default
            UIApplication.shared.statusBarStyle = statusBarStyle
            setNeedsStatusBarAppearanceUpdate()
            UIView.animate(withDuration: 0.3, animations:{
                if(self.vino.acquistabileVino==Vino.Acqistabile.si.rawValue){
                    self.buttonAcquista.isHidden=false
                    var bottom=CGFloat(0)
                    if #available(iOS 11.0, *) {
                        bottom = self.view.safeAreaInsets.bottom
                    }
                    self.buttonAcquista.frame = CGRect(x:self.buttonAcquista.frame.origin.x, y:self.view.frame.size.height - bottom - 12 - self.buttonAcquista.frame.size.height, width:self.buttonAcquista.frame.size.width, height:self.buttonAcquista.frame.size.height)
                }
                self.viewTitleHiddenVino.isHidden=false
                self.viewTitleHiddenVino.frame=CGRect(x:0, y:0, width:self.viewTitleHiddenVino.frame.size.width, height:self.viewTitleHiddenVino.frame.size.height)
            })
            
        }
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView==tableViewAzienda {
            return 1
        }else if tableView==tableViewEventi {
            return vino.eventiVino.count
        }else{
            return vino.utentiVino.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if tableView==tableViewAzienda {
            return CGFloat(Height.feedAziendaTableViewCell)
        }else if tableView==tableViewEventi {
            return CGFloat(Height.eventoTableViewCell)
        }else{
            return CGFloat(Height.utenteTableViewCell)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView==tableViewAzienda {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifierFeedAzienda", for: indexPath) as! FeedAziendaTableViewCell
            cell.setData(azienda:vino.aziendaVino)
            return cell
        } else if tableView==tableViewEventi {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifierEvento", for: indexPath) as! EventoTableViewCell
            cell.setData(ev: vino.eventiVino[indexPath.row], tag: 0, prezzoHidden: false)
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifierUtente", for: indexPath) as! UtenteTableViewCell
            let ut=vino.utentiVino[indexPath.row]
            cell.setData(utente: ut)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if tableView==tableViewAzienda{
            performSegue(withIdentifier: "GoToAziendaFromVino", sender: nil);
        } else if tableView==tableViewEventi {
            eventoSelezionato=vino.eventiVino[indexPath.row]
            performSegue(withIdentifier: "GoToEventoFromVino", sender: nil);
        } else{
            utenteSelezionato=vino.utentiVino[indexPath.row]
            performSegue(withIdentifier: "GoToUtenteFromVino", sender: nil);
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - IBAction
    
    @IBAction func buttonChiudiPressed(){
        dismiss(animated: true, completion: nil);
    }
    
    @IBAction func buttonAggiungiPressed(){
        if vino.statoVino != nil && vino.statoVino==Vino.Stato.preferito.rawValue {
            let alert = UIAlertController(title: "", message: "Sicuro di voler rimuovere questo vino dalla tua Carta dei Vini?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Sì", style: UIAlertActionStyle.default, handler: {_ in
                self.changeAggiungiVino()
            }))
            alert.addAction(UIAlertAction(title:"Annulla", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            self.changeAggiungiVino()
        }
    }
    
    private func changeAggiungiVino(){
        self.showLoading(indicatorVisible: false)
        self.statoVinoOld=self.vino.statoVino
        if(self.statoVinoOld==nil || self.statoVinoOld==Vino.Stato.null.rawValue){
            self.vino.statoVino=Vino.Stato.preferito.rawValue
            self.cManager.changeStatoVino(idVino: self.vino.idVino, stato: Vino.Stato.preferito)
        }else{
            self.vino.statoVino=Vino.Stato.null.rawValue
            self.cManager.changeStatoVino(idVino: self.vino.idVino, stato: Vino.Stato.null)
        }
        self.setButtonsAcquistaAggiungi()
    }
    
    @IBAction func buttonAcquistaPressed(){
        let alert = UIAlertController(title: "", message: "Confermi di voler acquistare il vino al prezzo di \(vino.getPrezzoVino())?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Sì", style: UIAlertActionStyle.default, handler: {_ in
            self.showLoading(indicatorVisible: false)
            self.statoVinoOld=self.vino.statoVino
            self.vino.statoVino=Vino.Stato.acquistato.rawValue
            self.setButtonsAcquistaAggiungi()
            self.cManager.changeStatoVino(idVino: self.vino.idVino, stato: Vino.Stato.acquistato)
        }))
        alert.addAction(UIAlertAction(title:"No", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Private
    
    private func setButtonAcquista(){
        buttonAcquista.frame = CGRect(x:self.buttonAcquista.frame.origin.x+11, y:self.view.frame.size.height, width:self.buttonAcquista.frame.size.width-22, height:self.buttonAcquista.frame.size.height)
        buttonAcquista.addCornerRadius()
        buttonAcquista.isHidden=true
        let attributedString = NSMutableAttributedString(string: "Acquista (\(vino.getPrezzoVino()) )", attributes: [
            .font: UIFont(name: "Larsseit", size: 16.0)!,
            .foregroundColor: UIColor(red: 70.0 / 255.0, green: 43.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0),
            .kern: 0.5
            ])
        attributedString.addAttribute(.font, value: UIFont(name: "Larsseit-Bold", size: 18.0)!, range: NSRange(location: 0, length: 8))
        buttonAcquista.setAttributedTitle(attributedString, for: .normal)
        
        
    }
    
    private func setButtonAggiungi(){
        buttonAggiunto.layer.cornerRadius = buttonAggiunto.frame.size.height/2
        buttonAggiunto.layer.borderWidth = 2
        buttonAggiunto.layer.borderColor = UIColor.bvDandelion.cgColor
        buttonAggiunto.clipsToBounds = true
    }
    
    private func setButtonsAcquistaAggiungi(){
        if vino.statoVino==nil || vino.statoVino==Vino.Stato.null.rawValue  {
            self.buttonAggiunto.backgroundColor = UIColor.white
            self.buttonAggiunto.setTitle("AGGIUNGI", for: .normal)
        }else{
            self.buttonAggiunto.backgroundColor = UIColor.bvDandelion
            self.buttonAggiunto.setTitle("AGGIUNTO", for: .normal)
        }
    }
    
    private func addHiddenTitleView(){
        viewTitleHiddenVino.frame=CGRect(x:0, y:-self.viewTitleHiddenVino.frame.size.height-hiddenTitleViewMargin, width:self.view.frame.size.width, height:self.viewTitleHiddenVino.frame.size.height+hiddenTitleViewMargin)
        viewTitleHiddenVino.create(title: vino.nomeVino, action: #selector(VinoDettaglioViewController.buttonChiudiPressed))
        view.addSubview(viewTitleHiddenVino)
        viewTitleHiddenVino.isHidden=true
    }
    
    private func showAlert(titolo:String, msg:String){
        let alert = UIAlertController(title: titolo, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showLoading(indicatorVisible:Bool){
        if indicatorVisible{
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
        actInd.isHidden=true
        actInd.removeFromSuperview()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    private func reloadView(){
        viewTitleHiddenVino.labelTitle?.text=vino.nomeVino
        imageViewVino.imageFromServerURL(urlString: vino.urlImmagineVino, imagePlaceholder: UIImage(named: "placeholder")!, completionBlock: {_ in })
        setButtonsAcquistaAggiungi()
        labelNomeVino.text=vino.nomeVino
        labelNomeAzienda.text=vino.aziendaVino.nomeAzienda
        
        /*labelUvaggio.text=vino.uvaggioVino
         labelRegione.text=vino.regioneVino
         labelProfumo.text=vino.profumoVino*/
        
        var uvaggioStr=""
        if vino.uvaggioVino != nil {
            uvaggioStr = vino.uvaggioVino
        }
        let attributedUvaggioString = NSMutableAttributedString(string: "Uvaggio: \(uvaggioStr)", attributes: [
            .font: UIFont(name: "InterUI-Regular", size: 16.0)!,
            .foregroundColor: UIColor(red: 70.0 / 255.0, green: 43.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0),
            .kern: 0.5])
        attributedUvaggioString.addAttribute(.font, value: UIFont(name: "InterUI-Bold", size: 16.0)!, range: NSRange(location: 0, length: 8))
        attributedUvaggioString.addAttribute(.kern , value: 0.6, range: NSRange(location: 0, length: attributedUvaggioString.length))
        textViewUvaggio.attributedText=attributedUvaggioString
        textViewUvaggio.textContainerInset = .zero
        textViewUvaggio.textContainer.lineFragmentPadding = 0
        
        var sizeThatFitsTextView = textViewUvaggio.sizeThatFits(CGSize(width: textViewUvaggio.frame.size.width, height: CGFloat(MAXFLOAT)))
        var heightOfText = sizeThatFitsTextView.height
        textViewUvaggio.frame.size.height = heightOfText
        
        var regioneStr=""
        if vino.regioneVino != nil {
            regioneStr = vino.regioneVino
        }
        let attributedRegioneString = NSMutableAttributedString(string: "Regione: \(regioneStr)", attributes: [
            .font: UIFont(name: "InterUI-Regular", size: 16.0)!,
            .foregroundColor: UIColor(red: 70.0 / 255.0, green: 43.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0),
            .kern: 0.5])
        attributedRegioneString.addAttribute(.font, value: UIFont(name: "InterUI-Bold", size: 16.0)!, range: NSRange(location: 0, length: 8))
        attributedRegioneString.addAttribute(.kern , value: 0.6, range: NSRange(location: 0, length: attributedRegioneString.length))
        textViewRegione.attributedText=attributedRegioneString
        textViewRegione.textContainerInset = .zero
        textViewRegione.textContainer.lineFragmentPadding = 0
        
        sizeThatFitsTextView = textViewRegione.sizeThatFits(CGSize(width: textViewRegione.frame.size.width, height: CGFloat(MAXFLOAT)))
        heightOfText = sizeThatFitsTextView.height
        textViewRegione.frame.size.height = heightOfText
        
        textViewRegione.frame=CGRect(x:textViewRegione.frame.origin.x, y:textViewUvaggio.frame.origin.y+textViewUvaggio.frame.size.height+10.0, width:textViewRegione.frame.size.width, height:heightOfText)
        
        var inBreveVinoStr=""
        if vino.inBreveVino != nil {
            inBreveVinoStr = vino.inBreveVino
        }
        let attributedString = NSMutableAttributedString(string: "In Breve: \(inBreveVinoStr)", attributes: [
            .font: UIFont(name: "InterUI-Regular", size: 16.0)!,
            .foregroundColor: UIColor.bvRedPink,
            .kern: 0.5])
        attributedString.addAttribute(.font, value: UIFont(name: "InterUI-Bold", size: 16.0)!, range: NSRange(location: 0, length: 8))
        attributedString.addAttribute(.kern , value: 0.6, range: NSRange(location: 0, length: attributedString.length))
        textViewInBreve.attributedText=attributedString
        textViewInBreve.textContainerInset = .zero
        textViewInBreve.textContainer.lineFragmentPadding = 0
        
        sizeThatFitsTextView = textViewInBreve.sizeThatFits(CGSize(width: textViewInBreve.frame.size.width, height: CGFloat(MAXFLOAT)))
        heightOfText = sizeThatFitsTextView.height
        textViewInBreve.frame.size.height = heightOfText
        
        textViewInBreve.frame=CGRect(x:textViewInBreve.frame.origin.x, y:textViewRegione.frame.origin.y+textViewRegione.frame.size.height+16.0, width:textViewInBreve.frame.size.width, height:heightOfText)
        
        var htmlstring=htmlTextStyle
        if vino.infoVino != nil {
            htmlstring.append(vino.infoVino)
        }
        textViewInfo.attributedText=htmlstring.htmlToAttributedString
        
        textViewInfo.textContainerInset = .zero
        textViewInfo.textContainer.lineFragmentPadding = 0
        
        sizeThatFitsTextView = textViewInfo.sizeThatFits(CGSize(width: textViewInfo.frame.size.width, height: CGFloat(MAXFLOAT)))
        heightOfText = sizeThatFitsTextView.height
        
        textViewInfo.frame=CGRect(x:textViewInfo.frame.origin.x, y:textViewInBreve.frame.origin.y+textViewInBreve.frame.size.height+16.0, width:textViewInfo.frame.size.width, height:heightOfText)
        
        var transitionHeight:CGFloat=marginBig
        
        //AZIENDA
        
        tableViewAzienda.reloadData()
        
        tableViewAzienda.frame=CGRect(x:tableViewAzienda.frame.origin.x, y:tableViewAzienda.frame.origin.y, width:tableViewAzienda.frame.size.width, height:CGFloat(Height.feedAziendaTableViewCell))
        
        if textViewInfo.frame.origin.y+textViewInfo.frame.size.height <= self.view.frame.size.height {
            viewCardAzienda.alpha=1
            viewCardAzienda.frame=CGRect(x:viewCardAzienda.frame.origin.x, y:textViewInfo.frame.origin.y+textViewInfo.frame.size.height+marginSmall*2, width:viewCardAzienda.frame.size.width, height:tableViewAzienda.frame.origin.y+tableViewAzienda.frame.height)
            
        }else{
            viewCardAzienda.alpha=0
            viewCardAzienda.frame=CGRect(x:viewCardAzienda.frame.origin.x, y:textViewInfo.frame.origin.y+textViewInfo.frame.size.height+marginBig, width:viewCardAzienda.frame.size.width, height:tableViewAzienda.frame.origin.y+tableViewAzienda.frame.height)
            transitionHeight=0.0
        }
        
        //EVENTI
        
        tableViewEventi.reloadData()
        tableViewEventi.frame=CGRect(x:tableViewEventi.frame.origin.x, y:tableViewEventi.frame.origin.y, width:tableViewEventi.frame.size.width, height:(CGFloat(Height.eventoTableViewCell) * CGFloat(tableViewEventi.numberOfRows(inSection: 0))))
        
        viewCardEventi.alpha=0
        if vino.eventiVino.count == 0 {
            viewCardEventi.isHidden=true
            viewCardEventi.frame=CGRect(x:viewCardEventi.frame.origin.x, y:viewCardAzienda.frame.origin.y+viewCardAzienda.frame.size.height+transitionHeight, width:viewCardEventi.frame.size.width, height:0)
        }else{
            viewCardEventi.isHidden=false
            viewCardEventi.frame=CGRect(x:viewCardEventi.frame.origin.x, y:viewCardAzienda.frame.origin.y+viewCardAzienda.frame.size.height, width:viewCardEventi.frame.size.width, height:tableViewEventi.frame.origin.y+tableViewEventi.frame.height)
        }
        
        //CARTA
        
        tableViewUtenti.reloadData()
        tableViewUtenti.frame=CGRect(x:tableViewUtenti.frame.origin.x, y:tableViewUtenti.frame.origin.y, width:tableViewUtenti.frame.size.width, height:(CGFloat(Height.utenteTableViewCell) * CGFloat(tableViewUtenti.numberOfRows(inSection: 0))))
        
        viewCardCarta.alpha=0
        if vino.utentiVino.count == 0 {
            viewCardCarta.isHidden=true
            viewCardCarta.frame=CGRect(x:viewCardCarta.frame.origin.x, y:viewCardEventi.frame.origin.y+viewCardEventi.frame.size.height, width:viewCardCarta.frame.size.width, height:0)
        }else{
            viewCardCarta.isHidden=false
            viewCardCarta.frame=CGRect(x:viewCardCarta.frame.origin.x, y:viewCardEventi.frame.origin.y+viewCardEventi.frame.size.height, width:viewCardCarta.frame.size.width, height:tableViewUtenti.frame.origin.y+10+tableViewUtenti.frame.height)
        }
        contentView.frame.size=CGSize(width:self.view.frame.width, height:viewCardCarta.frame.origin.y+viewCardCarta.frame.size.height+10.0+buttonAcquista.frame.size.height)
        
        self.scrollView.contentSize = contentView.frame.size
        heightConstraintContentView.constant=contentView.frame.size.height
    }
    
    // MARK: - ConnectionManagerDelegate
    
    func vinoDidReceive(vino:Vino?, errore:String){
        if errore=="" {
            self.vino=vino
            //   self.vino.acquistabileVino=Vino.Acqistabile.si.rawValue
        }else{
            showAlert(titolo: "Errore", msg: errore)
        }
        DispatchQueue.main.async() {
            self.reloadView()
            self.hideLoading()
        }
    }
    
    func vinoDidReceiveWithError(error:Error){
        DispatchQueue.main.async() {
            self.hideLoading()
            self.showAlert(titolo: "Errore", msg: error.localizedDescription)
        }
    }
    
    func statoVinoIsChanged(errore:String){
        if errore != ""{
            vino.statoVino=statoVinoOld
            DispatchQueue.main.async() {
                self.setButtonsAcquistaAggiungi()
                self.showAlert(titolo: "Errore", msg: errore)
            }
        }
        DispatchQueue.main.async() {
            self.hideLoading()
        }
    }
    
    func statoVinoError(error:Error){
        vino.statoVino=statoVinoOld
        DispatchQueue.main.async () {
            self.hideLoading()
            self.setButtonsAcquistaAggiungi()
            self.showAlert(titolo: "Errore", msg: error.localizedDescription)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "GoToUtenteFromVino"{
            let pvc = segue.destination as! ProfiloViewController
            pvc.utente=utenteSelezionato
            pvc.fromTabBar=false
        }else if segue.identifier == "GoToEventoFromVino"{
            let edvc = segue.destination as! EventoDettaglioViewController
            edvc.evento=eventoSelezionato
        }else if segue.identifier == "GoToAziendaFromVino"{
            let advc = segue.destination as! AziendaDettaglioViewController
            advc.azienda=vino.aziendaVino
        }
    }
    
    
}

