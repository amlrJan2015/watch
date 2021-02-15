//
//  MeasurementValueManager.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 16.10.20.
//  Copyright © 2020 Andreas Mueller. All rights reserved.
//

import Foundation

struct MeasurementValueManager {
    private static func getRequest(_ url : String) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!)
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    private static func getUrl(widget: JanitzaMeasurementValue?) -> String {
        let projectName = (widget?.projectName ?? "").addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        
        return "\(widget?.url ?? ""):\(widget?.port ?? "")/rest/1/projects/\(projectName!)/onlinevalues?value=\(widget?.deviceId ?? "");\(widget?.measurementValue ?? "");\(widget?.measurementType ?? "")"
    }
    
    static func fetchMeasurementValue(widget: JanitzaMeasurementValue?, complete: @escaping (MeasurementValue) -> Void) {
        URLSession.shared.dataTask(with: getRequest(getUrl(widget: widget))) { data, response, error in
            guard error == nil else {return}
            
            let response = try! JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
            
            if let measurementPowerValueDict = response {
                if let valueOpt = measurementPowerValueDict["value"] as? [String: Any] {
                    if let dValue = valueOpt["\(widget?.deviceId ?? "").\(widget?.measurementValue ?? "").\(widget?.measurementType ?? "")"] as? Double {
                        complete(MeasurementValue(date: Date(), value: dValue, unit: "W"))
                    } else {
                        complete(MeasurementValue(date: Date(), value: Double.nan, unit: ""))
                    }
                }
            }
        }.resume()
    }
}
