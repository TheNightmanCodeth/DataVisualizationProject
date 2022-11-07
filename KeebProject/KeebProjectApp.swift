//
//  KeebProjectApp.swift
//  KeebProject
//
//  Created by Joe on 11/6/22.
//

import SwiftUI

@main
struct KeebProjectApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

extension String {
    func floatValue() -> Float {
        return (self as NSString).floatValue
    }
}

extension Array<Float> {
    func average() -> Float {
        var sum: Float = 0
        for item in self {
            sum += item
        }
        return sum / Float(self.count)
    }
}
