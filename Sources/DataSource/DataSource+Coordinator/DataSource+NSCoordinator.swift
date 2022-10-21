//
//  DataSource+NSCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

// swiftlint:disable comment_spacing

//import Foundation
//
//public extension NSDataSource where SourceBase: NSDataSource {
//    var listCoordinator: ListCoordinator<SourceBase> {
//        sourceBase.coordinator(with: NSCoordinator(sourceBase))
//    }
//}
//
//public extension NSDataSource where SourceBase: NSDataSource, Self: ListAdapter {
//    func modelContext(
//        for listView: View,
//        at indexPath: IndexPath
//    ) -> [ListModelContext] {
//        _modelContext(for: listView, at: indexPath)
//    }
//
//    func modelContext(
//        for listView: View,
//        at index: Int
//    ) -> [ListModelContext] {
//        _modelContext(for: listView, at: .init(item: index))
//    }
//}
