//
//  FirstViewController.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 26/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit
import Firebase

protocol ProvinciaDelegate {
    func provinciaChanged(provincia: Provincia)
}

class ProvinceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ConnectionManagerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet weak var tableViewProvince: UITableView!
    var caricamentoView=CaricamentoView.instanceFromNib()
    private let cManager = ConnectionManager()//AppDelegate.connectionManager
    private let refreshControl = UIRefreshControl()
    var delegate: ProvinciaDelegate!
    private var province:[Provincia]!
    private var filteredProvince = [Provincia]()
    private var provinciaSelezionata:Provincia!
    private var searchController=UISearchController(searchResultsController: nil)
    private var actInd: UIActivityIndicatorView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        province=[Provincia]()
        refreshControl.addTarget(self, action: #selector(refreshProvince(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        if #available(iOS 10.0, *) {
            tableViewProvince.refreshControl = refreshControl
        } else {
            tableViewProvince.addSubview(refreshControl)
        }
        cManager.delegate=self
        showLoading()
        filteredProvince = province
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
       // definesPresentationContext = true
        tableViewProvince.tableHeaderView = searchController.searchBar
        tableViewProvince.register(ProvinciaTableViewCell.self, forCellReuseIdentifier: "CellIdentifierProvincia")
        cManager.getProvince()
        NotificationCenter.default.addObserver(self, selector: #selector(ProvinceViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProvinceViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cManager.delegate=self
        UIApplication.shared.statusBarStyle = .default
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableViewProvince.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
        }
    }
    @objc func keyboardWillHide(_ notification:Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableViewProvince.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
    
    // MARK: - tableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filteredProvince.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifierProvincia", for: indexPath)
        let pr=filteredProvince[indexPath.row]
        cell.textLabel?.text=pr.nomeProvincia
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        Analytics.logEvent(AnalyticsEventViewSearchResults, parameters: [
            AnalyticsParameterSearchTerm: filteredProvince[indexPath.row].nomeProvincia ])
        
        UDManager.setProvincia(provincia: filteredProvince[indexPath.row])
        delegate?.provinciaChanged(provincia: filteredProvince[indexPath.row])
        searchController.dismiss(animated: false, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - SearchResults
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text! == "" {
            filteredProvince = province
        } else {
            // Filter the results
            filteredProvince = province.filter { $0.nomeProvincia.lowercased().contains(searchController.searchBar.text!.lowercased()) }
            filteredProvince=filteredProvince.sorted(by: { $0.nomeProvincia < $1.nomeProvincia })
        }
        
        self.tableViewProvince.reloadData()
    }
    
    
    // MARK: - Private
    
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        actInd.isHidden=true
        actInd.removeFromSuperview()
    }
    
    private func showAlert(titolo:String, msg:String){
        let alert = UIAlertController(title: titolo, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
 
    @objc private func refreshProvince(_ sender: Any) {
        showLoading()
        cManager.getProvince()
    }
    
    // MARK: - IBAction
    
    @IBAction func buttonChiudiPressed(){
        dismiss(animated: true, completion: nil);
    }
    
    
    // MARK: - ConnectionManagerDelegate
    
    func provinceDidReceive(province:[Provincia]?, errore:String){
        if errore==""{
            self.province=province!.sorted(by: { $0.nomeProvincia < $1.nomeProvincia })
            self.filteredProvince = province!.sorted(by: { $0.nomeProvincia < $1.nomeProvincia })
            
            DispatchQueue.main.async() {
                self.tableViewProvince.reloadData()
            }
        }else{
            DispatchQueue.main.async() {
                self.showAlert(titolo: "Errore", msg: errore)
            }
        }
        DispatchQueue.main.async() {
            self.hideLoading()
            self.refreshControl.endRefreshing()
        }
    }
    
    func provinceDidReceiveWithError(error:Error){
        DispatchQueue.main.async () {
            
            self.hideLoading()
            self.refreshControl.endRefreshing()
            self.tableViewProvince.reloadData()
            self.showAlert(titolo: "Errore", msg: error.localizedDescription)
        }
    }
    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToDettaglioEventoFromFeed"{
            let edvc = segue.destination as! EventoDettaglioViewController
            //edvc.evento=evento
        }
    }
    */
    
}


