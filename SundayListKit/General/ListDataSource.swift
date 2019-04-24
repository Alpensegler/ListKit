//
//  ListModelSource.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/8.
//  Copyright © 2019 Frain. All rights reserved.
//

public protocol ListDataSource: ListSource {
    associatedtype Model
    associatedtype Item = Model
    
    func model<List: ListView>(for listContext: ListContext<List>) -> Model
    func item<List: ListView>(for listContext: ListContext<List>) -> Item
    func update(from oldModels: [Model], to models: [Model], in listUpdateContext: ListUpdateContext)
}

public protocol ListViewModel: ListDataSource {
    associatedtype Container: Collection = Array<Model>
    where Self.Container.Element == Model
    
    func listModels<List: ListView>(for listView: List) -> Container
}

public extension ListDataSource {
    func update(from oldModels: [Model], to models: [Model], in listUpdateContext: ListUpdateContext) {
        listUpdateContext.reloadCurrentContext()
    }
}

public extension ListDataSource where Item == Model {
    func item<List: ListView>(for listContext: ListContext<List>) -> Item {
        return model(for: listContext)
    }
}

public extension ListDataSource where Model: ListDataSource, Model.Item == Item {
    func item<List: ListView>(for listContext: ListContext<List>) -> Item {
        return model(for: listContext).item(for: listContext.sublistContext!)
    }
}

public extension ListViewModel {
    func dataSource<List: ListView>(for listView: List) -> AnyCollection<Any>? {
        return AnyCollection(listModels(for: listView).lazy.map { $0 as Any })
    }
    
    func model<List: ListView>(for listContext: ListContext<List>) -> Model {
        return listContext.model()
    }
    
    func numbersOfSections<List: ListView>(for listContext: ListContext<List>) -> Int {
        return listContext.listViewData.modelIndices.count
    }
    
    func numbersOfItems<List: ListView>(for listContext: ListContext<List>, in section: Int) -> Int {
        return listContext.listViewData.modelIndices[section].count
    }
}

public extension Collection where Self: ListViewModel {
    typealias Model = Element
    typealias Container = Self
    
    func listModels<List: ListView>(for listView: List) -> Self {
        return self
    }
}

extension Set: ListViewModel { }
extension Array: ListViewModel { }
extension String: ListViewModel { }
extension Dictionary: ListViewModel { }
extension AnyCollection: ListViewModel { }
extension LazySequence: ListSource where Base: Collection { }
extension LazySequence: ListDataSource where Base: Collection { }
extension LazySequence: ListViewModel where Base: Collection { }
