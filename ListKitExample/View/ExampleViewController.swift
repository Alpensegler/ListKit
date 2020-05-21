//
//  DemoViewController.swift
//  ListKitDemo
//
//  Created by Frain on 2019/12/18.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController {
    var toggle = true
    var action: (() -> Void)?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds)
        view.addSubview(tableView)
        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return tableView
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    func addRefreshAction(action: @escaping () -> Void) {
        self.action = action
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
    }
    
    @objc func refresh() {
        toggle.toggle()
        action?()
    }
}


#if canImport(SwiftUI) && DEBUG

import SwiftUI

struct ExampleView: UIViewControllerRepresentable {
    var viewController: ExampleViewController
    
    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: viewController)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) { }
}


#endif
