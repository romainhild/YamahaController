//
//  ZoneRow.swift
//  YamahaController
//
//  Created by Romain Hild on 23/10/2022.
//

import SwiftUI

struct ZoneRow: View {
    @EnvironmentObject var modelData: ModelData
    var zone: Zone

    var body: some View {
        VStack(alignment: .leading) {
            Text(zone.text).bold()
            Text(zone.devices.map {modelData.devices[$0]?.model ?? ""}.joined(separator: ", "))
                .font(.caption)
                .foregroundColor(.secondary)
            
        }
    }
}

struct ZoneRow_Previews: PreviewProvider {
    static var previews: some View {
        let device = Device(name: "Salon",
                            address: URL(string: "192.168.1.48")!,
                            controlURL: URL(string: "192.168.1.48/YamahaExtendedControl/v1/")!,
                            model: "",
                            image: Image(systemName: "star"))
        ZoneRow(zone: Zone(id: "main", text: "Salon", device: device, controlUrl: device.controlURL))
            .environmentObject(ModelData())
    }
}
