//
//  ModelCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/10/10.
//

// swiftlint:disable opening_brace

import Foundation

final class ModelCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase>
where
    SourceBase.Model == SourceBase.Source,
    SourceBase.SourceBase == SourceBase
{
    override func numbersOfSections() -> Int { 1 }
    override func numbersOfModel(in section: Int) -> Int { 1 }

    override func model(at indexPath: IndexPath) -> Model { source }
    override func configSourceType() -> SourceType { isSectioned ? .sectionModels : .models }

    override func update(
        from coordinator: ListCoordinator<SourceBase>,
        updateWay: ListUpdateWay<Model>?
    ) -> ListCoordinatorUpdate<SourceBase> {
        let coordinator = coordinator as! ModelCoordinator<SourceBase>
        return ModelCoordinatorUpdate(
            self,
            update: ListUpdate(updateWay),
            sources: (coordinator.source, source),
            options: (coordinator.options, options)
        )
    }

    override func update(
        update: ListUpdate<SourceBase>,
        options: ListOptions? = nil
    ) -> ListCoordinatorUpdate<SourceBase> {
        return ModelCoordinatorUpdate(
            self,
            update: update,
            sources: (source, update.source ?? source),
            options: (self.options, options ?? self.options)
        )
    }
}
