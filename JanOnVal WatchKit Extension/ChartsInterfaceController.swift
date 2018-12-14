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
    
    private var fetchTask: URLSessionDataTask?
    private var dict: [String: Any] = [:]
    private var serverUrl = ""
    
    var arrData = [(1.0,2.0), (2.0,2.0), (3.0,1.0),(4.0,2.0), (5.0,4.0),(6.0,3.0), (7.0,5.0),(8.0,3.0), (9.0,4.0),(10.0,5.0),
                   (11.0,6.0), (12.0,4.0),(13.0,7.0), (14.0,15.0),(15.0,3.0), (16.0,6.0),(17.0,7.0), (18.0,4.0),(19.0,6.0),
                   (20.0,6.0), (21.0,5.0),(22.0,9.0), (23.0,5.0),(24.0,13.0), (25.0,6.0),(26.0,9.0), (27.0,3.0),(28.0,6.0)]
    
    fileprivate func showChart() {
        let size = CGSize( width: 160, height: 170)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        // Setup for the path appearance
        context!.setStrokeColor(UIColor.white.cgColor)
        context!.setLineWidth(2.0)
        
        // Draw lines
        //context!.beginPath ();
        
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
        
        let ystepsize = calculateStepsizeFor(yRange: ymax, ymin)
        
        let ytickmarkarr = Array(stride(from: ystepsize * (ymin/ystepsize).rounded(.down), through: ystepsize * (ymax/ystepsize).rounded(.up), by: ystepsize))
        let ytickmarkpixelposarr = ytickmarkarr.map { (ymax - $0 )/(ymax-ymin) * graphicheight + coordoffsettop }
        //        print(ytickmarkpixelposarr)
        let xminpixelpos = coordoffsetleft
        let xmaxpixelpos = graphicwidth - coordoffsetright
        let yminpixelpos = graphicheight - coordoffsetbottom
        let ymaxpixelpos = coordoffsettop
        
        for var i in  1 ... (ytickmarkpixelposarr.endIndex-1){
            let ypixelpos = (ymax - ytickmarkarr[i] )/(ymax-ymin) * graphicheight
            if( (ypixelpos > ymaxpixelpos) && (ypixelpos < yminpixelpos)){
                context?.beginPath()
                context!.setStrokeColor(UIColor.gray.cgColor)
                if( i % 10 == 0){
                    context!.setLineWidth(1.2)
                    
                    //let paragraphStyle = NSMutableParagraphStyle()
                    //paragraphStyle.alignment = .center
                    //
                    //let attributes = [
                    //    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                    //    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0),
                    //    NSAttributedString.Key.foregroundColor: UIColor.blue
                    //]
                    //let myText = "HELLO"
                    //let attributedString = NSAttributedString(string: myText, attributes: attributes)
                    //
                    //attributedString.draw(in: context)
                    
                }else if( i % 5 == 0){
                    context!.setLineWidth(0.9)
                }else{
                    context!.setLineWidth(0.5)
                }
                context?.move( to: CGPoint( x: xminpixelpos, y: ytickmarkpixelposarr[i]))
                context?.addLine( to: CGPoint( x: xmaxpixelpos, y: ytickmarkpixelposarr[i]))
                context?.strokePath()
                
            }
        }
        context!.beginPath()
        
        // Setup for the path appearance
        context!.setStrokeColor(UIColor.white.cgColor)
        context!.setLineWidth(2.0)
        
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
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let tServerUrl_MeasurementDict = context as? (String,[String: Any]) {
            serverUrl = tServerUrl_MeasurementDict.0
            dict = tServerUrl_MeasurementDict.1
        }
        
        fetchAndShowData()
        
    }
    
    fileprivate func calculateStepsizeFor(yRange ymax: Double, _ ymin: Double) -> Double {
        // Bleibt noch der Fall ymax=ymin, muss noch behandelt werden
        let ymarknumber = 50
        let ymark_diff_temp = (ymax - ymin) / Double( ymarknumber)
        var mag = log10( ymark_diff_temp)
        mag.round(.down)
        let magPow = pow( 10, mag)
        var magMsd = (ymark_diff_temp / magPow + 0.5).rounded()
        if( magMsd > 5.0)
        {
            magMsd = 10.0
        }
        else if( magMsd > 2.0)
        {
            magMsd = 5.0
        }
        else if( magMsd > 1.0)
        {
            magMsd = 2.0
        }
        let ymark_diff = magMsd*magPow
        return ymark_diff
    }
    


    fileprivate func fetchAndShowData() {
        
        
        DispatchQueue.main.async {
            
            let request = TableUtil.createRequestForChart(self.dict, self.serverUrl)
            let session = URLSession.shared
            let deviceId = self.dict["deviceId"] as! Int
            let measurementValue = self.dict["measurementValue"] as! String
            let measurementType = self.dict["measurementType"] as! String
            
            let fetchTask = session.dataTask(with: request) { data, response, error -> Void in
                
                if error == nil {
                
                do {
                    OnlineMeasurementBig.updateStateCounter = 0
                    if let measurementDataJson = data {
                        //                    print(String(data: measurementData,encoding: String.Encoding.utf8) as! String)
                        let json = try JSONSerialization.jsonObject(with: measurementDataJson) as! Dictionary<String, AnyObject>
                        print(json)
                        
                        self.arrData = []
                        
                        let valuesArrOpt = json["values"] as? [[String: Any]]
                        if let valuesArr = valuesArrOpt {
                        for value in valuesArr {
                            let avgOpt = value["avg"] as? Double
                            let startTimeOpt = value["startTime"] as? Double
                            if let avg = avgOpt, let startTime = startTimeOpt {
                                self.arrData.append((startTime, avg))
                            }
                        }
                        
                        self.showChart()
                        }
                        
                    } else {
                        print("data is invalid")
                    }
                } catch {
                    print("error")
                }
                } else {
                    print("Error: \(error)")
                }
                
            }
            
            
            fetchTask.resume()
            
            }
        
        
        
        
    }
}
