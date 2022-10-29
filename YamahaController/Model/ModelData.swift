//
//  ModelData.swift
//  YamahaController
//
//  Created by Romain Hild on 09/08/2022.
//

import Foundation
import SwiftUI

final class ModelData: ObservableObject {
    @Published
    var devices: [String: Device] {
        didSet {
            self.saveDevices()
        }
    }
    @Published
    var zones: [String: Zone] = [:]
    var devicesUrl: [URL] = []
    
    var broadcastConnection: UDPBroadcastConnection?

    init() {
        let decoder = JSONDecoder()
        if let encoded = UserDefaults.standard.object(forKey: "devices") as? Data {
            print("devices found")
            if let devices = try? decoder.decode([String: Device].self, from: encoded) {
                print("devices loaded")
                print(devices)
                self.devices = devices
            } else {
                print("not decoded")
                self.devices = [:]
            }
        } else {
            self.devices = [:]
        }
    }
    
    func searchDevice() {
        let message = """
                    M-SEARCH * HTTP/1.1\r
                    HOST: 239.255.255.250:1900\r
                    MAN: "ssdp:discover"\r
                    ST: urn:schemas-upnp-org:device:MediaRenderer:1\r
                    MX: 2\r

                    """.data(using: .utf8)

        do {
            broadcastConnection = try UDPBroadcastConnection(
                port: 1900,
                handler: { ipAddress, port, response in
                    let str = String(decoding: response, as: UTF8.self)
                    guard let url = self.getUrl(text: str) else { return }
                    if !self.devicesUrl.contains(url) {
                        self.devicesUrl.append(url)
                        Task {
                            await self.createDevice(url: url)
                        }
                    }
                },
                errorHandler: { (error) in
                    print(error)
                }
            )

            try broadcastConnection!.sendBroadcast(message!)
        } catch {
            print("error while broadcast")
        }
    }
    
    func getUrl(text: String) -> URL? {
        let pattern = #"Location: (http(s)?://.*)"#
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern)
        } catch {
            print("error with the regex")
            return nil
        }
        let nsrange = NSRange(text.startIndex..<text.endIndex, in: text)
        if let match = regex.firstMatch(in: text, range: nsrange) {
            guard match.numberOfRanges > 1 else { return nil }
            guard let range = Range(match.range(at: 1), in: text) else { return nil }
            let xmlAddress = String(text[range])
            guard let url = URL(string: xmlAddress) else { return nil }
            return url
        }
        else {
            return nil
        }
    }
    
    func createDevice(url: URL) async {
        if let device = await Device(url: url),
           let deviceInfo = device.deviceInfo,
           let deviceFeatures = device.deviceFeatures {
            DispatchQueue.main.async {
                self.devices[deviceInfo.device_id] = device
            }
            for zoneId in deviceFeatures.zone {
                if let zone = self.zones[zoneId.id] {
                    DispatchQueue.main.async {
                        zone.devices.append(device)
                    }
                } else {
                    if let zone = await Zone(id: zoneId.id, device: device) {
                        DispatchQueue.main.async {
                            self.zones[zone.id] = zone
                        }
                    }
                }
            }
        }
    }
    
    func saveDevices() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(devices) {
            UserDefaults.standard.set(encoded, forKey: "devices")
        }
    }
}