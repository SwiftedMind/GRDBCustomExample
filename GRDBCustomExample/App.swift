//
//  GRDBCustomExampleApp.swift
//  GRDBCustomExample
//
//  Created by Dennis Müller on 23.04.25.
//

import Database
import SwiftUI

@main
struct GRDBCustomExampleApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .task {
          do {
            try await performExample()
          } catch {
            print("Error: \(error)")
          }
        }
    }
  }
}
