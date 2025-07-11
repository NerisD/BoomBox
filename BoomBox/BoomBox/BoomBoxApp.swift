//
//  BoomBoxApp.swift
//  BoomBox
//
//  Created by Dimitri SMITH on 11/07/2025.
//

import SwiftUI

@main
struct BoomBoxApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
