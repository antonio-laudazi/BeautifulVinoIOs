//
//  BoardingViewController.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 03/04/18.
//  Copyright © 2018 Maria Tourbanova. All rights reserved.
//

import UIKit

class BoardingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    fileprivate let reuseIdentifier = "CellIdentifierBoarding"
    @IBOutlet weak var pageControl:UIPageControl?
    @IBOutlet weak var collectionView:UICollectionView?
    @IBOutlet weak var viewBassa:UIView!
    
    @IBOutlet weak var buttonSalta:UIButton!
    @IBOutlet weak var buttonEntra:UIButton!
    var cellVisibile:BoardingCollectionViewCell?
    
    private var viewRosa=UIView()
    private var viewGialla=UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl?.currentPage = 0
        pageControl?.numberOfPages = 3
        addViews()
        
        viewBassa.layer.shadowColor = UIColor.berry20.cgColor
        viewBassa.layer.shadowOpacity = 1
        viewBassa.layer.shadowOffset = CGSize(width: 0, height: -5)
        viewBassa.layer.shadowRadius = 14//blur
        viewBassa.layer.shadowPath = UIBezierPath(roundedRect: viewBassa.bounds, cornerRadius: 0).cgPath
        buttonEntra.isHidden=true
        UIApplication.shared.statusBarStyle = .default
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    private func addViews(){
        let altezzaScGialla=Double(self.view.frame.height / 1.85)//359
        let xScGialla = Double(self.view.frame.width / -5.95) //-63.0
        let yScGialla = Double(self.view.frame.height / 1.48)//450.0
        
        let altezzaScRosa:Double=Double(self.view.frame.height / 1.09)//614.0
        let xScRosa = Double(self.view.frame.width / -7.35)//-51.0
        let yScRosa = Double(self.view.frame.height / 1.55)//430.0
        
        viewRosa.frame = CGRect(x:xScRosa, y:yScRosa, width: altezzaScRosa, height: altezzaScRosa)
        viewRosa.backgroundColor=UIColor.bvRedPink
        
        viewGialla.frame = CGRect(x:xScGialla, y:yScGialla, width: altezzaScGialla, height: altezzaScGialla)
        viewGialla.backgroundColor=UIColor.bvDandelion
        
        self.viewRosa.layer.cornerRadius = self.viewRosa.frame.size.width / 2
        self.viewGialla.layer.cornerRadius = self.viewGialla.frame.size.width / 2
        
        self.view.insertSubview(viewRosa, at: 0)
        self.view.insertSubview(viewGialla, at: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BoardingCollectionViewCell
        if indexPath.row==0 {
            cell.labelTitolo.text="Scopri"
            cell.labelSottotitolo.text="Entra nel nostro club di\ndegustazione e partecipa solo a\neventi particolari"
            cell.imageViewImapara1.isHidden=true
            cell.imageViewImapara2.isHidden=true
            cell.imageViewScopri1.isHidden=false
            cell.imageViewScopri2.isHidden=false
            cell.imageViewGiocaMedaglia.isHidden=true
            cell.imageViewGiocaIphoneMockup.isHidden=true
            cell.imageViewGiocaInsideIphone.isHidden=true
            cell.imageViewGiocaBadge1.isHidden=true
            cell.imageViewGiocaBadge2.isHidden=true
            cell.imageViewGiocaBadge3.isHidden=true
        }else if indexPath.row==1 {
            cell.labelTitolo.text="Impara"
            cell.labelSottotitolo.text="Leggi le storie dei vignaioli, accedi a contenuti formativi scritti dai produttori ed esplora le mille sfaccettature del vino"
            cell.imageViewImapara1.isHidden=false
            cell.imageViewImapara2.isHidden=false
            cell.imageViewScopri1.isHidden=true
            cell.imageViewScopri2.isHidden=true
            cell.imageViewGiocaMedaglia.isHidden=true
            cell.imageViewGiocaIphoneMockup.isHidden=true
            cell.imageViewGiocaInsideIphone.isHidden=true
            cell.imageViewGiocaBadge1.isHidden=true
            cell.imageViewGiocaBadge2.isHidden=true
            cell.imageViewGiocaBadge3.isHidden=true
            
            cell.labelTitolo.alpha=0.0
            cell.labelSottotitolo.alpha=0.0
            cell.imageViewImapara1.alpha=0.0
            cell.imageViewImapara2.alpha=0.0
            cell.imageViewImapara1.transform=CGAffineTransform(translationX: 50, y: 0)
            cell.imageViewImapara2.transform=CGAffineTransform(translationX: 150, y: 0)
        }else{
            cell.labelTitolo.text="Gioca"
            cell.labelSottotitolo.text="Fai crescere la tua carta dei vini, guadagna esperienza e colleziona badge esperienziali"
            cell.imageViewGiocaMedaglia.isHidden=false
            cell.imageViewGiocaMedaglia.alpha=0.0
            cell.imageViewGiocaIphoneMockup.isHidden=false
            cell.imageViewGiocaInsideIphone.isHidden=false
            cell.imageViewImapara1.isHidden=true
            cell.imageViewImapara2.isHidden=true
            cell.imageViewScopri1.isHidden=true
            cell.imageViewScopri2.isHidden=true
            cell.imageViewGiocaBadge1.isHidden=false
            cell.imageViewGiocaBadge2.isHidden=false
            cell.imageViewGiocaBadge3.isHidden=false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.view.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        animateCerchioRosa(indexP:indexPath.row)
        animateTitle(alpha: 0.0, prossimoIndex: indexPath.row)
        animateBadges(alpha:0.0)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        animateCard(indexP:(pageControl?.currentPage)!)
        animateCerchioRosa(indexP:(pageControl?.currentPage)!)
        if pageControl?.currentPage==2 {
            animateBadges(alpha:1.0)
            buttonEntra.isHidden=false
            pageControl?.isHidden=true
            buttonSalta.isHidden=true
        }else{
            animateBadges(alpha:0.0)
            buttonEntra.isHidden=true
            pageControl?.isHidden=false
            buttonSalta.isHidden=false
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        let indexPath=IndexPath(row: (pageControl?.currentPage)!, section: 0)
        cellVisibile=collectionView!.cellForItem(at: indexPath) as? BoardingCollectionViewCell
    }
    
    /* func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
     //   let indexPath=IndexPath(row: (pageControl?.currentPage)!, section: 0)
     //  cellVisibile=collectionView?.cellForItem(at: indexPath) as? BoardingCollectionViewCell
     //    animateBadges(alpha:1.0)
     }*/
    
    func animateTitle(alpha:CGFloat, prossimoIndex:Int){
        UIView.animate(withDuration: 0.5, animations:{
            
            self.cellVisibile?.labelTitolo.alpha=0
            self.cellVisibile?.labelSottotitolo.alpha=0
            self.cellVisibile?.imageViewGiocaIphoneMockup.alpha=0
            self.cellVisibile?.imageViewGiocaInsideIphone.alpha=0
            self.cellVisibile?.imageViewImapara1.alpha=0
            self.cellVisibile?.imageViewImapara2.alpha=0
            self.cellVisibile?.imageViewScopri1.alpha=0
            self.cellVisibile?.imageViewScopri2.alpha=0
            self.cellVisibile?.imageViewGiocaMedaglia.alpha=0
            
            if alpha==0{
                self.cellVisibile?.imageViewScopri1.transform=CGAffineTransform(translationX: -50, y: 0)
                self.cellVisibile?.imageViewScopri2.transform=CGAffineTransform(translationX: -150, y: 0)
                if prossimoIndex==0{
                    self.cellVisibile?.imageViewImapara1.transform=CGAffineTransform(translationX: 50, y: 0)
                    self.cellVisibile?.imageViewImapara2.transform=CGAffineTransform(translationX: 150, y: 0)
                }else{
                    self.cellVisibile?.imageViewImapara1.transform=CGAffineTransform(translationX: -50, y: 0)
                    self.cellVisibile?.imageViewImapara2.transform=CGAffineTransform(translationX: -150, y: 0)
                }
            }else{
                /*   self.cellVisibile?.imageViewImapara1.transform=CGAffineTransform(translationX: 0, y: 0)
                 self.cellVisibile?.imageViewImapara2.transform=CGAffineTransform(translationX: 0, y: 0)
                 self.cellVisibile?.imageViewScopri1.transform=CGAffineTransform(translationX: 0, y: 0)
                 self.cellVisibile?.imageViewScopri2.transform=CGAffineTransform(translationX: 0, y: 0)*/
            }
        })
    }
    
    
    func animateCard(indexP:Int){
        if let cellB:BoardingCollectionViewCell=collectionView?.cellForItem(at: IndexPath(row: indexP, section: 0)) as? BoardingCollectionViewCell {
            UIView.animate(withDuration: 0.4, animations:{
                cellB.labelTitolo.alpha=1.0
                cellB.labelSottotitolo.alpha=1.0
                cellB.imageViewGiocaIphoneMockup.alpha=1.0
                cellB.imageViewGiocaInsideIphone.alpha=1.0
                cellB.imageViewImapara1.alpha=1.0
                cellB.imageViewImapara2.alpha=1.0
                cellB.imageViewScopri1.alpha=1.0
                cellB.imageViewScopri2.alpha=1.0
                
                cellB.imageViewImapara1.transform=CGAffineTransform(translationX: 0, y: 0)
                cellB.imageViewImapara2.transform=CGAffineTransform(translationX: 0, y: 0)
                cellB.imageViewScopri1.transform=CGAffineTransform(translationX: 0, y: 0)
                cellB.imageViewScopri2.transform=CGAffineTransform(translationX: 0, y: 0)
            })}
    }
    
    
    
    func animateCerchioRosa(indexP:Int){
        if indexP==0 {
            UIView.animate(withDuration: 0.5, animations:{
                self.viewRosa.transform=CGAffineTransform(scaleX: 1, y: 1)
                self.viewGialla.transform=CGAffineTransform(scaleX: 1, y: 1)
            })
        }else if indexP==1{
            UIView.animate(withDuration: 0.5, animations:{
                self.viewRosa.transform=CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.viewGialla.transform=CGAffineTransform(scaleX: 1.4, y: 1.4)
            })
        }else if indexP==2{
            UIView.animate(withDuration: 0.5, animations:{
                self.viewGialla.transform=CGAffineTransform(scaleX: 2, y: 2)
                self.viewRosa.transform=CGAffineTransform(scaleX: 1, y: 1).concatenating(CGAffineTransform(translationX: self.view.frame.width/1.5, y: 0))//250
            } )
        }
    }
    
    private func animateBadges(alpha:CGFloat){
        if let cellB:BoardingCollectionViewCell=collectionView?.cellForItem(at: IndexPath(row: 2, section: 0)) as? BoardingCollectionViewCell {
            let expandTransform:CGAffineTransform = CGAffineTransform(scaleX: 0.4, y: 0.4);
            let expand:CGAffineTransform = CGAffineTransform(scaleX: 1, y: 1);
            UIView.animate(withDuration: 0.5,
                           delay:0.0,
                           usingSpringWithDamping:0.40,
                           initialSpringVelocity:0.2,
                           options: .curveEaseOut,
                           animations:  {
                            cellB.imageViewGiocaBadge1.alpha=alpha
                            cellB.imageViewGiocaBadge2.alpha=alpha
                            cellB.imageViewGiocaBadge3.alpha=alpha
                            if alpha==1.0 {
                                cellB.imageViewGiocaBadge1.transform = expandTransform.inverted()
                                cellB.imageViewGiocaBadge2.transform = expandTransform.inverted()
                                cellB.imageViewGiocaBadge3.transform = expandTransform.inverted()
                                cellB.imageViewGiocaBadge1.transform = expand.inverted()
                                cellB.imageViewGiocaBadge2.transform = expand.inverted()
                                cellB.imageViewGiocaBadge3.transform = expand.inverted()
                            }}, completion: {
                                (value: Bool) in
                                UIView.animate(withDuration: 0.5,
                                               delay:0.0,
                                               usingSpringWithDamping:0.40,
                                               initialSpringVelocity:0.2,
                                               options: .curveEaseOut,
                                               animations:  {
                                                cellB.imageViewGiocaMedaglia.alpha=alpha
                                                if alpha==1.0 {
                                                    cellB.imageViewGiocaMedaglia.transform = expandTransform.inverted()
                                                    cellB.imageViewGiocaMedaglia.transform = expand.inverted()
                                                }
                                })
            })
        }
        
    }
    
    @IBAction func buttonEntraPressed(){
        UDManager.setFirstLaunch(first: true)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let eventiVC = storyBoard.instantiateViewController(withIdentifier: "EventiViewController")
        UIApplication.shared.keyWindow?.rootViewController = eventiVC
    }
    
    @IBAction func buttonSaltaPressed(){
        UDManager.setFirstLaunch(first: true)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let eventiVC = storyBoard.instantiateViewController(withIdentifier: "EventiViewController")
        UIApplication.shared.keyWindow?.rootViewController = eventiVC
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
