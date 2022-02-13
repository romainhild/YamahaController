//
//  YamahaControllerApp.swift
//  YamahaController
//
//  Created by Romain Hild on 07/02/2022.
//

import SwiftUI

@main
struct YamahaControllerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        
        statusBarItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
        if let button = statusBarItem.button {
            button.image = NSImage(named:"yamaha")
            button.image?.isTemplate = true
            
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Start Sound Bar", action: #selector(startSoundBar(_:)), keyEquivalent: "s"))
            menu.addItem(NSMenuItem(title: "Stop Sound Bar", action: #selector(stopSoundBar(_:)), keyEquivalent: "d"))
//            menu.addItem(NSMenuItem(title: "Restart Sound Bar", action: #selector(restartSoundBar(_:)), keyEquivalent: "r"))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Quit YamahaCtrl", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
            statusBarItem.menu = menu
        }
    }
    
    @objc func startSoundBar(_ sender: AnyObject?) {
        let url = URL(string: "http://192.168.1.15/YamahaExtendedControl/v1/main/setPower?power=on")
        //let url = URL(string: "http://192.168.1.15/YamahaExtendedControl/v1/main/setPower?power=on")
        guard let requestUrl = url else { fatalError() }
        sendTask(url: requestUrl)
    }
    
    @objc func stopSoundBar(_ sender: AnyObject?) {
        let url = URL(string: "http://192.168.1.15/YamahaExtendedControl/v1/main/setPower?power=standby")
        //let url = URL(string: "http://192.168.1.15/YamahaExtendedControl/v1/main/setPower?power=on")
        guard let requestUrl = url else { fatalError() }
        sendTask(url: requestUrl)
    }
    
//    @objc func restartSoundBar(_ sender: AnyObject?) {
//        let url = URL(string: "http://192.168.1.15/YamahaExtendedControl/v1/main/setPower?power=on")
//        //let url = URL(string: "http://192.168.1.15/YamahaExtendedControl/v1/main/setPower?power=on")
//        guard let requestUrl = url else { fatalError() }
//        sendTask(url: requestUrl)
//    }
    
    func sendTask(url: URL) {
        let urlSession = URLSession(configuration: .ephemeral)
        let task = urlSession.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
        }
        task.resume()
    }
    
}
