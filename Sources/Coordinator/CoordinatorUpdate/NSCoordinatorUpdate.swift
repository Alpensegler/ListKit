//
//  NSCoordinatorswift
//  ListKit
//
//  Created by Frain on 2020/6/10.
//

import Foundation

final class NSCoordinatorUpdate<SourceBase: NSDataSource>: ListCoordinatorUpdate<SourceBase>
where SourceBase.SourceBase == SourceBase {
    typealias SectionValue = (isReload: Bool, related: Int)
    typealias ItemValue = (isReload: Bool, related: IndexPath)
    
    var sectionInsertIndices = IndexSet()
    var sectionDeleteIndices = IndexSet()
    var itemInsertSectionIndices = IndexSet()
    var itemDeleteSectionIndices = IndexSet()
    var itemInsertIndices = [Int: IndexSet]()
    var itemDeleteIndices = [Int: IndexSet]()
    
    var sectionInsertDict = [Int: SectionValue]()
    var sectionDeleteDict = [Int: SectionValue]()
    var itemInsertDict = [IndexPath: ItemValue]()
    var itemDeleteDict = [IndexPath: ItemValue]()
    
    func insertSection(_ section: Int) {
        sectionInsertIndices.insert(section)
    }
    
    func insertSections(_ sections: IndexSet) {
        sectionInsertIndices.formUnion(sections)
    }
    
    func deleteSection(_ section: Int) {
        sectionDeleteIndices.insert(section)
    }
    
    func deleteSections(_ sections: IndexSet) {
        sectionDeleteIndices.formUnion(sections)
    }
    
    func reloadSection(_ section: Int) {
        sectionDeleteIndices.insert(section)
        sectionInsertIndices.insert(section)
        sectionDeleteDict[section] = (true, section)
        sectionInsertDict[section] = (true, section)
    }
    
    func reloadSections(_ sections: IndexSet) {
        sectionDeleteIndices.formUnion(sections)
        sectionInsertIndices.formUnion(sections)
        sections.forEach {
            sectionDeleteDict[$0] = (true, $0)
            sectionInsertDict[$0] = (true, $0)
        }
    }
    
    func moveSection(_ section: Int, to newSection: Int) {
        sectionDeleteIndices.insert(section)
        sectionInsertIndices.insert(newSection)
        sectionDeleteDict[section] = (false, newSection)
        sectionInsertDict[newSection] = (false, section)
    }
    
    func insertItem(at indexPath: IndexPath) {
        itemInsertSectionIndices.insert(indexPath.section)
        itemInsertIndices[default: indexPath.section].insert(indexPath.item)
    }
    
    func insertItems(at indexPaths: [IndexPath]) {
        indexPaths.forEach {
            itemInsertSectionIndices.insert($0.section)
            itemInsertIndices[default: $0.section].insert($0.item)
        }
    }
    
    func deleteItem(at indexPath: IndexPath) {
        itemDeleteSectionIndices.insert(indexPath.section)
        itemDeleteIndices[default: indexPath.section].insert(indexPath.item)
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        indexPaths.forEach {
            itemDeleteSectionIndices.insert($0.section)
            itemDeleteIndices[default: $0.section].insert($0.item)
        }
    }
    
    func reloadItem(at indexPath: IndexPath) {
        itemDeleteSectionIndices.insert(indexPath.section)
        itemInsertSectionIndices.insert(indexPath.section)
        itemDeleteIndices[default: indexPath.section].insert(indexPath.item)
        itemInsertIndices[default: indexPath.section].insert(indexPath.item)
        itemDeleteDict[indexPath] = (true, indexPath)
        itemInsertDict[indexPath] = (true, indexPath)
    }
    
    func reloadItems(at indexPaths: [IndexPath]) {
        indexPaths.forEach {
            itemDeleteSectionIndices.insert($0.section)
            itemInsertSectionIndices.insert($0.section)
            itemDeleteIndices[default: $0.section].insert($0.item)
            itemInsertIndices[default: $0.section].insert($0.item)
            itemDeleteDict[$0] = (true, $0)
            itemInsertDict[$0] = (true, $0)
        }
    }
    
    func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        itemDeleteSectionIndices.insert(indexPath.section)
        itemInsertSectionIndices.insert(newIndexPath.section)
        itemDeleteIndices[default: indexPath.section].insert(indexPath.item)
        itemInsertIndices[default: newIndexPath.section].insert(newIndexPath.item)
        itemDeleteDict[indexPath] = (false, newIndexPath)
        itemInsertDict[newIndexPath] = (false, indexPath)
    }
}

fileprivate extension Dictionary where Key == Int, Value == IndexSet {
    subscript(default key: Int) -> IndexSet {
        get { self[key] ?? .init() }
        set { self[key] = newValue }
    }
}
