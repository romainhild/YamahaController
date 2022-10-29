//
//  YamahaControllerApp.swift
//  YamahaController
//
//  Created by Romain Hild on 07/02/2022.
//

import SwiftUI
import Network

@main
struct YamahaControllerApp: App {
    @StateObject private var modelData = ModelData()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelData)
        }
        .commands {
            YamahaControllerCommands()
        }
        
        Settings {
            EmptyView()
        }
    }
}
