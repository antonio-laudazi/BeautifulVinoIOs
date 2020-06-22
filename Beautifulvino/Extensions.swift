//
//  UIImageView.swift
//  Beautifulvino
//
//  Created by Antonio Laudazi on 02/11/17.
//  Copyright © 2017 Maria Tourbanova. All rights reserved.
//

import UIKit

extension UIImageView {
    
    public func imageFromServerURL(urlString: String?, imagePlaceholder:UIImage, completionBlock: @escaping (Data?) -> Void) -> Void {
       // self.image = imagePlaceholder
        if let urlStr = urlString {
            if let url = NSURL(string: urlStr){
                URLSession.shared.dataTask(with: url as URL, completionHandler: { (data, response, error) -> Void in
                    DispatchQueue.main.async(execute: { () -> Void in
                        if error != nil {
                            self.image = imagePlaceholder
                            completionBlock(nil)
                            return
                        }else{
                            let image = UIImage(data: data!)
                            if image==nil{
                                completionBlock(nil);
                            }else{
                                self.image = image
                                completionBlock(data!)
                            }
                        }})
                }).resume()
            }
        }else{
            completionBlock(nil)
            self.image = imagePlaceholder
        }
    }
    
}

extension UITextField {
    
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor(white: 1, alpha: 0.6).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 0.0
    }
    
    func setBottomBorderForWhite() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.bvPurpleBrown.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 0.0
    }
    
    
}

extension Date {
    
    public func fromDateToSting()->String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd MMMM', ore' HH:mm"
        let now = dateformatter.string(from: self)
        return now
    }
    
}

extension String {
    
    public func fromStingToDate()->Date {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM/dd/yy hh:mm"
        let now = dateformatter.date(from: self)
        return now!
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf16) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension Int {
    public func fromIntSince1970ToStringDate()->String {
        let date = Date(timeIntervalSince1970: TimeInterval(self/1000))
        return date.fromDateToSting()
    }
}

extension UIColor {
    @nonobjc class var bvRedPink: UIColor {
        return UIColor(red: 241.0 / 255.0, green: 44.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var bvDandelion: UIColor {
        return UIColor(red: 252.0 / 255.0, green: 219.0 / 255.0, blue: 9.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var bvPurpleBrown: UIColor {
        return UIColor(red: 70.0 / 255.0, green: 43.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var bvWarmGrey: UIColor {
        return UIColor(red: 121.0 / 255.0, green: 113.0 / 255.0, blue: 113.0 / 255.0, alpha: 1.0)
    }
    
    
    @nonobjc class var berry20: UIColor {
        return UIColor(red: 137.0 / 255.0, green: 21.0 / 255.0, blue: 62.0 / 255.0, alpha: 0.2)
    }
}

// Text styles

extension UIFont {
    class func bvTitoloCartaDeiViniSchedaFont() -> UIFont? {
        return UIFont(name: "Larsseit-Bold", size: 24.0)
    }
    
    class func bvUiTextTitoloListaViniFont() -> UIFont? {
        return UIFont(name: "Larsseit-Bold", size: 23.0)
    }
    
}

extension UIImageView {
    
    public func setCornersSmall(){
        self.clipsToBounds = true
        self.layer.cornerRadius = 4.0
    }
    
    public func setCornersBig(){
        self.clipsToBounds = true
        self.layer.cornerRadius = 10.0
    }
    
    public func setImageRounded(){
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
    
    public func addBlackGradientLayer(frame: CGRect, colors:[UIColor]){
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = colors.map{$0.cgColor}
        self.layer.addSublayer(gradient)
    }
    
}

extension UITextView {
/*    func addCharacterSpacing(lineSpacing:CGFloat, characterLine:Double) {
        if let textViewText = text, textViewText.count > 0 {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = lineSpacing//5
            let attributes = [
                NSAttributedStringKey.foregroundColor : self.textColor!,
                NSAttributedStringKey.font : self.font!,
                NSAttributedStringKey.kern : characterLine,// 1.1,
                NSAttributedStringKey.paragraphStyle : style
                ] as [NSAttributedStringKey : Any]
            let attributedString = NSAttributedString(string: textViewText, attributes: attributes)
            attributedText = attributedString
        }
    }*/
    
    func addCharacterLineSpacingText() {
        if let textViewText = text, textViewText.count > 0 {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 5.5
            let attributes = [
                NSAttributedStringKey.foregroundColor : self.textColor!,
                NSAttributedStringKey.font : self.font!,
                NSAttributedStringKey.kern : 0.6,
                NSAttributedStringKey.paragraphStyle : style
                ] as [NSAttributedStringKey : Any]
            let attributedString = NSAttributedString(string: textViewText, attributes: attributes)
            attributedText = attributedString
        }
    }
}


extension UIView {
    
    public func setShadow(){
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.15
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 15//blur
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 4).cgPath
    }
    
    public func setShadowAndCorners(corners:UIRectCorner, x:CGFloat, y:CGFloat, offsetW:CGFloat, offsetH:CGFloat, cornerRadius:Int, colorBg:UIColor){
        self.clipsToBounds = true
        self.layer.masksToBounds=false
        self.backgroundColor = UIColor.clear
        let shadowLayer = CAShapeLayer()
        
        let viewWidth = self.bounds.width + offsetW
        let viewHeight = self.bounds.height + offsetH
        let rect = CGRect(origin: CGPoint(x:self.bounds.origin.x+x, y:self.bounds.origin.y+y), size: CGSize(width: viewWidth, height: viewHeight) )
        
        shadowLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        shadowLayer.shouldRasterize = true
        shadowLayer.rasterizationScale = UIScreen.main.scale
        shadowLayer.fillColor = colorBg.cgColor
        shadowLayer.shadowColor = UIColor.black.cgColor
        
        let path = UIBezierPath(rect: rect)
        
        shadowLayer.shadowPath = path.cgPath
        shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
        shadowLayer.shadowOpacity = 0.15 //1.0 //
        shadowLayer.shadowRadius = 15
        self.layer.insertSublayer(shadowLayer, at: 0)
    }
    
    /* public func addshadow(top: Bool,
     left: Bool,
     bottom: Bool,
     right: Bool,
     shadowRadius: CGFloat = 20.0) {
     
     self.layer.masksToBounds = false
     self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
     self.layer.shadowRadius = shadowRadius
     self.layer.shadowOpacity = 0.15//1//
     
     let path = UIBezierPath()
     var x: CGFloat = 0
     var y: CGFloat = 0
     var viewWidth = self.frame.width
     var viewHeight = self.frame.height
     
     // here x, y, viewWidth, and viewHeight can be changed in
     // order to play around with the shadow paths.
     if (!top) {
     y+=(shadowRadius+11)
     }
     if (!bottom) {
     viewHeight-=(shadowRadius+11)
     }
     if (!left) {
     x+=(shadowRadius+11)
     }
     if (!right) {
     viewWidth-=(shadowRadius+11)
     }
     // selecting top most point
     path.move(to: CGPoint(x: x, y: y))
     // Move to the Bottom Left Corner, this will cover left edges
     /*
     */
     path.addLine(to: CGPoint(x: x, y: viewHeight))
     // Move to the Bottom Right Corner, this will cover bottom edge
     
     path.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
     // Move to the Top Right Corner, this will cover right edge
     /*
     ☐|
     */
     path.addLine(to: CGPoint(x: viewWidth, y: y))
     // Move back to the initial point, this will cover the top edge
     /*
     _
     ☐
     */
     path.close()
     self.layer.shadowPath = path.cgPath
     }*/
    
    func fadeIn(withDuration duration: TimeInterval = 0.5, y:CGFloat) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
            self.frame = CGRect(x:self.frame.origin.x, y:y, width:self.frame.size.width, height:self.frame.size.height)
        })
    }
    
    /// Fade out a view with a duration
    ///
    /// - Parameter duration: custom animation duration
    func fadeOut(withDuration duration: TimeInterval = 0.5, y:CGFloat) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
            self.frame = CGRect(x:self.frame.origin.x, y:y, width:self.frame.size.width, height:self.frame.size.height)
        })
    }
    
}

