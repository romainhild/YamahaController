//
//  SwiftUIView.swift
//  YamahaController
//
//  Created by Romain Hild on 29/08/2022.
//

import SwiftUI

struct DeviceRow: View {
    var device: Device
    
    var body: some View {
        HStack {
            if let image = device.image {
                image
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(5)
            }
            Text(device.name)
                .bold()
        }
    }
}

struct DeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        DeviceRow(device: Device(name: "Salon",
                                 address: URL(string: "192.168.1.48")!,
                                 controlURL: URL(string: "192.168.1.48/YamahaExtendedControl/v1/")!,
                                 model: "",
                                 image: Image(systemName: "star")))
    }
}
