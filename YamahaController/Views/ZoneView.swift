//
//  ZoneView.swift
//  YamahaController
//
//  Created by Romain Hild on 23/10/2022.
//

import SwiftUI

struct ZoneView: View {
    @EnvironmentObject var modelData: ModelData
    var zoneId: String
    
    var body: some View {
        VStack {
            Text("power: \(modelData.zones[zoneId]!.zoneStatus.power)")
            Text("volume: \(modelData.zones[zoneId]!.volume)")
            Button("get status") {
//                Task {
//                    await modelData.zones[zoneId]!.getStatus()
//                }
                modelData.zones[zoneId]?.volume = 5
            }
        }
    }
}

struct ZoneView_Previews: PreviewProvider {
    static var previews: some View {
        let device = Device(name: "Salon",
                            address: URL(string: "192.168.1.48")!,
                            controlURL: URL(string: "192.168.1.48/YamahaExtendedControl/v1/")!,
                            model: "",
                            image: Image(systemName: "star"))
        let zone = Zone(id: "main", text: "Salon", device: device, controlUrl: device.controlURL)
        let modelData = ModelData()
        modelData.devices["test"] = device
        zone.devices = ["test"]
        modelData.zones[zone.id] = zone
        return ZoneView(zoneId: zone.id).environmentObject(modelData)
    }
}
