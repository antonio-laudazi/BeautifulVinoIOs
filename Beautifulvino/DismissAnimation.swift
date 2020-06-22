//
//  PopAnimator.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 22/01/18.
//  Copyright © 2018 Maria Tourbanova. All rights reserved.
//

import UIKit

class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.2
    
    var dismissCompletion: (()->Void)?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let toViewController = transitionContext.viewController(forKey: .to)
        let eventiController=transitionContext.viewController(forKey: .to)?.childViewControllers[0] as! EventiViewController
        let fromViewController = transitionContext.viewController(forKey: .from) as! EventoDettaglioViewController
        
        let containerView = transitionContext.containerView
        
        let cellSelezionata = eventiController.eventoCellSelezionato!
        
        let imageViewSfondo = fromViewController.imageViewEvento.snapshotView(afterScreenUpdates: false)
        imageViewSfondo?.frame = containerView.convert(fromViewController.imageViewEvento.frame, from: fromViewController.view)
        fromViewController.imageViewEvento.isHidden = true
        imageViewSfondo?.layer.cornerRadius = 8.0
        imageViewSfondo?.clipsToBounds = true
        imageViewSfondo?.contentMode = .scaleAspectFill
        let imageViewPin = fromViewController.imageViewPin.snapshotView(afterScreenUpdates: false)
        imageViewPin?.frame = containerView.convert(fromViewController.imageViewPin.frame, from: fromViewController.view)
        fromViewController.imageViewPin.isHidden = true
        
        let labelCitta = fromViewController.labelLuogo.snapshotView(afterScreenUpdates: false)
        labelCitta?.frame = containerView.convert(fromViewController.labelLuogo.frame, from: fromViewController.view)
        fromViewController.labelLuogo.isHidden = true
        
        fromViewController.buttonPreferito.isHidden = true
        
        let viewShadow = UIView()
        viewShadow.backgroundColor = .white
        viewShadow.clipsToBounds = true
        viewShadow.layer.cornerRadius = 10.0
        viewShadow.frame = containerView.convert(fromViewController.viewTitleShadowEvento.frame, from: fromViewController.view)
        fromViewController.viewTitleShadowEvento.isHidden = true
        
        let labelTitolo = fromViewController.labelTitolo.snapshotView(afterScreenUpdates: false)
        labelTitolo?.frame = containerView.convert(fromViewController.labelTitolo.frame, from: fromViewController.viewTitleShadowEvento)
        
        fromViewController.labelTitolo.isHidden = true
        
        let labelData = fromViewController.labelData.snapshotView(afterScreenUpdates: false)
        labelData?.frame = containerView.convert(fromViewController.labelData.frame, from: fromViewController.viewTitleShadowEvento)
        
        fromViewController.labelData.isHidden = true
        labelData?.clipsToBounds = false
        
        let labelPrezzo = fromViewController.labelPrezzo.snapshotView(afterScreenUpdates: false)
        labelPrezzo?.frame = containerView.convert(fromViewController.labelPrezzo.frame, from: fromViewController.viewTitleShadowEvento)
        
        fromViewController.labelPrezzo.isHidden = true
        labelPrezzo?.backgroundColor = UIColor.bvDandelion
        labelPrezzo?.layer.cornerRadius = 12.0
        labelPrezzo?.clipsToBounds = true
        
        eventiController.view.alpha = 0
        
        cellSelezionata.imageViewSfondoEvento.isHidden = true
        cellSelezionata.imageViewPinEvento.isHidden = true
        cellSelezionata.labelCittaEvento.isHidden=true
        cellSelezionata.viewShadowEvento.isHidden = true
        cellSelezionata.labelTitoloEvento.isHidden = true
        cellSelezionata.labelDataEvento.isHidden = true
        cellSelezionata.labelPrezzoEvento.isHidden = true
        
        containerView.addSubview((toViewController?.view)!)
        containerView.addSubview(viewShadow)
        containerView.addSubview(imageViewSfondo!)
        containerView.addSubview(imageViewPin!)
        containerView.addSubview(labelCitta!)
        containerView.addSubview(labelTitolo!)
        containerView.addSubview(labelData!)
        containerView.addSubview(labelPrezzo!)
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            //toViewController.view.setNeedsLayout()
            // toViewController.view.layoutIfNeeded()
            eventiController.view.alpha = 1.0

            var endRectImageViewSfondo = cellSelezionata.convert(cellSelezionata.imageViewSfondoEvento.frame, to: cellSelezionata)
            endRectImageViewSfondo.origin.y=endRectImageViewSfondo.origin.y+eventiController.yOfCellInSuperview

            var endRectImageViewPin = cellSelezionata.convert(cellSelezionata.imageViewPinEvento.frame, from: cellSelezionata)
            endRectImageViewPin.origin.y=endRectImageViewPin.origin.y+eventiController.yOfCellInSuperview

            var endRectLabelCitta = cellSelezionata.convert(cellSelezionata.labelCittaEvento.frame, from: cellSelezionata)
            endRectLabelCitta.origin.y=endRectLabelCitta.origin.y+eventiController.yOfCellInSuperview

            var endRectShadow = cellSelezionata.convert(cellSelezionata.viewShadowEvento.frame, from: cellSelezionata)
            endRectShadow.origin.y=endRectShadow.origin.y+eventiController.yOfCellInSuperview

            var endRectLabelTitolo = cellSelezionata.convert(cellSelezionata.labelTitoloEvento.frame, from: cellSelezionata)
            endRectLabelTitolo.origin.y=endRectLabelTitolo.origin.y+eventiController.yOfCellInSuperview

            var endRectLabelData = cellSelezionata.convert(cellSelezionata.labelDataEvento.frame, from: cellSelezionata)
            endRectLabelData.origin.y=endRectLabelData.origin.y+eventiController.yOfCellInSuperview

            var endRectLabelPrezzo = cellSelezionata.convert(cellSelezionata.labelPrezzoEvento.frame, from:cellSelezionata)
            endRectLabelPrezzo.origin.y=endRectLabelPrezzo.origin.y+eventiController.yOfCellInSuperview

            imageViewSfondo?.frame = endRectImageViewSfondo
            imageViewPin?.frame = endRectImageViewPin
            labelCitta?.frame = endRectLabelCitta
            viewShadow.frame = endRectShadow
            labelTitolo?.frame = endRectLabelTitolo
            labelData?.frame = endRectLabelData
            labelPrezzo?.frame = endRectLabelPrezzo
        }, completion: { _ in
            fromViewController.imageViewEvento.isHidden = false
            cellSelezionata.imageViewSfondoEvento.isHidden = false
            toViewController?.view.removeFromSuperview()
            imageViewSfondo?.removeFromSuperview()
            
            fromViewController.imageViewPin.isHidden = false
            cellSelezionata.imageViewPinEvento.isHidden = false
            imageViewPin?.removeFromSuperview()
            
            fromViewController.buttonPreferito.isHidden = false
            
            fromViewController.labelLuogo.isHidden = false
            cellSelezionata.labelCittaEvento.isHidden = false
            labelCitta?.removeFromSuperview()
            
            fromViewController.viewTitleShadowEvento.isHidden = false
            cellSelezionata.viewShadowEvento.isHidden = false
            viewShadow.removeFromSuperview()
            
            fromViewController.labelTitolo.isHidden = false
            cellSelezionata.labelTitoloEvento.isHidden = false
            labelTitolo?.removeFromSuperview()
            
            fromViewController.labelData.isHidden = false
            cellSelezionata.labelDataEvento.isHidden = false
            labelData?.removeFromSuperview()
            
            fromViewController.labelPrezzo.isHidden = false
            cellSelezionata.labelPrezzoEvento.isHidden = false
            labelPrezzo?.removeFromSuperview()
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }
    
}

