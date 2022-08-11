//
//  ModelsCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/11/25.
//

// swiftlint:disable opening_brace

import Foundation

class ModelsCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: Collection,
    SourceBase.Model == SourceBase.Source.Element
{
    lazy var models = toModels(source)

    var updateType: ModelsCoordinatorUpdate<SourceBase>.Type {
        ModelsCoordinatorUpdate<SourceBase>.self
    }

    func toModels(_ source: SourceBase.Source) -> ContiguousArray<Model> {
        source.mapContiguous { $0 }
    }

    override func numbersOfModel(in section: Int) -> Int { models.count }
    override func numbersOfSections() -> Int { models.isEmpty && options.removeEmptySection ? 0 : 1 }

    override func model(at indexPath: IndexPath) -> Model { models[indexPath.item] }
    override func configSourceType() -> SourceType { isSectioned ? .sectionModels : .models }

    override func update(
        from coordinator: ListCoordinator<SourceBase>,
        updateWay: ListUpdateWay<Model>?
    ) -> ListCoordinatorUpdate<SourceBase> {
        let coordinator = coordinator as! ModelsCoordinator<SourceBase>
        return updateType.init(
            coordinator: self,
            update: ListUpdate(updateWay),
            values: (coordinator.models, models),
            sources: (coordinator.source, source),
            options: (coordinator.options, options)
        )
    }

    override func update(
        update: ListUpdate<SourceBase>,
        options: ListOptions? = nil
    ) -> ListCoordinatorUpdate<SourceBase> {
        updateType.init(
            coordinator: self,
            update: update,
            values: (models, update.source.map(toModels) ?? models),
            sources: (source, update.source ?? source),
            options: (self.options, options ?? self.options)
        )
    }
}

final class RangeReplacableModelsCoordinator<SourceBase: DataSource>: ModelsCoordinator<SourceBase>
where
    SourceBase.SourceBase == SourceBase,
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element == SourceBase.Model
{
    override var updateType: ModelsCoordinatorUpdate<SourceBase>.Type {
        RangeReplacableModelsCoordinatorUpdate<SourceBase>.self
    }
}
