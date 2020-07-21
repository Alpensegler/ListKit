//
//  RelatedCache.swift
//  ListKit
//
//  Created by Frain on 2020/6/9.
//

final class RelatedCache {
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
    
    func updateFrom(_ cache: RelatedCache) {
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
