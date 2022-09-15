//
//  DataSource+SourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

// swiftlint:disable opening_brace

//import Foundation
//
//public extension DataSource
//where
//    SourceBase.Source: RangeReplaceableCollection,
//    SourceBase.Source.Element: DataSource,
//    SourceBase.Source.Element.SourceBase.Model == Model
//{
//    var listCoordinator: ListCoordinator<SourceBase> {
//        DataSourcesCoordinator(sources: sourceBase)
//    }
//}
//
//public extension DataSource
//where
//    SourceBase: UpdatableDataSource,
//    SourceBase.Source: RangeReplaceableCollection,
//    SourceBase.Source.Element: DataSource,
//    SourceBase.Source.Element.SourceBase.Model == Model
//{
//    var listCoordinator: ListCoordinator<SourceBase> {
//        sourceBase.coordinator(with: DataSourcesCoordinator(sources: sourceBase))
//    }
//}
//
//public extension UpdatableDataSource
//where
//    SourceBase: UpdatableDataSource,
//    SourceBase.Source: RangeReplaceableCollection,
//    SourceBase.Source.Element: DataSource,
//    SourceBase.Source.Element.SourceBase.Model == Model,
//    Self: ListAdapter
//{
//    func modelContext(for listView: View, at index: IndexPath) -> [ListModelContext] {
//        _modelContext(for: listView, at: index)
//    }
//}
