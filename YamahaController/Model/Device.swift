//
//  Device.swift
//  YamahaController
//
//  Created by Romain Hild on 09/08/2022.
//

import Foundation
import SwiftUI

struct DeviceInfo: Hashable, Codable {
    var model_name: String
    var destination: String
    var device_id: String
    var system_version: Float
    var api_version: Float
    var netmodule_version: String
}

struct DeviceFeatures: Hashable, Codable {
    var zone: [ZoneFeature]
}

struct ZoneFeature: Hashable, Codable {
    var id: String
    var func_list: [String]
    var input_list: [String]
    var sound_program_list: [String]
    var link_control_list: [String]
    var link_audio_delay_list: [String]
    var link_audio_quality_list: [String]
    var range_step: [RangeStep]
}

struct RangeStep: Hashable, Codable {
    var id: String
    var min: Int
    var max: Int
    var step: Int
}

class Device: Hashable, Codable {
    var name: String
    var address: URL
    var controlURL: URL
    var model: String
    var imagePath: URL?
    var image: Image?
    var deviceInfo: DeviceInfo?
    var deviceFeatures: DeviceFeatures?
    
    enum CodingKeys: String, CodingKey {
        case name
        case address
        case controlURL
        case model
        case imagePath
        case deviceInfo
    }
    
    init(name: String, address: URL, controlURL: URL, model: String, image: Image) {
        self.name = name
        self.address = address
        self.controlURL = controlURL
        self.model = model
        self.image = image
    }
    
    init?(url: URL) async {
        guard #available(macOS 12.0, *) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let parser = XMLParser(data: data)
            let parserDelegate = YamahaControllerXMLParser()
            parser.delegate = parserDelegate
            parser.parse()
            guard parserDelegate.manufacturer == "Yamaha Corporation" else { return nil }
            guard let name = parserDelegate.name else { return nil }
            guard let address = parserDelegate.urlBase else { return nil }
            guard let controlPath = parserDelegate.controlPath else { return nil }
            guard let model = parserDelegate.model else { return nil }
            
            self.name = name
            self.address = address
            guard let controlURL = URL(string: controlPath, relativeTo: self.address) else { return nil }
            self.controlURL = controlURL
            self.model = model
            if let icon = parserDelegate.icons.sorted(by: {(lhs, rhs) in Icon.less(lhs: lhs, rhs: rhs)} ).first,
               let iconUrl = URL(string: icon.path, relativeTo: self.address) {
                let (tempUrl, _) = try await URLSession.shared.download(from: iconUrl)
                let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationUrl = documentsUrl.appendingPathComponent("\(UUID().uuidString)-\(icon.name)")
                try FileManager.default.copyItem(at: tempUrl, to: destinationUrl)
                if let nsImage = NSImage(contentsOf: destinationUrl) {
                    self.image = Image(nsImage: nsImage)
                    self.imagePath = destinationUrl
                }
            }
            await self.getDeviceInfo()
            
        } catch {
            print("error get device description")
            return nil
        }
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        address = try values.decode(URL.self, forKey: .address)
        controlURL = try values.decode(URL.self, forKey: .controlURL)
        model = try values.decode(String.self, forKey: .model)
        do {
            imagePath = try values.decode(URL?.self, forKey: .imagePath)
            if let imagePath = imagePath, let nsImage = NSImage(contentsOf: imagePath) {
                self.image = Image(nsImage: nsImage)
            }
        } catch {}
        do {
            deviceInfo = try values.decode(DeviceInfo?.self, forKey: .deviceInfo)
        } catch {
            Task {
                await self.getDeviceInfo()
            }
        }
    }
    
    func sendTask(path: String, parameters: [URLQueryItem], callback: @escaping (Data)-> Void) {
//        let urlSession = URLSession(configuration: .ephemeral)
//        guard var urlCtrl = URL(string: self.controlURL, relativeTo: self.address)?.absoluteURL else { return }
////        let zone = "main"
////        urlCtrl.appendPathComponent(zone)
//        urlCtrl.appendPathComponent(path)
//        var urlCmp = URLComponents(url: urlCtrl, resolvingAgainstBaseURL: false)
//        if !parameters.isEmpty {
//            urlCmp?.queryItems = parameters
//        }
//        if let url = urlCmp?.url {
////            print(url)
//            let task = urlSession.dataTask(with: url) {(data, response, error) in
//                guard let data = data else { return }
//                //print(String(data: data, encoding: .utf8)!)
//                callback(data)
//            }
//            task.resume()
//        }
    }
    
    func getDeviceInfo() async {
        guard #available(macOS 12.0, *) else { return }
        if let url = URL(string: "system/getDeviceInfo", relativeTo: self.controlURL) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoder = JSONDecoder()
                self.deviceInfo = try decoder.decode(DeviceInfo.self, from: data)
            } catch {
                print("error getting device info")
                return
            }
        }
    }
    
    func getFeatures() async -> [ZoneFeature] {
        guard #available(macOS 12.0, *) else { return [] }
        if let url = URL(string: "system/getFeatures", relativeTo: self.controlURL) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoder = JSONDecoder()
                let deviceFeatures = try decoder.decode(DeviceFeatures.self, from: data)
                return deviceFeatures.zone
            } catch {
                print("error getting device features")
                return []
            }
        } else {
            return []
        }
    }
    
//    func getStatus() {
//        self.sendTask(path: "getStatus", parameters: [], callback: {_ in})
//    }
//    
//    func startDevice() {
//        let params = [URLQueryItem(name: "power", value: "on")]
//        self.sendTask(path: "setPower", parameters: params, callback: {_ in})
//    }
//    
    func stopDevice() {
//        let params = [URLQueryItem(name: "power", value: "standby")]
//        self.sendTask(path: "setPower", parameters: params, callback: {_ in})
    }
//    
//    func setVolume(_ vol: Int) {
//        let params = [URLQueryItem(name: "volume", value: String(vol))]
//        self.sendTask(path: "setVolume", parameters: params, callback: {_ in})
//    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encode(controlURL, forKey: .controlURL)
        try container.encode(model, forKey: .model)
        if let imagePath = self.imagePath {
            try container.encode(imagePath, forKey: .imagePath)
        }
        if let deviceInfo = deviceInfo {
            try container.encode(deviceInfo, forKey: .deviceInfo)
        }
    }

    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.address)
        hasher.combine(self.controlURL)
        hasher.combine(self.model)
        hasher.combine(self.deviceInfo)
    }
}
