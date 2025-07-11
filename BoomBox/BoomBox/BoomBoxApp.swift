//
//  BoomBoxApp.swift
//  BoomBox
//
//  Created by Dimitri SMITH on 11/07/2025.
//

import SwiftUI

@main
struct BoomBoxApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appModel)
        }
    }
}
