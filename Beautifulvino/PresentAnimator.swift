//
//  PopAnimator.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 22/01/18.
//  Copyright © 2018 Maria Tourbanova. All rights reserved.
//

import UIKit

class PresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.2
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: .from)?.childViewControllers[0] as! EventiViewController
        let toViewController = transitionContext.viewController(forKey: .to) as! EventoDettaglioViewController
        let containerView = transitionContext.containerView
        let selectedRow = fromViewController.tableViewEventi.indexPathForSelectedRow
        let cell = fromViewController.tableViewEventi.cellForRow(at: selectedRow!) as! EventoTableViewCell
        
        let imageViewSfondo = cell.imageViewSfondoEvento.snapshotView(afterScreenUpdates: false)!
        imageViewSfondo.frame = cell.convert(cell.imageViewSfondoEvento.frame, to: fromViewController.tableViewEventi.superview)
        cell.imageViewSfondoEvento.isHidden = true
        
        let imageViewPin = cell.imageViewPinEvento.snapshotView(afterScreenUpdates: false)
        imageViewPin?.frame = cell.convert(cell.imageViewPinEvento.frame, to: fromViewController.tableViewEventi.superview)
        cell.imageViewPinEvento.isHidden = true
        
        let labelCitta = cell.labelCittaEvento.snapshotView(afterScreenUpdates: false)
        labelCitta?.frame = cell.convert(cell.labelCittaEvento.frame, to: fromViewController.tableViewEventi.superview)
        cell.labelCittaEvento.isHidden = true
        
        let viewShadow = cell.viewShadowEvento.snapshotView(afterScreenUpdates: false)
        viewShadow?.clipsToBounds = true
        viewShadow?.layer.cornerRadius = 10.0
        viewShadow?.frame = cell.convert(cell.viewShadowEvento.frame, to: fromViewController.tableViewEventi.superview)
        cell.viewShadowEvento.isHidden = true
        
        let labelTitolo = cell.labelTitoloEvento.snapshotView(afterScreenUpdates: false)
        labelTitolo?.frame = cell.convert(cell.labelTitoloEvento.frame, to: fromViewController.tableViewEventi.superview)
        cell.labelTitoloEvento.isHidden = true
        
        let labelData = cell.labelDataEvento.snapshotView(afterScreenUpdates: false)
        labelData?.frame = cell.convert(cell.labelDataEvento.frame, to: fromViewController.tableViewEventi.superview)
        cell.labelDataEvento.isHidden = true
        
        let labelPrezzo = cell.labelPrezzoEvento.snapshotView(afterScreenUpdates: false)
        labelPrezzo?.frame = cell.convert(cell.labelPrezzoEvento.frame, to: fromViewController.tableViewEventi.superview)
        cell.labelPrezzoEvento.isHidden = true
        labelPrezzo?.backgroundColor = UIColor.bvDandelion
        labelPrezzo?.layer.cornerRadius = 12.0
        labelPrezzo?.clipsToBounds = true
        
        toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
        toViewController.view.alpha = 0
        
        toViewController.imageViewEvento.isHidden = true
        toViewController.viewTitleShadowEvento.isHidden = true
        toViewController.labelTitolo.isHidden = true
        toViewController.labelData.isHidden = true
        toViewController.labelPrezzo.isHidden = true
        toViewController.imageViewPin.isHidden = true
        toViewController.buttonPreferito.isHidden = true
        toViewController.labelLuogo.isHidden = true
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(imageViewSfondo)
        containerView.addSubview(imageViewPin!)
        containerView.addSubview(labelCitta!)
        containerView.addSubview(viewShadow!)
        containerView.addSubview(labelTitolo!)
        containerView.addSubview(labelData!)
        containerView.addSubview(labelPrezzo!)
        
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            toViewController.view.setNeedsLayout()
            toViewController.view.layoutIfNeeded()
            
            toViewController.view.alpha = 1.0
            let endRectImageViewSfondo = containerView.convert(toViewController.imageViewEvento.frame, from: toViewController.view)
            let endRectImageViewPin = containerView.convert(toViewController.imageViewPin.frame, from: toViewController.view)
            let endRectLabelCitta = containerView.convert(toViewController.labelLuogo.frame, from: toViewController.view)
            let endRectShadow = containerView.convert(toViewController.viewTitleShadowEvento.frame, from: toViewController.view)
            let endRectLabelTitolo = containerView.convert(toViewController.labelTitolo.frame, from: toViewController.viewTitleShadowEvento)
            let endRectLabelData = containerView.convert(toViewController.labelData.frame, from: toViewController.viewTitleShadowEvento)
            let endRectLabelPrezzo = containerView.convert(toViewController.labelPrezzo.frame, from: toViewController.viewTitleShadowEvento)
            imageViewSfondo.frame=CGRect(x: endRectImageViewSfondo.origin.x, y: endRectImageViewSfondo.origin.y+20, width: endRectImageViewSfondo.size.width, height: endRectImageViewSfondo.size.height)
            imageViewPin?.frame = endRectImageViewPin
            labelCitta?.frame = endRectLabelCitta
            viewShadow?.frame = endRectShadow
            labelTitolo?.frame = endRectLabelTitolo
            labelData?.frame = endRectLabelData
            labelPrezzo?.frame = endRectLabelPrezzo
        }) { (finished) -> Void in
            toViewController.imageViewEvento.isHidden = false
            cell.imageViewSfondoEvento.isHidden = false
            imageViewSfondo.removeFromSuperview()
            
            toViewController.imageViewPin.isHidden = false
            cell.imageViewPinEvento.isHidden = false
            imageViewPin?.removeFromSuperview()
            
            toViewController.buttonPreferito.isHidden = false
            
            toViewController.labelLuogo.isHidden = false
            cell.labelCittaEvento.isHidden = false
            labelCitta?.removeFromSuperview()
            
            toViewController.viewTitleShadowEvento.isHidden = false
            cell.viewShadowEvento.isHidden = false
            viewShadow?.removeFromSuperview()
            
            toViewController.labelTitolo.isHidden = false
            cell.labelTitoloEvento.isHidden = false
            labelTitolo?.removeFromSuperview()
            
            toViewController.labelPrezzo.isHidden = false
            cell.labelPrezzoEvento.isHidden = false
            labelPrezzo?.removeFromSuperview()
            
            toViewController.labelData.isHidden = false
            cell.labelDataEvento.isHidden = false
            labelData?.removeFromSuperview()
            fromViewController.tableViewEventi.deselectRow(at: selectedRow!, animated: false)
            
            transitionContext.completeTransition(true)
        }
        
    }
    
}
