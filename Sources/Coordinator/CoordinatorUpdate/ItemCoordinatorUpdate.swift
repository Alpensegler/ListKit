//
//  ItemCoordinatorUpdate.swift
//  ListKit
//
//  Created by Frain on 2020/8/3.
//

import Foundation

final class ItemCoordinatorUpdate<SourceBase: DataSource>: ListCoordinatorUpdate<SourceBase>
where SourceBase.Item == SourceBase.Source, SourceBase.SourceBase == SourceBase {
    
}
