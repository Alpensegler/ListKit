//
//  ModelCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

// swiftlint:disable comment_spacing

import Foundation

final class ModelCoordinator<Model>: ListCoordinator<Model> {
    var source: Model

    init(
        source: Model,
        options: ListOptions = .none
    ) {
        self.source = source
        super.init(options: options)
    }

    override func numbersOfSections() -> Int { 1 }
    override func numbersOfModel(in section: Int) -> Int { 1 }

    override func model(at indexPath: IndexPath) -> Model { source }
    override func configSourceType() -> SourceType { isSectioned ? .sectionModels : .models }

//    override func update(
//        from coordinator: ListCoordinator<Model>
//        updateWay: ListUpdateWay<Model>?
//    ) -> ListCoordinatorUpdate<SourceBase> {
//        let coordinator = coordinator as! ModelCoordinator<Model>
//        return ModelCoordinatorUpdate(
//            self,
//            update: ListUpdate(updateWay),
//            sources: (coordinator.source, source),
//            options: (coordinator.options, options)
//        )
//    }

//    override func update(
//        update: ListUpdate<SourceBase>,
//        options: ListOptions? = nil
//    ) -> ListCoordinatorUpdate<SourceBase> {
//        return ModelCoordinatorUpdate(
//            self,
//            update: update,
//            sources: (source, update.source ?? source),
//            options: (self.options, options ?? self.options)
//        )
//    }
}
