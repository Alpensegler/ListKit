//
//  ListView+NSCollectionView.swift
//  ListKit
//
//  Created by Frain on 2019/12/9.
//

#if os(macOS)
import AppKit

public typealias CollectionView = NSCollectionView

extension NSCollectionView: NSListView { }

#endif
