//
//  ExampleApp.swift
//  Example
//
//  Created by Frain on 2024/1/13.
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
public typealias ViewController = UIViewController
public typealias ViewControllerRepresentable = UIViewControllerRepresentable

struct Contents: ViewControllerRepresentable {
    func updateUIViewController(_ uiviewController: UINavigationController, context: Context) { }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        return UINavigationController(rootViewController: ContentsViewController())
    }
}
#else
import AppKit
public typealias ViewControllerRepresentable = NSViewControllerRepresentable

struct Contents: ViewControllerRepresentable {
    func updateNSViewController(_ nsViewController: ContentsViewController, context: Context) { }
    
    func makeNSViewController(context: Context) -> ContentsViewController {
        .init()
    }
}
#endif
