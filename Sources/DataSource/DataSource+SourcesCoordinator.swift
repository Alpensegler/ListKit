//
//  DataSource+SourcesCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

public extension DataSource
where
    SourceBase == Self,
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.SourceBase.Item == Item
{
    func makeListCoordinator() -> ListCoordinator { SourcesCoordinator(value: self) }
}

public extension UpdatableDataSource
where
    SourceBase == Self,
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.SourceBase.Item == Item
{
    func performUpdate(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        
    }
}

public extension DataSource
where
    SourceBase == Self,
    Source: RangeReplaceableCollection,
    Source.Element: DataSource,
    Source.Element.SourceBase.Item == Item,
    Item == Any
{
    func makeListCoordinator() -> ListCoordinator { AnySourcesCoordinator(value: self) }
}
