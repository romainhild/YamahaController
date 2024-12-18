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

struct ZoneStatus: Codable {
    var response_code: Int
    var power: String
    var volume: Int
    var mute: Bool
    var max_volume: Int
    var input: String
}

class Zone: Codable, ObservableObject {
    var id: String
    @Published var text: String
    @Published var devices: [String]
    var controlUrl: URL
    var zoneFeatures: ZoneFeature
    @Published var zoneStatus: ZoneStatus
    @Published var volume: Int = 0

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case devices
        case controlUrl
        case features
    }
    
    init?(features: ZoneFeature, device: String, controlUrl: URL) async {
        self.id = features.id
        self.devices = [device]
        self.controlUrl = controlUrl
        self.zoneFeatures = features
        self.zoneStatus = ZoneStatus(response_code: 0, power: "off", volume: 0, mute: false, max_volume: 100, input: "")
        
        self.text = ""
        if let text = await self.getName() {
            self.text = text
        } else {
            return nil
        }
        Task {
            await self.getStatus()
        }
    }
    
    init(id: String, text: String, device: Device, controlUrl: URL) {
        self.id = id
        self.text = text
        if let deviceId = device.deviceInfo?.device_id {
            self.devices = [deviceId]
        } else {
            self.devices = []
        }
        self.controlUrl = controlUrl
        self.zoneFeatures = ZoneFeature(id: id,
                                        func_list: [],
                                        input_list: [],
                                        sound_program_list: [],
                                        link_control_list: [],
                                        link_audio_delay_list: [],
                                        link_audio_quality_list: [],
                                        range_step: [])
        self.zoneStatus = ZoneStatus(response_code: 0, power: "off", volume: 0, mute: false, max_volume: 100, input: "")
        Task {
            await self.getStatus()
        }
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        text = try values.decode(String.self, forKey: .text)
        devices = try values.decode([String].self, forKey: .devices)
        controlUrl = try values.decode(URL.self, forKey: .controlUrl)
        zoneFeatures = try values.decode(ZoneFeature.self, forKey: .features)
        self.zoneStatus = ZoneStatus(response_code: 0, power: "off", volume: 0, mute: false, max_volume: 100, input: "")
        Task {
            await self.getStatus()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(devices, forKey: .devices)
        try container.encode(controlUrl, forKey: .controlUrl)
        try container.encode(zoneFeatures, forKey: .features)
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
    
    func getStatus() async {
        guard #available(macOS 12.0, *) else { return }
        if let url = URL(string: "\(self.id)/getStatus", relativeTo: self.controlUrl) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoder = JSONDecoder()
                self.zoneStatus = try decoder.decode(ZoneStatus.self, from: data)
                DispatchQueue.main.async {
                    self.volume = self.zoneStatus.volume
                }
                print(self.volume)
            } catch {
                print("error")
                return
            }
        }
    }
}
