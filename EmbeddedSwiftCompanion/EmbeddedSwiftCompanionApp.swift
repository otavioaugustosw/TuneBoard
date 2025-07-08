//
//  EmbeddedSwiftCompanionApp.swift
//  EmbeddedSwiftCompanion
//
//  Created by Otávio Augusto on 17/06/25.
//

import SwiftUI

@main
struct EmbeddedSwiftCompanionApp: App {
    @State var bluetoothService = BluetoothService()
    @State var audioService = AudioService()
    var body: some Scene {
        WindowGroup {
            SetupView()
                .environment(bluetoothService)
                .environment(audioService)

        }
    }
}
