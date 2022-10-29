//
//  ZoneView.swift
//  YamahaController
//
//  Created by Romain Hild on 23/10/2022.
//

import SwiftUI

struct ZoneView: View {
    var zone: Zone
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ZoneView_Previews: PreviewProvider {
    static var previews: some View {
        let device = Device(name: "Salon",
                            address: URL(string: "192.168.1.48")!,
                            controlURL: URL(string: "192.168.1.48/YamahaExtendedControl/v1/")!,
                            model: "",
                            image: Image(systemName: "star"))
        ZoneView(zone: Zone(id: "main", text: "Salon", device: device, controlUrl: device.controlURL))
    }
}
