//
//  ListViewData.swift
//  SundayListKit
//
//  Created by Frain on 2019/4/21.
//  Copyright © 2019 Frain. All rights reserved.
//

class ListData {
    var models = [Any]()
    var modelsModels = [ListData?]()
    var modelIndices = [[Int]]()
    var modelOffset = [IndexPath]()
    
    var isEmpty: Bool {
        return models.isEmpty
    }
    
    func model<Model>(at indexPath: IndexPath) -> Model {
        return models[modelIndices[indexPath]] as! Model
    }
    
    func subData(at indexPath: IndexPath) -> ListData? {
        let index = modelIndices[indexPath]
        return modelsModels[index]
    }
    
    func subOffset(at indexPath: IndexPath) -> IndexPath {
        let index = modelIndices[indexPath]
        return modelOffset[index]
    }
    
    init() { }
    
    init<List: ListView>(for listView: List, listViewSource: ListSource) {
        
    }
    
    init<Container: Collection, List: ListView>(for listView: List, container: Container) {
        var lastModelWasSection = false
        var __lastIndices: [Int] {
            get {
                return lastModelWasSection ? [] : modelIndices.last ?? []
            }
            set {
                if modelIndices.isEmpty || lastModelWasSection {
                    modelIndices.append(newValue)
                } else {
                    modelIndices[modelIndices.lastIndex] = newValue
                }
            }
        }
        var lastOffset: IndexPath? {
            if modelIndices.isEmpty { return nil }
            return IndexPath(item: modelIndices[modelIndices.lastIndex].lastIndex, section: modelIndices.lastIndex)
        }
        
//        for model in container {
//            models.append(model)
//            if let source = model as? ListViewSource, let subModels = source.dataSource(for: listView) {
//                let modelsModel = ListViewData(for: listView, container: subModels)
//                if source.containsSection {
//                    modelOffset.append(lastOffset.map { IndexPath(item: $0.item, section: $0.section + 1) } ?? IndexPath(item: 0, section: 0))
//                    for index in modelsModel.modelIndices {
//                        modelIndices.append(Array(repeating: models.lastIndex, count: index.count))
//                    }
//                } else {
//                    modelOffset.append(lastOffset.map { IndexPath(item: $0.item + 1, section: $0.section) } ?? IndexPath(item: 0, section: 0))
//                    __lastIndices.append(contentsOf: Array(repeating: models.lastIndex, count: modelsModel.modelIndices[0].count))
//                }
//                modelsModels.append(modelsModel)
//                lastModelWasSection = source.containsSection
//            } else {
//                modelsModels.append(nil)
//                __lastIndices.append(models.lastIndex)
//                modelOffset.append(lastOffset.map { IndexPath(item: $0.item + 1, section: $0.section) } ?? IndexPath(item: 0, section: 0))
//                lastModelWasSection = false
//            }
//        }
    }
}

private extension Array {
    var lastIndex: Int {
        return Swift.max(endIndex - 1, 0)
    }
}
