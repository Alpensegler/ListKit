//
//  DataSource+ModelCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

// swiftlint:disable comment_spacing

//public extension DataSource where SourceBase.Source == Model {
//    var listCoordinator: ListCoordinator<SourceBase> {
//        ModelCoordinator(sourceBase)
//    }
//}
//
//public extension DataSource where SourceBase.Source == Model, SourceBase: UpdatableDataSource {
//    var listCoordinator: ListCoordinator<SourceBase> {
//        sourceBase.coordinator(with: ModelCoordinator(sourceBase))
//    }
//}
//
//public extension UpdatableDataSource where SourceBase.Source == Model, Self: ListAdapter {
//    func modelContext(for listView: View) -> [ListModelContext] {
//        _modelContext(for: listView, at: .init(item: 0))
//    }
//}
