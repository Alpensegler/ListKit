//
//  EmptyCoordinator.swift
//  ListKit
//
//  Created by Frain on 2020/4/28.
//

final class EmptyCoordinator<SourceBase: DataSource>: ListCoordinator<SourceBase>
where SourceBase.SourceBase == SourceBase {
    override var isEmpty: Bool { true }
    
    init(sourceBase: SourceBase) {
        super.init(source: sourceBase.source, storage: nil)
    }
}
