//
//  ContentView.swift
//  YamahaController
//
//  Created by Romain Hild on 07/02/2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var modelData: ModelData

    var body: some View {
        NavigationView {
            List {
                ForEach(Array(modelData.zones.values), id: \.id) { zone in
                    NavigationLink {
                        ZoneView(zone: zone)
                    } label: {
                        ZoneRow(zone: zone)
                    }
                }
            }
            .navigationTitle("Zones")
            
            if modelData.zones.isEmpty {
                Button("Find MusicCast devices") {
                    modelData.searchDevice()
                }
            } else {
                Text("Choose a zone")
            }
        }
        .frame(width: 500, height: 500)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}
