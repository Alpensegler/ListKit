//
//  DataSource+SourceCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

// swiftlint:disable comment_spacing

//import Foundation
//
//public extension DataSource
//where SourceBase.Source: DataSource, SourceBase.Source.Model == Model {
//    var listCoordinator: ListCoordinator<SourceBase> {
//        WrapperCoordinator(wrapper: sourceBase)
//    }
//}
//
//public extension DataSource
//where
//    SourceBase: UpdatableDataSource,
//    SourceBase.Source: DataSource,
//    SourceBase.Source.Model == Model
//{
//    var listCoordinator: ListCoordinator<SourceBase> {
//        sourceBase.coordinator(with: WrapperCoordinator(wrapper: sourceBase))
//    }
//}
//
//public extension UpdatableDataSource
//where
//    SourceBase.Source: DataSource,
//    SourceBase.Source.SourceBase == AnySources,
//    SourceBase.Model == Any,
//    Self: ListAdapter
//{
//    func modelContext(for listView: View, at index: IndexPath) -> [ListModelContext] {
//        _modelContext(for: listView, at: index)
//    }
//}
