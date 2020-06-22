//
//  EventoDettaglioViewController.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 27/10/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit

class ListaViniViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ConnectionManagerDelegate {
    
    var evento:Evento!
    private var vinoSelezionato:Vino!
    private var aziendaSelezionata:Azienda!
    private var aziende:[Azienda]!
    private let cManager = ConnectionManager()
    
    @IBOutlet weak var tableViewVini: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cManager.delegate=self
        showLoading()
        if(aziende==nil){
            aziende=[Azienda]()
        }
        
        tableViewVini.register(UINib(nibName: "VinoTableViewCell", bundle: nil), forCellReuseIdentifier: "CellIdentifierVino")
        let nib = UINib(nibName: "TableSectionHeaderAzienda", bundle: nil)
        tableViewVini.register(nib, forHeaderFooterViewReuseIdentifier: "IdentifierSectionHeaderAzienda")
      //  let nibFooter = UINib(nibName: "TableSectionFooterVino", bundle: nil)
       // tableViewVini.register(nibFooter, forHeaderFooterViewReuseIdentifier: "IdentifierSectionFooterVino")
        
        cManager.getViniEvento(evento: evento)
        tableViewVini.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        cManager.delegate=self
        UIApplication.shared.statusBarStyle = .default
        setNeedsStatusBarAppearanceUpdate()
    }

    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aziende[section].viniAzienda.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return aziende.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = self.tableViewVini.dequeueReusableHeaderFooterView(withIdentifier: "IdentifierSectionHeaderAzienda")
        let header = cell as! TableSectionHeaderAzienda
        let az: Azienda=aziende[section]
        header.labelNomeAzienda.text=az.nomeAzienda
        header.tag=section
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(ListaViniViewController.sectionAziendaPressed(sender:)))
        cell?.addGestureRecognizer(headerTapGesture)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(Height.tableSectionHeaderAzienda)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.backgroundColor = UIColor.clear
        let viewShadow = UIView(frame: CGRect(x: 15, y: 0, width: self.view.frame.size.width-31, height: 30))
        viewShadow.setShadowAndCorners(corners: [.bottomLeft, .bottomRight], x:0, y:20, offsetW: 0, offsetH: -20, cornerRadius: 10, colorBg: .white)
        vw.addSubview(viewShadow)
        return vw
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return CGFloat(Height.vinoTableViewCell)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifierVino", for: indexPath) as! VinoTableViewCell
        let v=aziende[indexPath.section].viniAzienda[indexPath.row]
        cell.setData(vino: v)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let vdvc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "IdentifierVinoDettaglioViewController") as! VinoDettaglioViewController
        vdvc.vino=aziende[indexPath.section].viniAzienda[indexPath.row]
        self.present(vdvc, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    // MARK: - IBAction
    @objc func sectionAziendaPressed(sender: UITapGestureRecognizer) {
        let advc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "IdentifierAziendaDettaglioViewController") as! AziendaDettaglioViewController
        advc.azienda=aziende[(sender.view?.tag)!]
        self.present(advc, animated: true, completion: nil)
    }
    
    @IBAction func buttonChiudiPressed(){
        dismiss(animated: true, completion: nil);
    }
    
    // MARK: - ConnectionManagerDelegate
    
    func viniEventoDidReceive(aziende:[Azienda]?, errore:String){
        if errore=="" {
            self.aziende=aziende
        }else{
            DispatchQueue.main.async() {
                self.showAlert(titolo: "Errore", msg: errore)
            }
        }
        DispatchQueue.main.async() {
            self.tableViewVini.reloadData()
            self.hideLoading()
        }
    }
    
    func viniEventoDidReceiveWithError(error:Error){
        DispatchQueue.main.async() {
            self.hideLoading()
            self.showAlert(titolo: "Errore", msg: error.localizedDescription)
        }
    }
    
    // MARK: - Private
    
    private func showAlert(titolo:String, msg:String){
        let alert = UIAlertController(title: titolo, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showLoading(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    private func hideLoading(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
       // caricamentoView.removeFromSuperview()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "GoToAziendaFromEvento"{
            let advc = segue.destination as! AziendaDettaglioViewController
            advc.azienda=aziendaSelezionata
        }
    }
    
}

