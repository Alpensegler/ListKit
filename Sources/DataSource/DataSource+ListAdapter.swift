//
//  DataSource+ListAdapter.swift
//  ListKit
//
//  Created by Frain on 2020/6/10.
//

// swiftlint:disable opening_brace

public extension DataSource where Self: ListAdapter {
    var listCoordinatorContext: ListCoordinatorContext<SourceBase> {
        ListCoordinatorContext(listCoordinator, listDelegate: list.listDelegate)
    }
}

// MARK: - DataSource + nested Adapter
public extension DataSource
where
    SourceBase.Source: ListAdapter,
    SourceBase.Source.SourceBase.Model == Model
{
    func listBySubsource() -> ListAdaptation<AdapterBase, SourceBase.Source.View> { .init(adapterBase) }
}

public extension ListAdapter
where
    SourceBase.Source: ListAdapter,
    SourceBase.Source.SourceBase.Model == Model
{
    var list: ListAdaptation<AdapterBase, SourceBase.Source.View> { listBySubsource() }
}

public extension DataSource
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: ListAdapter,
    SourceBase.Source.Element.SourceBase.Model == Model
{
    func listBySubsource() -> ListAdaptation<AdapterBase, SourceBase.Source.Element.View> { .init(adapterBase) }
}

public extension ListAdapter
where
    SourceBase.Source: RangeReplaceableCollection,
    SourceBase.Source.Element: ListAdapter,
    SourceBase.Source.Element.SourceBase.Model == Model
{
    var list: ListAdaptation<AdapterBase, SourceBase.Source.Element.View> { listBySubsource() }
}
