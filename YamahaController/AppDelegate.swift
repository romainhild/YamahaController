//
//  AppDelegate.swift
//  YamahaController
//
//  Created by Romain Hild on 05/08/2022.
//

import Foundation
import SwiftUI


class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    let volumeSlider = NSSlider()
    var statusBarItem: NSStatusItem!
    var volumeItem = NSMenuItem(title: "Set Volume", action: nil, keyEquivalent: "")

    func applicationDidFinishLaunching(_ notification: Notification) {
        
        statusBarItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
        if let button = statusBarItem.button {
            button.image = NSImage(named:"yamaha")
            button.image?.isTemplate = true
            
            let menu = NSMenu()
            menu.delegate = self
            
            menu.addItem(NSMenuItem(title: "Start Sound Bar", action: #selector(startSoundBar(_:)), keyEquivalent: "s"))
            menu.addItem(NSMenuItem(title: "Stop Sound Bar", action: #selector(stopSoundBar(_:)), keyEquivalent: "d"))
//            menu.addItem(NSMenuItem(title: "Restart Sound Bar", action: #selector(restartSoundBar(_:)), keyEquivalent: "r"))
            
            menu.addItem(self.volumeItem)
            self.volumeSlider.minValue = 0
            self.volumeSlider.maxValue = 100
            self.volumeSlider.action = #selector(setVolume(_:))
            let menuItem = NSMenuItem()
            let hs = NSStackView(views: [self.volumeSlider])
            hs.orientation = .horizontal
            hs.alignment = .centerY
            hs.edgeInsets = NSEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            menuItem.view = hs
            menu.addItem(menuItem)
            
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Quit YamahaCtrl", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

            statusBarItem.menu = menu
        }
    }
    
    @objc func startSoundBar(_ sender: AnyObject?) {
        let url = URL(string: "http://192.168.1.15/YamahaExtendedControl/v1/main/setPower?power=on")
        guard let requestUrl = url else { fatalError() }
        sendTask(url: requestUrl, callback: {_ in})
    }
    
    @objc func stopSoundBar(_ sender: AnyObject?) {
        let url = URL(string: "http://192.168.1.15/YamahaExtendedControl/v1/main/setPower?power=standby")
        guard let requestUrl = url else { fatalError() }
        sendTask(url: requestUrl, callback: {_ in})
    }
    
//    @objc func restartSoundBar(_ sender: AnyObject?) {
//        let url = URL(string: "http://192.168.1.15/YamahaExtendedControl/v1/main/setPower?power=on")
//        guard let requestUrl = url else { fatalError() }
//        sendTask(url: requestUrl)
//    }
    
    @objc func setVolume(_ sender: AnyObject?) {
        print("set volume \(self.volumeSlider.integerValue)")
        let vol = self.volumeSlider.integerValue
        let url = URL(string: "http://192.168.1.15/YamahaExtendedControl/v1/main/setVolume?volume=\(vol)")
        guard let requestUrl = url else { fatalError() }
        sendTask(url: requestUrl) { _ in
            DispatchQueue.main.async {
                self.volumeItem.title = "Set Volume \(vol)"
            }
        }
    }
    
    func sendTask(url: URL, callback: @escaping (Data)-> Void) {
        let urlSession = URLSession(configuration: .ephemeral)
        let task = urlSession.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            //print(String(data: data, encoding: .utf8)!)
            callback(data)
        }
        task.resume()
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        let url = URL(string: "http://192.168.1.15/YamahaExtendedControl/v1/main/getStatus")
        guard let requestUrl = url else { fatalError() }
        sendTask(url: requestUrl) { data in
            // print(String(data: data, encoding: .utf8)!)
            do {
                if let datas = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let vol = datas["volume"] {
                        DispatchQueue.main.async {
                            self.volumeSlider.integerValue = vol as! Int
                            self.volumeItem.title = "Set Volume \(vol)"
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
