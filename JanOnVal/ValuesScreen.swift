//
//  ValuesScreen.swift
//  JanOnVal
//
//  Created by Andreas M on 29.07.22.
//  Copyright © 2022 Andreas Mueller. All rights reserved.
//

import SwiftUI

struct ValuesScreen: View {
    
    let configData: [Measurement]
    
    @ObservedObject var viewModel: MeasurementValueViewModel
    
    let layout = [
        GridItem(.adaptive(minimum: 150))
    ]
    
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns:layout, spacing: 15) {
                ForEach(viewModel.values) {value in
                    ZStack{
                        RadialGradient(gradient: Gradient(colors: [
                            Color(red: 143/255.0, green: 172/255.0, blue: 202/255.0, opacity:1.0),
                            Color(red: 69.0/255.0, green: 116.0/255.0, blue: 167/255.0, opacity:1.0)]),
                                       center: .top, startRadius: 0, endRadius: 200)
                        VStack(alignment: .center, spacing: 2) {
                            Text(value.icon)
                                .font(.largeTitle)
                            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 8) {
                                Text(value.getScaledValue().0).font(.system(.title2, design: .default)).bold().foregroundColor(.white)
                                Text(value.getScaledValue().1).font(.system(.title2, design: .default)).bold().foregroundColor(.white)
                            }
                            Text(value.getDateTimeFormatted()).font(.system(.caption2, design: .default)).foregroundColor(.white)
                        }
                    }
                    .frame(width: 150, height: 150, alignment: Alignment.center)
                    .cornerRadius(15)
                }
            }.padding(.vertical)
        }.onDisappear {
            viewModel.cancelTimer()
        }        
    }
}

struct ValuesScreen_Previews: PreviewProvider {
    static var previews: some View {
        ValuesScreen(configData: [], viewModel: MeasurementValueViewModel(serverUrl: "", refreshTime: 3, measurementData: [[:]]))
    }
}
