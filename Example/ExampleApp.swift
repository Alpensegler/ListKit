//
//  ExampleApp.swift
//  Example
//
//  Created by luofengyu on 2024/1/13.
//

import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            Contents()
        }
    }
}

#if canImport(UIKit)
import UIKit
#else
import AppKit
public typealias ViewControllerRepresentable = NSViewControllerRepresentable
#endif

struct Contents: ViewControllerRepresentable {
    func updateNSViewController(_ nsViewController: ContentsViewController, context: Context) {

    }
    
    func makeNSViewController(context: Context) -> ContentsViewController {
        .init()
    }
}
