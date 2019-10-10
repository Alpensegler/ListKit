//
//  Source.swift
//  ListKit
//
//  Created by Frain on 2019/4/8.
//

protocol DataSource {
    associatedtype Item
    associatedtype Source = [Item]
    
    var source: Source { get }
    var updater: Updater<Source, Item> { get }
    
    func snapshot(for source: Source) -> Snapshot<Item>
    func eraseToSources() -> Sources<Source, Item>
}
