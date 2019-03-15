//
//  ChartsInterfaceController.swift
//  JanOnVal WatchKit Extension
//
//  Created by Andreas Mueller on 23.11.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import WatchKit
import Foundation
import UIKit

class ChartsInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var image: WKInterfaceImage!
    
    @IBOutlet weak var maxLbl: WKInterfaceLabel!
    @IBOutlet weak var minLbl: WKInterfaceLabel!
    
    private var fetchTask: URLSessionDataTask?
    private var dict: [String: Any] = [:]
    private var serverUrl = ""
    
    private var namedTime = "NAMED_Today"
    private var namedTimeLbl = "Today"
    
    private var namedTimeOld = "NAMED_Yesterday"
    private var namedTimeOldLbl = "Yesterday"
    var arrOldData = [(1.0,2.0)]
    private var OldDataTime = 0.0
    
    let defaults = UserDefaults.standard
    
    var arrData = [(1.0,2.0)]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let tServerUrl_MeasurementDict = context as? (String,[String: Any]) {
            serverUrl = tServerUrl_MeasurementDict.0
            dict = tServerUrl_MeasurementDict.1
        }
    }
    
    override func willActivate() {
        super.willActivate()
        
        fetchAndShowData()
        resetView()
    }
    
    fileprivate func showChart() {
        
        let currentDevice = WKInterfaceDevice.current()
        let deviceWidth = currentDevice.screenBounds.width
        let deviceHeight = currentDevice.screenBounds.height
        
        //Bei dimensionslosen Größen schwieriger, da nicht klar ob Stundenwerte (h), wir machen trotzdem einfach als Stundenbasis
        
        let size = CGSize( width: deviceWidth, height: deviceHeight*0.75)
        //let size = CGSize( width: 160, height: 170)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        // Setup for the path appearance
        context!.setStrokeColor(UIColor.white.cgColor)
        context!.setLineWidth(2.0)
        
        // Draw lines
        //context!.beginPath ();
        
        let coordoffsetleft = 0.0
        let coordoffsetbottom = 0.0
        let coordoffsetright = 0.0
        let coordoffsettop = 0.0
        
        //Zum Testen von dem Fall, dass die Daten erst später am Tag anfangen
        //arrData = Array( arrData.dropFirst(15))
        
        let graphicheight = Double(size.height) - coordoffsetbottom - coordoffsettop
        let graphicwidth = Double(size.width) - coordoffsetleft - coordoffsetright
        
        let xminoffset = 0.0
        let xmaxoffset = 0.0
        let yminoffset = 0.0
        let ymaxoffset = (Double( arrData.map({ $0.1}).max() ?? 0) - Double( arrData.map({ $0.1}).min() ?? 0)) / graphicheight * 10 //0.0
        
        var unit = dict["unit"] as! String
        var unit2 = dict["unit2"] as! String
        
        var y_delta = false
        if( show_DerivativeChart() ) { //Ob bei kWh Ableitung verwendet werden soll
            let timeScale = Double( 60*60)
            for i in 0 ... (arrData.endIndex - 2){
                arrData[i].1 = ( arrData[i+1].1 - arrData[i].1) / ( arrData[i+1].0 - arrData[i].0) * timeScale
                arrData[i].0 = ( arrData[i+1].0 + arrData[i].0) / 2
                //print( ( arrData[i+1].1 - arrData[i].1) / ( arrData[i+1].0 - arrData[i].0) * timeScale)
            }
            arrData = Array(arrData.dropLast(1))
            if( unit.contains("Wh")){
                unit = unit.replacingOccurrences(of: "Wh", with: "W")
            }else{
                if( unit.isEmpty){
                    unit = "1/h"
                }else{
                    unit = unit + "/h"
                }
            }
            if (!unit2.isEmpty) {
                if( unit2.contains("Wh")){
                    unit2 = unit2.replacingOccurrences(of: "Wh", with: "W")
                }else{
                    if( unit2.isEmpty){
                        unit2 = "1/h"
                    }else{
                        unit2 = unit2 + "/h"
                    }
                }
            }
        }else{
            if unit.contains("Wh") || unit.isEmpty {
                let start_wert = arrData.first?.1
                
                arrData = arrData.map( { ($0.0, $0.1 - (start_wert ?? 0))})
                y_delta = true
            }
        }
        
        //TODO: Ableitung bei Yesterday-Daten
        
        let tageslaenge = Double(24*60*60)
        let timestamp_min = arrData.map({ $0.0}).min()!
        let hour = Calendar.current.component(.hour, from: Date(timeIntervalSince1970: timestamp_min))
        let minute = Calendar.current.component(.minute, from: Date(timeIntervalSince1970: timestamp_min))
        let second = Calendar.current.component(.second, from: Date(timeIntervalSince1970: timestamp_min))
        let data_start_time = hour*60*60 + minute*60 + second
        
        let day_start = timestamp_min - Double( data_start_time)
        
        let xmin = day_start - xminoffset
        //let xmax = max(Double(tageswertanzahl), arrData.map({ $0.0}).max()!)+xmaxoffset
        let xmax = max( xmin + tageslaenge, arrData.map({ $0.0}).max()!+xmaxoffset)
        var minValue: Double? = arrData.map({ $0.1}).min()
        var maxValue: Double? = arrData.map({ $0.1}).max()
        if( arrOldData.count > 5){
            minValue = min( minValue!, arrOldData.map({ $0.1}).min()!)
            maxValue = max( maxValue!, arrOldData.map({ $0.1}).max()!)
        }
        let ymin = minValue!-yminoffset
        var ymax = maxValue!+ymaxoffset
        if( ymax == ymin){
            ymax = ymax + 1 // ymax * 1.1 haette Vorteil fuer sehr grosse ymax, aber dann sowas wie ymax = 0, ymax = -5
        }
        
        let ystepsize = calculateStepsizeFor(yRange: ymax, ymin)
        
        let ytickmarkarr = Array(stride(from: ystepsize * (ymin/ystepsize).rounded(.down), through: ystepsize * (ymax/ystepsize).rounded(.up), by: ystepsize))
        let ytickmarkpixelposarr = ytickmarkarr.map { (ymax - $0 )/(ymax-ymin) * graphicheight + coordoffsettop }
        //        print(ytickmarkpixelposarr)
        let xminpixelpos = coordoffsetleft
        let xmaxpixelpos = graphicwidth - coordoffsetright
        let yminpixelpos = graphicheight - coordoffsetbottom
        let ymaxpixelpos = coordoffsettop
        
        let stundentickmarkarr = [ 6, 12, 18]
        let xtickmarkposarr = stundentickmarkarr.map( {xmin + tageslaenge * Double($0) / 24})
        //let xtickmarkposarr = [ xmin + tageslaenge / 4, xmin + tageslaenge / 2, xmin + 3 * tageslaenge / 4]
        let xtickmarkpixelposarr = xtickmarkposarr.map { ( ($0 - xmin)/(xmax-xmin) * graphicwidth + coordoffsetleft)}
        context!.setLineWidth(0.4)
        for i in  0 ... (xtickmarkpixelposarr.endIndex - 1){
            
            context?.move( to: CGPoint( x: xtickmarkpixelposarr[i], y: ymaxpixelpos))
            context?.addLine( to: CGPoint( x: xtickmarkpixelposarr[i], y: yminpixelpos))
            context?.strokePath()
            
        }
        context!.beginPath()
        
        
        for i in  1 ... (ytickmarkpixelposarr.endIndex-1){
            let ypixelpos = (ymax - ytickmarkarr[i] )/(ymax-ymin) * graphicheight
            if( (ypixelpos > ymaxpixelpos) && (ypixelpos < yminpixelpos)){
                context?.beginPath()
                context!.setStrokeColor(UIColor.gray.cgColor)
                if( i % 10 == 0){
                    //                    context!.setLineWidth(1.2)
                    //                    context!.setLineWidth(0.4)
                    //                    context!.setLineDash(phase: 2.0, lengths: [1.0])
                    if show_Values_On_Y_Axis() {
                        var plus_prefix = ""
                        if( y_delta && ytickmarkarr[i] > 0){
                            plus_prefix = "+"
                        }
                        let sig_decimal =  Int(ceil(log10( ystepsize))) + 1 // +1 wegen dem i % 10 -- nur jedes zehnte Mal
                        let yLabel = plus_prefix +  TableUtil.getCompactNumberAndSiriPrefix( ytickmarkarr[i], forceDecimals:  sig_decimal)
                        drawYLabelText(context: context, text: yLabel, leftX: 6, centreY: CGFloat(CFloat(ytickmarkpixelposarr[i])))
                    }
                    //                    context!.setStrokeColor(UIColor.white.cgColor)
                    
                }else if( i % 5 == 0){
                    //                    context!.setLineWidth(0.9)
                }else{
                    //                    context!.setLineWidth(0.5)
                }
                context?.move( to: CGPoint( x: xminpixelpos, y: ytickmarkpixelposarr[i]))
                //                context?.addLine( to: CGPoint( x: xmaxpixelpos, y: ytickmarkpixelposarr[i]))
                context?.strokePath()
                
            }
        }
        
        //Draw Yesterday-Data
        if(  arrOldData.count > 5){
            context!.beginPath()
            
            // Setup for the path appearance
            context!.setStrokeColor(UIColor.gray.cgColor)
            context!.setLineWidth(1.0)
            
            let xDiffToOld = 24*60*60*1.0
            
            let PixelPositionOldArr = arrOldData.map { ( ( ($0.0 + xDiffToOld) -  xmin)/(xmax-xmin) * graphicwidth + coordoffsetleft , (ymax - $0.1 )/(ymax-ymin) * graphicheight + coordoffsettop)}
            
            context?.move( to: CGPoint( x: PixelPositionOldArr[0].0, y: PixelPositionOldArr[0].1))
            for i in  1 ... (PixelPositionOldArr.endIndex-1){
                context?.addLine( to: CGPoint( x: PixelPositionOldArr[i].0, y: PixelPositionOldArr[i].1))
                
            }
            context!.strokePath()
        }


        context!.beginPath()
        
        // Setup for the path appearance
        context!.setStrokeColor(UIColor.white.cgColor)
        context!.setLineWidth(2.0)
        
        let PixelPositionArr = arrData.map { ( ($0.0 - xmin)/(xmax-xmin) * graphicwidth + coordoffsetleft , (ymax - $0.1 )/(ymax-ymin) * graphicheight + coordoffsettop)}
        
        context?.move( to: CGPoint( x: PixelPositionArr[0].0, y: PixelPositionArr[0].1))
        for i in  1 ... (PixelPositionArr.endIndex-1){
            context?.addLine( to: CGPoint( x: PixelPositionArr[i].0, y: PixelPositionArr[i].1))
            
        }
        
        context!.strokePath()
        
        context!.beginPath()
        context!.setLineWidth(1.0)
        context?.move( to: CGPoint( x: coordoffsetleft, y: coordoffsettop))
        context?.addLine( to: CGPoint( x: coordoffsetleft, y:coordoffsettop + graphicheight))
        context?.addLine( to: CGPoint( x: coordoffsetleft + graphicwidth, y: coordoffsettop + graphicheight))
        
        context!.strokePath();
        
        
        if show_6_12_18() {
            for i in  0 ... (stundentickmarkarr.endIndex-1){
                drawText(context: context, text: String(stundentickmarkarr[i]), centreX: CGFloat(xtickmarkpixelposarr[i]), centreY: 6)
            }
        }
        
        let cgimage = context!.makeImage();
        let uiimage = UIImage(cgImage: cgimage!)
        
        // End the graphics context
        UIGraphicsEndImageContext()
        
        // Show on WKInterfaceImage
        image.setImage(uiimage)
        
        
        var minValueFormated = ("", 0.0)
        var maxValueFormated = ("", 0.0)
        
        
        minValueFormated = TableUtil.getSiPrefix(minValue!)
        maxValueFormated = TableUtil.getSiPrefix(maxValue!)
        
        
        minLbl.setText("↓:\(String(format:"%.1f", minValueFormated.1)) \(minValueFormated.0)")
        maxLbl.setText("↑:\(String(format:"%.1f", maxValueFormated.1)) \(maxValueFormated.0)\("" == unit2 ? unit : unit2) ")
    }
    
    func drawText( context : CGContext?, text : String, centreX : CGFloat, centreY : CGFloat )
    {
        let attributes = [
            NSAttributedString.Key.font : UIFont.boldSystemFont( ofSize: 18 ),
            NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0, green: 0.4797353745, blue: 1, alpha: 1)
            ] as [NSAttributedString.Key : Any]
        
        let textSize = text.size( withAttributes: attributes )
        
        text.draw(
            in: CGRect( x: centreX - textSize.width / 2.0,
                        y: centreY - textSize.height / 2.0,
                        width: textSize.width,
                        height: textSize.height ),
            withAttributes : attributes )
    }
    
    func drawYLabelText( context : CGContext?, text : String, leftX : CGFloat, centreY : CGFloat )
    {
        let attributes = [
            NSAttributedString.Key.font : UIFont.systemFont( ofSize: 12 ),
            NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0, green: 0.4797353745, blue: 1, alpha: 1)
            ] as [NSAttributedString.Key : Any]
        
        let textSize = text.size( withAttributes: attributes )
        
        text.draw(
            in: CGRect( x: leftX,
                        y: centreY - textSize.height / 2.0,
                        width: textSize.width,
                        height: textSize.height ),
            withAttributes : attributes )
    }
    
    fileprivate func calculateStepsizeFor(yRange ymax: Double, _ ymin: Double) -> Double {
        // Bleibt noch der Fall ymax=ymin, muss noch behandelt werden
        if( ymin == ymax){
            //
            return 1.0
        }
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
        fetchAndCacheOldData()
        DispatchQueue.main.async {
            let request = TableUtil.createRequestForChart(self.dict, self.serverUrl, namedTime: self.namedTime)
            let session = URLSession.shared
            _ = self.dict["deviceId"] as! Int
            _ = self.dict["measurementValue"] as! String
            _ = self.dict["measurementType"] as! String
            
            let fetchTask = session.dataTask(with: request) { data, response, error -> Void in
                
                if error == nil {
                    do {
                        OnlineMeasurementBig.updateStateCounter = 0
                        if let measurementDataJson = data {
                            //                    print(String(data: measurementData,encoding: String.Encoding.utf8) as! String)
                            let json = try JSONSerialization.jsonObject(with: measurementDataJson) as! Dictionary<String, AnyObject>
                            //print(json)
                            
                            self.arrData = []
                            
                            let valuesArrOpt = json["values"] as? [[String: Any]]
                            if let valuesArr = valuesArrOpt {
                                for value in valuesArr {
                                    let avgOpt = value["avg"] as? Double
                                    let startTimeOpt = value["startTime"] as? UInt64
                                    if let avg = avgOpt, let startTime = startTimeOpt {
                                        self.arrData.append((Double(startTime / 1_000_000_000), avg))
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
    
    fileprivate func fetchAndCacheOldData() {
        //TODO: Caching funktioniert noch nicht, da in OldDataTime nicht nur das Datum, sondern auch die Uhrzeit steht
        if( ( self.OldDataTime  + 24*60*60 <= NSDate().timeIntervalSince1970) || (self.arrOldData.count < 5)){
            DispatchQueue.main.async {
                let request = TableUtil.createRequestForChart(self.dict, self.serverUrl, namedTime: self.namedTimeOld)
                let session = URLSession.shared
                _ = self.dict["deviceId"] as! Int
                _ = self.dict["measurementValue"] as! String
                _ = self.dict["measurementType"] as! String
                
                let fetchTask = session.dataTask(with: request) { data, response, error -> Void in
                    
                    if error == nil {
                        do {
                            OnlineMeasurementBig.updateStateCounter = 0
                            if let measurementDataJson = data {
                                //                    print(String(data: measurementData,encoding: String.Encoding.utf8) as! String)
                                let json = try JSONSerialization.jsonObject(with: measurementDataJson) as! Dictionary<String, AnyObject>
                                //print(json)
                                
                                self.arrOldData = []
                                
                                let valuesArrOpt = json["values"] as? [[String: Any]]
                                if let valuesArr = valuesArrOpt {
                                    for value in valuesArr {
                                        let avgOpt = value["avg"] as? Double
                                        let startTimeOpt = value["startTime"] as? UInt64
                                        if let avg = avgOpt, let startTime = startTimeOpt {
                                            self.arrOldData.append((Double(startTime / 1_000_000_000), avg))
                                        }
                                    }
                                    self.OldDataTime = NSDate().timeIntervalSince1970
                                    //self.showChart()
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
    
    override func willDisappear() {
        fetchTask?.cancel()
        print("chart's fetch task cancled!")
    }
    
    private func show_6_12_18() -> Bool {
        return defaults.bool(forKey: OptionsInterfaceController.SHOW_6_12_18)
    }
    
    private func show_Values_On_Y_Axis() -> Bool {
        return defaults.bool(forKey: OptionsInterfaceController.SHOW_Values_On_Y_Axis)
    }
    
    private func show_DerivativeChart() -> Bool {
        return defaults.bool(forKey: OptionsInterfaceController.SHOW_DERIVATIVE_CHART)
    }
    
    @IBAction func onTodayMenuItemClick() {
        namedTime = "NAMED_Today"
        namedTimeLbl = "Today"
        fetchAndShowData()
        resetView()
    }
    
    fileprivate func resetView() {
        image.setImage(nil)
        minLbl.setText("  \(namedTimeLbl)")
        maxLbl.setText("⏳ ")
    }
    
    @IBAction func onYesterdayMenuItemClick() {
        namedTime = "NAMED_Yesterday"
        namedTimeLbl = "Yesterday"
        fetchAndShowData()
        resetView()
    }
    
    @IBAction func onOptionsMenuItemClick() {
        pushController(withName: "OptionsView", context: nil)
    }
}
