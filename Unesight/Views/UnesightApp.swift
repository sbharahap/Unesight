//
//  UnesightApp.swift
//  Unesight
//
//  Created by Satria Baladewa Harahap on 25/04/24.
//

import SwiftUI

@main
struct UnesightApp: App {
    var body: some Scene {
        WindowGroup {
            ImagePicker()
                .environment(\.locale, .init(identifier: "id")) // Set locale ke Bahasa Indonesia
        }
    }
}
