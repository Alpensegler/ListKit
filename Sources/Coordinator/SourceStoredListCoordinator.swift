//
//  SourceStoredListCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

class SourceStoredListCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase>
where SourceBase.SourceBase == SourceBase {
    var _source: SourceBase.Source
    override var source: SourceBase.Source { _source }
    
    override init(_ sourceBase: SourceBase, storage: CoordinatorStorage<SourceBase>? = nil) {
        _source = sourceBase.source(storage: storage)
        
        super.init(sourceBase, storage: storage)
    }
}

extension SourceStoredListCoordinator where SourceBase: UpdatableDataSource {
    convenience init(updatable sourceBase: SourceBase) {
        self.init(sourceBase, storage: sourceBase.coordinatorStorage)
    }
}
