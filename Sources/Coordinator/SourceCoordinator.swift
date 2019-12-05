//
//  SourceCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

class SourceCoordinator<SourceBase: DataSource>: ItemTypedWrappedCoordinator<SourceBase>
where SourceBase.Source: DataSource, SourceBase.Source.Item == SourceBase.Item {
    var coodinator: ListCoordinator<SourceBase.Source.SourceBase>
    var storedSource: SourceBase.Source
    override var source: SourceBase.Source { storedSource }
    override var wrappedCoodinator: BaseCoordinator { coodinator }
    override var wrappedItemTypedCoodinator: ItemTypedCoorinator<Item> { coodinator }
    
    override init(sourceBase: SourceBase) {
        storedSource = sourceBase.source
        coodinator = storedSource.makeListCoordinator()
        
        super.init(sourceBase: sourceBase)
    }
}
