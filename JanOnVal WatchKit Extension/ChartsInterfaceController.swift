//
//  ChartsInterfaceController.swift
//  JanOnVal WatchKit Extension
//
//  Created by Christian Stolz on 23.11.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import WatchKit
import Foundation
import UIKit

class ChartsInterfaceController: WKInterfaceController {
    
    
    @IBOutlet weak var image: WKInterfaceImage!
    
    let arrData = [(1.0,2.0), (2.0,2.0), (3.0,1.0),(4.0,2.0), (5.0,4.0),(6.0,3.0), (7.0,5.0),(8.0,3.0), (9.0,4.0),(10.0,5.0), (11.0,6.0), (12.0,4.0),(13.0,7.0), (14.0,5.0),(15.0,3.0), (16.0,6.0),(17.0,7.0), (18.0,4.0),(19.0,6.0)]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let size = CGSize( width: 160, height: 170)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        // Setup for the path appearance
        context!.setStrokeColor(UIColor.white.cgColor)
        context!.setLineWidth(3.0)
        
        // Draw lines
        context!.beginPath ();
        
        let coordoffsetleft = 5.0
        let coordoffsetbottom = 5.0
        let coordoffsetright = 0.0
        let coordoffsettop = 0.0
        
        
        let graphicheight = Double(size.height) - coordoffsetbottom - coordoffsettop
        let graphicwidth = Double(size.width) - coordoffsetleft - coordoffsetright
        
        let xminoffset = 0.0
        let xmaxoffset = 0.0
        let yminoffset = 0.0
        let ymaxoffset = 0.0
        
        let xmin = arrData.map({ $0.0}).min()!-xminoffset
        let xmax = arrData.map({ $0.0}).max()!+xmaxoffset
        let ymin = arrData.map({ $0.1}).min()!-yminoffset
        let ymax = arrData.map({ $0.1}).max()!+ymaxoffset

        let PixelPositionArr = arrData.map { ( ($0.0 - xmin)/(xmax-xmin) * graphicwidth + coordoffsetleft , (ymax - $0.1 )/(ymax-ymin) * graphicheight + coordoffsettop)}
        
        context?.move( to: CGPoint( x: PixelPositionArr[0].0, y: PixelPositionArr[0].1))
        for var i in  1 ... (PixelPositionArr.endIndex-1){
            context?.addLine( to: CGPoint( x: PixelPositionArr[i].0, y: PixelPositionArr[i].1))
            
        }
        
        context!.strokePath()
        
        context!.beginPath()
        context!.setLineWidth(1.0)
        context?.move( to: CGPoint( x: coordoffsetleft, y: coordoffsettop))
        context?.addLine( to: CGPoint( x: coordoffsetleft, y:coordoffsettop + graphicheight))
        context?.addLine( to: CGPoint( x: coordoffsetleft + graphicwidth, y: coordoffsettop + graphicheight))
        
        context!.strokePath();
        
        let cgimage = context!.makeImage();
        let uiimage = UIImage(cgImage: cgimage!)
        
        // End the graphics context
        UIGraphicsEndImageContext()
        
        // Show on WKInterfaceImage
        image.setImage(uiimage)

    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
