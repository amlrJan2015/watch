//
//  AppModel.swift
//  JanOnVal
//
//  Created by Andreas Mueller on 26.01.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import Foundation

class AppModel {
    var serverUrl = ""
    var selectedDeviceArr = Array<Device>()
    var refreshTime = 2
    var data: [Measurement] = []
    
    func getMeasurementData() -> [[String:Any]] {
        var dictArr = [[String:Any]]()
        //var recordsToSave: [CKRecord] = []
        
        for (index, measurement) in data.enumerated() {
            
            /*let measurementValueRecord = CKRecord(recordType: "MeasurementValue", recordID: CKRecord.ID(recordName: "measurementValue\(index)"))
            measurementValueRecord["deviceId"] = measurement.device?.id
            measurementValueRecord["deviceName"] = measurement.device?.name
            measurementValueRecord["start"] = measurement.start
            measurementValueRecord["end"] = measurement.end
            measurementValueRecord["favorite"] = String(measurement.favorite)
            measurementValueRecord["index"] = index
            measurementValueRecord["isOnline"] = String(measurement.online)
            measurementValueRecord["measurementType"] = measurement.valueType?.type ?? ""
            measurementValueRecord["measurementTypeName"] = measurement.valueType?.typeName ?? ""
            measurementValueRecord["measurementValue"] = measurement.valueType?.value ?? ""
            measurementValueRecord["measurementValueName"] = measurement.valueType?.valueName ?? ""
            measurementValueRecord["mode"] = measurement.mode
            measurementValueRecord["timebase"] = String(measurement.timebase)
            measurementValueRecord["unit"] = measurement.valueType?.unit ?? ""
            measurementValueRecord["unit2"] = measurement.unit2
            measurementValueRecord["watchTitle"] = measurement.watchTitle*/
            
            
            //recordsToSave.append(measurementValueRecord)
            
            if index < SelectedMeasurementViewController.MAX_VALUES_COUNT {
                dictArr.append([
                    "watchTitle":measurement.watchTitle,
                    "isOnline": measurement.online,
                    "start": measurement.start,
                    "end": measurement.end,
                    "unit": "\(measurement.valueType?.unit ?? "")",
                    "unit2": "\(measurement.unit2)",
                    "deviceId" : measurement.device?.id,
                    "deviceName" : measurement.device?.name,
                    "mode": measurement.mode,
                    "timebase": String(measurement.timebase),
                    "measurementValue": measurement.valueType?.value ?? "",
                    "measurementValueName": measurement.valueType?.valueName ?? "",
                    "measurementType": measurement.valueType?.type ?? "",
                    "measurementTypeName": measurement.valueType?.typeName ?? "",
                    MeasurementPropertyKey.favorite: measurement.favorite
                ])
            }
        }
        
        /*database.fetch(withRecordID: CKRecord.ID(recordName: "config")) { recordOpt, error in
            if error != nil {
                print("Error:\(error)")
            }
            
            if let configRecord = recordOpt {
                recordsToSave.forEach { record in
                    record["config"] = CKRecord.Reference(record: configRecord, action: CKRecord.ReferenceAction.deleteSelf)
                }
                
                //TODO: save confgiMVs changes
                
                self.database.modifyRecords(saving: recordsToSave, deleting: [], savePolicy: CKModifyRecordsOperation.RecordSavePolicy.allKeys, atomically: true) { result in
                    switch result {
                    case .success(let successInfo):
                        print("Save measurements to Cloud SUCCESS[\(successInfo.saveResults.count)]")
                        break
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }*/
        
        return dictArr
    }
}
