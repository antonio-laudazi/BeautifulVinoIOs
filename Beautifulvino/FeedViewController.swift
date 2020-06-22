//
//  FirstViewController.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 26/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ConnectionManagerDelegate {
    
    @IBOutlet weak var tableViewFeed: UITableView!
    var caricamentoView=CaricamentoView.instanceFromNib()
    private let cManager = ConnectionManager()//AppDelegate.connectionManager
    private let refreshControl = UIRefreshControl()
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var feedArray:[Feed]!
    private var footerView:UIView!
    var numTotFeed = 0
    private var idProvincia = -1
    private var requestType:RequestTypeList!
  //  private var ultimoFeedRicevutoJson:Feed!
    private var feedSelezionato:Feed!
    private var headerClicked:Bool!
    private var loadedError:Bool=false
    private var loaded:Bool=false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(refreshFeed(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        tableViewFeed.register(UINib(nibName: "FeedAziendaTableViewCell", bundle: nil), forCellReuseIdentifier: "CellIdentifierFeedAzienda")
        if #available(iOS 10.0, *) {
            tableViewFeed.refreshControl = refreshControl
        } else {
            tableViewFeed.addSubview(refreshControl)
        }
        cManager.delegate=self
      if feedArray==nil {
            feedArray=[Feed]()
            tableViewFeed.reloadData()
            showLoading()
            requestType=RequestTypeList.refresh
            cManager.getFeed(ultimoFeed:nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        setNeedsStatusBarAppearanceUpdate()
        cManager.delegate=self
        tableViewFeed.tableFooterView?.isHidden = true
        spinner.stopAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Analytics.setScreenName("I_ListaFeed", screenClass: "FeedViewController")
    }
    
    /* override func viewWillDisappear(_ animated: Bool) {
     requestIsFinished()
     cManager.cancelRequest(typeRequest: cManager.request_get_feed)
     }*/
    
    // MARK: - tableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return feedArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        let f=feedArray[indexPath.row]
        if f.tipoFeed == Feed.TipoFeed.pubblicita.rawValue{
            return CGFloat(Height.feedPubblicitaTableViewCell)
        }else if f.tipoFeed == Feed.TipoFeed.azienda.rawValue{
            return CGFloat(Height.feedAziendaTableViewCell)
        }else if f.tipoFeed == Feed.TipoFeed.evento.rawValue || f.tipoFeed == Feed.TipoFeed.vino.rawValue{
            return CGFloat(Height.feedAzioneTableViewCell)
        }else {
            return CGFloat(Height.feedPostTableViewCell)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let f=feedArray[indexPath.row]
        
        if f.tipoFeed == Feed.TipoFeed.pubblicita.rawValue{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifierFeedPubblicita", for: indexPath) as! FeedPubblicitaTableViewCell
            cell.setData(feed: f)
            return cell
        }else if f.tipoFeed == Feed.TipoFeed.azienda.rawValue{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifierFeedAzienda", for: indexPath) as! FeedAziendaTableViewCell
            cell.setData(feed: f, tag: indexPath.row)
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            cell.headerView.addGestureRecognizer(tapGes)
            tapGes.view?.tag=indexPath.row
            return cell
        }else if f.tipoFeed == Feed.TipoFeed.evento.rawValue || f.tipoFeed == Feed.TipoFeed.vino.rawValue{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifierFeedAzione", for: indexPath) as! FeedAzioneTableViewCell
            cell.setData(feed:f, tag: indexPath.row)
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            cell.headerView.addGestureRecognizer(tap)
            tap.view?.tag=indexPath.row
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifierFeedPost", for: indexPath) as! FeedPostTableViewCell
            cell.setData(feed: f, tag: indexPath.row)
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            cell.headerView.addGestureRecognizer(tap)
            tap.view?.tag=indexPath.row
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (feedArray.count < numTotFeed && indexPath.row==feedArray.count-1 && !loadedError && !loaded) {
            loaded=true
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
            tableViewFeed.tableFooterView = spinner
            tableViewFeed.tableFooterView?.isHidden = false
            requestType=RequestTypeList.more
            cManager.getFeed(ultimoFeed: self.feedArray[feedArray.count-1])
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        headerClicked=false
        feedSelezionato=feedArray[indexPath.row]
        tableViewFeed.deselectRow(at: indexPath, animated: false)
        if feedSelezionato.tipoFeed == Feed.TipoFeed.pubblicita.rawValue || feedSelezionato.tipoFeed == Feed.TipoFeed.vino.rawValue {
            performSegue(withIdentifier: "GoToDettaglioVinoFromFeed", sender: nil)
        }else if feedSelezionato.tipoFeed == Feed.TipoFeed.azienda.rawValue || feedSelezionato.tipoFeed == Feed.TipoFeed.post.rawValue {
            performSegue(withIdentifier: "GoToDettaglioPostFromFeed", sender: nil)
        }else if feedSelezionato.tipoFeed == Feed.TipoFeed.evento.rawValue {
            performSegue(withIdentifier: "GoToDettaglioEventoFromFeed", sender: nil)
        }
    }
    
    @objc func handleTap(_ sender:AnyObject) {
        headerClicked=true
        feedSelezionato=feedArray[sender.view.tag]
        if feedSelezionato.tipoEntitaHeaderFeed == Feed.TipoEntitaHeaderFeed.azienda.rawValue {
            performSegue(withIdentifier: "GoToDettaglioAziendaFromFeed", sender: nil)
        }else if feedSelezionato.tipoEntitaHeaderFeed == Feed.TipoEntitaHeaderFeed.evento.rawValue{
            performSegue(withIdentifier: "GoToDettaglioEventoFromFeed", sender: nil)
        }else if feedSelezionato.tipoEntitaHeaderFeed == Feed.TipoEntitaHeaderFeed.profilo.rawValue {
            performSegue(withIdentifier: "GoToDettaglioProfiloFromFeed", sender: nil)
        }else if feedSelezionato.tipoEntitaHeaderFeed == Feed.TipoEntitaHeaderFeed.vino.rawValue {
            performSegue(withIdentifier: "GoToDettaglioVinoFromFeed", sender: nil)
        }
    }
    
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
        self.tableViewFeed.tableFooterView?.isHidden=true
        self.hideLoading()
        self.refreshControl.endRefreshing()
    }
    
    @objc private func refreshFeed(_ sender: Any) {
        requestType=RequestTypeList.refresh
        showLoading()
        cManager.getFeed(ultimoFeed:nil)
    }
    
    // MARK: - ConnectionManagerDelegate
    
    func feedArrayDidReceive(feedA:[Feed]?, numTotFeed:Int, errore:String){
        if errore=="" {
            if(requestType==RequestTypeList.refresh){
                self.feedArray=feedA
                self.numTotFeed=numTotFeed
                DispatchQueue.main.async() {
                    self.tableViewFeed.reloadData()
                }
            }else{
            //    self.feedArray.append(contentsOf: feedArray!)
             //   self.numTotFeed=numTotFeed
                let c:Int=feedArray.count
                self.feedArray.append(contentsOf: feedA!)
                let a:Int=feedArray.count-1
                self.numTotFeed=numTotFeed
                var r: Array<IndexPath>=Array()
                for i in c...a {
                    let indexPath=IndexPath(row: i, section: 0)
                    r.append(indexPath)
                }
                DispatchQueue.main.async() {
                    self.tableViewFeed.insertRows(at: r, with: .none)
                }
            }
            loadedError=false
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
    
    func feedArrayDidReceiveWithError(error:Error){
        loadedError=true
        loaded=false
        DispatchQueue.main.async () {
            self.requestIsFinished()
            self.tableViewFeed.reloadData()
            self.showAlert(titolo: "Errore", msg: error.localizedDescription)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if headerClicked==false {
            if segue.identifier == "GoToDettaglioVinoFromFeed"{
                let vdvc = segue.destination as! VinoDettaglioViewController
                vdvc.vino=feedSelezionato.vinoFeedInt
            }else if segue.identifier == "GoToDettaglioEventoFromFeed"{
                let edvc = segue.destination as! EventoDettaglioViewController
               let evento=feedSelezionato.eventoFeedInt
                edvc.evento=evento
            }else if segue.identifier == "GoToDettaglioPostFromFeed"{
                let pdvc = segue.destination as! PostDettaglioViewController
                pdvc.feed=feedSelezionato
            }
        }else{
            if segue.identifier == "GoToDettaglioAziendaFromFeed"{
                let advc = segue.destination as! AziendaDettaglioViewController
                let az=Azienda()
                az.nomeAzienda=""
                az.idAzienda=feedSelezionato.idEntitaHeaderFeed
                advc.azienda=az
            }else if segue.identifier == "GoToDettaglioEventoFromFeed"{
                let edvc = segue.destination as! EventoDettaglioViewController
                let evento=Evento()
                evento.idEvento=feedSelezionato.idEntitaHeaderFeed
                evento.dataEvento=feedSelezionato.dataEntitaHeaderFeed
                evento.titoloEvento=""
                edvc.evento=evento
            }else if segue.identifier == "GoToDettaglioProfiloFromFeed"{
                let pdvc = segue.destination as! ProfiloViewController
                let pr = Utente()
                pr.idUtente=feedSelezionato.idEntitaHeaderFeed
                pdvc.utente=pr
                pdvc.fromTabBar=false
            }else if segue.identifier == "GoToDettaglioVinoFromFeed"{
                let vdvc = segue.destination as! VinoDettaglioViewController
                let vino=Vino()
                vino.idVino=feedSelezionato.idEntitaFeed
                vino.nomeVino=""
                vdvc.vino=vino
            }
        }
    }
    
    
}


