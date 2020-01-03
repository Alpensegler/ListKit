//
//  DataSource+NSCoordinator.swift
//  ListKit
//
//  Created by Frain on 2019/12/17.
//

public extension NSDataSource where SourceBase: NSDataSource {
    func makeListCoordinator() -> ListCoordinator<SourceBase> {
        NSCoordinator(sourceBase, storage: coordinatorStorage)
    }
}
