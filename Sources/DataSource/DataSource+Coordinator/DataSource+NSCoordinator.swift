//
//  DataSource+NSCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

public extension NSDataSource where SourceBase: NSDataSource {
    var listCoordinator: ListCoordinator<SourceBase> {
        sourceBase.coordinator(with: NSCoordinator(sourceBase))
    }
}

extension NSDataSource {
    
}
