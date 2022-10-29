//
//  DeviceView.swift
//  YamahaController
//
//  Created by Romain Hild on 11/08/2022.
//

import SwiftUI

struct DeviceView: View {
    var device: Device

    var body: some View {
        Button("Stop \(device.name)", action: { device.stopDevice() })
    }
}

struct DeviceView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceView(device: Device(name: "Salon",
                                  address: URL(string: "192.168.1.48")!,
                                  controlURL: URL(string: "192.168.1.48/YamahaExtendedControl/v1/")!,
                                  model: "",
                                  image: Image(systemName: "star")))
    }
}
