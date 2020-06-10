//
//  ItemRelatedCache.swift
//  ListKit
//
//  Created by Frain on 2020/6/9.
//

final class ItemRelatedCache {
    var nestedAdapterItemUpdateDidConfig = false
    var cacheForItemDidConfig = false
    
    lazy var nestedAdapterItemUpdate: [AnyHashable: (Bool, (Any) -> Void)] = {
        nestedAdapterItemUpdateDidConfig = true
        return .init()
    }()
    
    lazy var cacheForItem: [ObjectIdentifier: Any] = {
        cacheForItemDidConfig = true
        return .init()
    }()
    
    func updateFrom(_ cache: ItemRelatedCache) {
        if cache.nestedAdapterItemUpdateDidConfig {
            nestedAdapterItemUpdate = cache.nestedAdapterItemUpdate
            nestedAdapterItemUpdateDidConfig = true
        }
        if cache.cacheForItemDidConfig {
            cacheForItem = cache.cacheForItem
            cacheForItemDidConfig = true
        }
    }
}
