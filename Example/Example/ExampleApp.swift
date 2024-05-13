//
//  ExampleApp.swift
//  Example
//
//  Created by Maxim Aliev on 13.05.2024.
//

import SwiftUI
import Debugger

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Debugger.setup()
                }
        }
    }
}
