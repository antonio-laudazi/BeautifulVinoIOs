//
//  PostViewController.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 24/11/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

//
//  EventoDettaglioViewController.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 27/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit
import MapKit

class PostDettaglioViewController: UIViewController, UIScrollViewDelegate, ConnectionManagerDelegate {
    
    public var feed:Feed!
    private var viewTitleHiddenFeed=HiddenTitleView.instanceFromNib()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelTitolo: UILabel!
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var textViewTesto: UITextView!
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var webView:UIWebView!
    @IBOutlet weak var headerViewGoTo:HeaderView!
    @IBOutlet weak var heightConstraintContentView:NSLayoutConstraint!
    @IBOutlet weak var buttonLetto: UIButton!
    
    private var marginSmall:CGFloat=20.0
    private var marginBig:CGFloat=80.0
    private var lastContentOffset: CGFloat = 0
    private var statusBarStyle=UIStatusBarStyle.lightContent
    private var hiddenTitleViewMargin:CGFloat!
    private let cManager = ConnectionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cManager.delegate=self
        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436{
            hiddenTitleViewMargin=30
            imageView.addBlackGradientLayer(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: imageView.frame.size.height), colors: [ UIColor(red: 0, green: 0, blue: 0, alpha: 0.5), UIColor(red: 0, green: 0, blue: 0, alpha: 0.4), UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), .clear, UIColor(red: 0, green: 0, blue: 0, alpha: 0.2), UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), .clear])
            
        } else{
            hiddenTitleViewMargin=20
            imageView.addBlackGradientLayer(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: imageView.frame.size.height), colors: [ UIColor(red: 0, green: 0, blue: 0, alpha: 0.5), UIColor(red: 0, green: 0, blue: 0, alpha: 0.4), .clear, UIColor(red: 0, green: 0, blue: 0, alpha: 0.2), UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), .clear])
        }
        
        self.viewShadow.frame=CGRect(x: viewShadow.frame.origin.x, y: viewShadow.frame.origin.y, width: self.view.frame.size.width-(viewShadow.frame.origin.x*2), height: viewShadow.frame.size.height)
        self.viewShadow.setShadowAndCorners(corners: [.allCorners], x:0, y:0, offsetW: 0, offsetH: 0, cornerRadius: 4, colorBg: .white)
        headerViewGoTo.setDataHeaderView(feed: feed, tag:0)
        self.addHiddenTitleView()
        buttonLetto.addCornerRadius()
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
    
    override func viewDidAppear(_ animated: Bool) {
        // reloadView()
    }
    override func viewWillAppear(_ animated: Bool) {
        cManager.delegate=self
        UIApplication.shared.statusBarStyle = statusBarStyle
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
        UIApplication.shared.isStatusBarHidden = false
    }
    
    // MARK: - IBAction
    
    @IBAction func buttonChiudiPressed(){
        dismiss(animated: true, completion: nil);
    }
    
    @IBAction func buttonGuadagnaPressed(){
        //    self.showLoading()
        //     self.setButtonsAcquistaAggiungi()
        buttonLetto.isHidden=true
        self.cManager.getPuntiEsperienza(idFeed: feed.idFeed)
    }
    
    
    @objc func handleTap(_ sender:AnyObject) {
        if feed.tipoEntitaHeaderFeed == Feed.TipoEntitaHeaderFeed.azienda.rawValue {
            performSegue(withIdentifier: "GoToAziendaFromPost", sender: nil)
        }else if feed.tipoEntitaHeaderFeed == Feed.TipoEntitaHeaderFeed.evento.rawValue{
            performSegue(withIdentifier: "GoToEventoFromPost", sender: nil)
        }else if feed.tipoEntitaHeaderFeed == Feed.TipoEntitaHeaderFeed.profilo.rawValue {
            performSegue(withIdentifier: "GoToProfiloFromPost", sender: nil)
        }else if feed.tipoEntitaHeaderFeed == Feed.TipoEntitaHeaderFeed.vino.rawValue {
            performSegue(withIdentifier: "GoToVinoFromPost", sender: nil)
        }
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
        // let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
        let currentVerticalOffset:CGFloat = scrollView.contentOffset.y
        
        // percentages
        // CGFloat percentageHorizontalOffset = currentHorizontalOffset / maximumHorizontalOffset;
        //  let percentageOffset:CGFloat = currentVerticalOffset / maximumVerticalOffset
        didScrollToPercentageOffset(currentVerticalOffset: currentVerticalOffset, moveUp:self.lastContentOffset > scrollView.contentOffset.y)
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func didScrollToPercentageOffset(currentVerticalOffset: CGFloat, moveUp:Bool){
        if currentVerticalOffset >= viewShadow.frame.origin.y {
            animateViews(hidden: false)
        }else if currentVerticalOffset <= viewShadow.frame.origin.y{
            animateViews(hidden: true)
        }
        if textViewTesto.frame.origin.y+textViewTesto.frame.size.height+headerViewGoTo.frame.size.height+marginSmall > self.view.frame.size.height{
            if currentVerticalOffset >= headerViewGoTo.frame.origin.y-self.view.frame.size.height && !moveUp && headerViewGoTo.alpha==0{
                headerViewGoTo.fadeIn(y:textViewTesto.frame.origin.y+textViewTesto.frame.size.height+marginSmall)
            }
            if currentVerticalOffset <= headerViewGoTo.frame.origin.y-self.view.frame.size.height+marginBig && moveUp && headerViewGoTo.alpha==1{
                headerViewGoTo.fadeOut(y:textViewTesto.frame.origin.y+textViewTesto.frame.size.height+marginBig)
            }
        }
        
        if currentVerticalOffset >= headerViewGoTo.frame.origin.y-self.view.frame.size.height && !moveUp && buttonLetto.alpha==0{
            buttonLetto.fadeIn(y:headerViewGoTo.frame.origin.y+headerViewGoTo.frame.size.height+marginSmall)
        }
        if currentVerticalOffset <= headerViewGoTo.frame.origin.y-self.view.frame.size.height+marginBig && moveUp && buttonLetto.alpha==1{
            buttonLetto.fadeOut(y:headerViewGoTo.frame.origin.y+headerViewGoTo.frame.size.height+marginBig)
        }
    }
    
    private func animateViews(hidden:Bool){
        if (hidden==true && viewTitleHiddenFeed.frame.origin.y == 0) {
            viewTitleHiddenFeed.isHidden=true
            statusBarStyle = .lightContent
            UIApplication.shared.statusBarStyle = statusBarStyle
            setNeedsStatusBarAppearanceUpdate()
            UIView.animate(withDuration: 0.3, animations:{
                if #available(iOS 11.0, *) {
                    self.viewTitleHiddenFeed.frame=CGRect(x:0, y:-self.viewTitleHiddenFeed.frame.size.height, width:self.viewTitleHiddenFeed.frame.size.width, height:self.viewTitleHiddenFeed.frame.size.height)
                } else {
                    self.viewTitleHiddenFeed.frame=CGRect(x:0, y:-self.viewTitleHiddenFeed.frame.size.height, width:self.viewTitleHiddenFeed.frame.size.width, height:self.viewTitleHiddenFeed.frame.size.height)
                    
                }
                
            })
        }else if (hidden==false && viewTitleHiddenFeed.frame.origin.y < 0) {
            statusBarStyle = .default
            UIApplication.shared.statusBarStyle = statusBarStyle
            setNeedsStatusBarAppearanceUpdate()
            viewTitleHiddenFeed.isHidden=false
            UIView.animate(withDuration: 0.3, animations:{
                self.viewTitleHiddenFeed.frame=CGRect(x:0, y:0, width:self.viewTitleHiddenFeed.frame.size.width, height:self.viewTitleHiddenFeed.frame.size.height)
            })
        }
    }
    
    // MARK: - ConnectionManagerDelegate
    
    func puntiGuadagnati(esito: Esito){
        //codice errore 600
        if esito.codice == 600 {
            DispatchQueue.main.async() {
                self.buttonLetto.isHidden=true
                self.showAlert(titolo: "Attenzione!", msg: esito.message)
            }
        }else if esito.codice == 100{
            DispatchQueue.main.async() {
                self.buttonLetto.isHidden=true
                self.showAlert(titolo: "Articolo Letto!", msg: "Bene! La lettura di questo articolo ti fa guadagnare 10 punti esperienza")
            }
        }else{
            DispatchQueue.main.async() {
                self.buttonLetto.isHidden=false
                self.showAlert(titolo: "Errore!", msg: esito.message)
            }
        }
    }
    
    func puntiGuadagnatiError(error:Error){
        DispatchQueue.main.async () {
            self.buttonLetto.isHidden=false
            //self.hideLoading()
            // self.setButtonsAcquistaAggiungi()
            self.showAlert(titolo: "Errore", msg: error.localizedDescription)
        }
    }
    
    // MARK: - Private
    
    private func showAlert(titolo:String, msg:String){
        let alert = UIAlertController(title: titolo, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func addHiddenTitleView(){
        viewTitleHiddenFeed.frame=CGRect(x:0, y:-self.viewTitleHiddenFeed.frame.size.height-hiddenTitleViewMargin, width:self.view.frame.size.width, height:self.viewTitleHiddenFeed.frame.size.height+hiddenTitleViewMargin)
        viewTitleHiddenFeed.create(title: feed.titoloFeed, action: #selector(PostDettaglioViewController.buttonChiudiPressed))
        view.addSubview(viewTitleHiddenFeed)
        viewTitleHiddenFeed.isHidden=true
    }
    
    private func reloadView(){
        imageView.imageFromServerURL(urlString: feed.urlImmagineFeed, imagePlaceholder: UIImage(named: "placeholder")!, completionBlock: {_ in })
        labelTitolo.text=feed.titoloFeed
        // feed.urlVideoFeed="https://www.youtube.com/embed/Nr2g5R-v874"
        if feed.urlVideoFeed==nil || feed.urlVideoFeed=="" {
            webView.frame=CGRect(x: webView.frame.origin.x, y: webView.frame.origin.y, width: webView.frame.size.width, height: 0)
        }else{
            webView.allowsInlineMediaPlayback = true
            webView.mediaPlaybackRequiresUserAction = false
            let embedHTML="<iframe width=\"100%%\" height=\"\" src=\"\(feed.urlVideoFeed!)\"  frameborder=\"0\"allowfullscreen></iframe>"
            webView.loadHTMLString(embedHTML, baseURL:nil)
        }
        var htmlstring=htmlTextStyle
        htmlstring.append(feed.testoFeed)
        textViewTesto.attributedText=htmlstring.htmlToAttributedString
        textViewTesto.textContainerInset = .zero
        textViewTesto.textContainer.lineFragmentPadding = 0
        
        let sizeThatFitsTextView = textViewTesto.sizeThatFits(CGSize(width: textViewTesto.frame.size.width, height: CGFloat(MAXFLOAT)))
        let heightOfText = sizeThatFitsTextView.height
        
        textViewTesto.frame=CGRect(x:textViewTesto.frame.origin.x, y:webView.frame.origin.y+webView.frame.size.height, width:textViewTesto.frame.size.width, height:heightOfText)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        headerViewGoTo.addGestureRecognizer(tap)
        
        if textViewTesto.frame.origin.y+textViewTesto.frame.size.height <= self.view.frame.size.height {
            headerViewGoTo.alpha=1
            headerViewGoTo.frame=CGRect(x:headerViewGoTo.frame.origin.x, y:textViewTesto.frame.origin.y+textViewTesto.frame.size.height+marginSmall, width:headerViewGoTo.frame.size.width, height:headerViewGoTo.frame.size.height)
        }else{
            headerViewGoTo.alpha=0
            headerViewGoTo.frame=CGRect(x:headerViewGoTo.frame.origin.x, y:textViewTesto.frame.origin.y+textViewTesto.frame.size.height+marginBig, width:headerViewGoTo.frame.size.width, height:headerViewGoTo.frame.size.height)
        }
        contentView.frame.size=CGSize(width:self.view.frame.width, height:headerViewGoTo.frame.origin.y+headerViewGoTo.frame.size.height+marginSmall)
        
        if textViewTesto.frame.origin.y+textViewTesto.frame.size.height+headerViewGoTo.frame.size.height+marginSmall <= self.view.frame.size.height {
            headerViewGoTo.alpha=1
            headerViewGoTo.frame=CGRect(x:headerViewGoTo.frame.origin.x, y:self.view.frame.size.height-headerViewGoTo.frame.size.height-marginSmall, width:headerViewGoTo.frame.size.width, height:headerViewGoTo.frame.size.height)
            contentView.frame.size=CGSize(width:self.view.frame.width, height:headerViewGoTo.frame.origin.y+headerViewGoTo.frame.size.height+marginSmall*2)
            // heightConstraintContentView.constant=contentView.frame.size.height
        }else{
            //   heightConstraintContentView.constant=contentView.frame.size.height+marginBig
        }
        heightConstraintContentView.constant=contentView.frame.size.height+marginBig
        self.scrollView.contentSize = contentView.frame.size
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "GoToVinoFromPost"{
            let vdvc = segue.destination as! VinoDettaglioViewController
            let vinoSelezionato=Vino()
            vinoSelezionato.idVino=feed.idEntitaHeaderFeed
            vinoSelezionato.nomeVino=""
            vdvc.vino=vinoSelezionato
        }else if segue.identifier == "GoToEventoFromPost"{
            let edvc = segue.destination as! EventoDettaglioViewController
            let eventoSelezionato=Evento()
            eventoSelezionato.titoloEvento=""
            eventoSelezionato.idEvento=feed.idEntitaHeaderFeed
            edvc.evento=eventoSelezionato
        }else if segue.identifier == "GoToProfiloFromPost"{
            let pvc = segue.destination as! ProfiloViewController
            let utenteSelezionato=Utente()
            utenteSelezionato.idUtente=feed.idEntitaHeaderFeed
            pvc.utente=utenteSelezionato
            pvc.fromTabBar=false
        }else if segue.identifier == "GoToAziendaFromPost"{
            let advc = segue.destination as! AziendaDettaglioViewController
            let azSelezionata=Azienda()
            azSelezionata.nomeAzienda=""
            azSelezionata.idAzienda=feed.idEntitaHeaderFeed
            advc.azienda=azSelezionata
        }
    }
    
}
