//
//  Zone.swift
//  YamahaController
//
//  Created by Romain Hild on 23/10/2022.
//

import Foundation

struct ZoneName: Codable {
    var id: String
    var text: String
}

class Zone {
    var id: String
    @Published var text: String
    @Published var devices: [Device]
    var controlUrl: URL

    init?(id: String, device: Device) async {
        self.id = id
        self.devices = [device]
        self.controlUrl = device.controlURL
        
        self.text = ""
        if let text = await self.getName() {
            self.text = text
        } else {
            return nil
        }
    }
    
    init(id: String, text: String, device: Device, controlUrl: URL) {
        self.id = id
        self.text = text
        self.devices = [device]
        self.controlUrl = controlUrl
    }
    
    func getName() async -> String? {
        guard #available(macOS 12.0, *) else { return nil }
        let url = URL(string: "system/getNameText", relativeTo: self.controlUrl)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [URLQueryItem(name: "id", value: self.id)]
        if let urlQuery = components?.url {
            do {
                let (data, _) = try await URLSession.shared.data(from: urlQuery)
                let decoder = JSONDecoder()
                let zoneName = try decoder.decode(ZoneName.self, from: data)
                return zoneName.text
            } catch {
                print("error")
                return nil
            }
        } else {
            return nil
        }
    }
}