extension UISegmentedControl{
    
    func addUnderlineForSelectedSegment(){
        let underlineWidth: CGFloat = (self.frame.size.width / CGFloat(self.numberOfSegments))-30.0
        let underlineHeight: CGFloat = 3.0
        let underlineXPosition = CGFloat(selectedSegmentIndex * Int(underlineWidth))+15.0
        let underLineYPosition = self.bounds.size.height - 3.0
        let underlineFrame = CGRect(x: underlineXPosition, y: underLineYPosition, width: underlineWidth, height: underlineHeight)
        let underline = UIView(frame: underlineFrame)
        underline.backgroundColor = UIColor(red: 241/255, green: 44/255, blue: 114/255, alpha: 1.0)
        underline.tag = 1
        self.addSubview(underline)
    }
    
    func changeUnderlinePosition(){
        guard let underline = self.viewWithTag(1) else {return}
        var underlineFinalXPosition=CGFloat(0)
        if self.selectedSegmentIndex==1 {
            underlineFinalXPosition=self.frame.width/2
        } else if self.selectedSegmentIndex==2 {
            underlineFinalXPosition = self.frame.width-underline.frame.size.width-15
        }else{
            underlineFinalXPosition = (self.frame.width / CGFloat(self.numberOfSegments)) * CGFloat(selectedSegmentIndex)+15.0
        }
        UIView.animate(withDuration: 0.1, animations: {
            if self.selectedSegmentIndex==1 {
                underline.frame.origin.x = underlineFinalXPosition-underline.frame.width/2
            }else{
                underline.frame.origin.x = underlineFinalXPosition
            }
            
        })
    }
}


extension UIButton{
    func addCornerRadius(){
        DispatchQueue.main.async {
            self.layer.cornerRadius = self.frame.size.height/2
            self.clipsToBounds = true
            
        }
    }
}

