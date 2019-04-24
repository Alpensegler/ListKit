examples:

```swift

class ExampleCell: UICollectionViewCell {
    var text = ""
}

class ExampleListAdapter: CollectionListAdapter {
    typealias Model = String
    
    func cellForItem<List: ListView>(for listContext: ListContext<List>, item: String) -> List.Cell {
        return listContext.dequeueReusableCell(withCellClass: ExampleCell.self) {
            $0.text = item
        }
    }
    
    func listModels<List: ListView>(for listView: List) -> [Model] {
        return ["aaa", "bbb", "ccc"]
    }
}

let collectionView = UICollectionView()
let adapter = ExampleListAdapter()
collectionView.listDelegate = adapter
adapter.update()

class ExampleMultipleSectionAdapter: CollectionListAdapter {
    typealias Model = String
    typealias Item = Character
    
    func cellForItem<List: ListView>(for listContext: ListContext<List>, item: Character) -> List.Cell {
        return listContext.dequeueReusableCell(withCellClass: ExampleCell.self) {
            $0.text = String(item)
        }
    }
    
    func listModels<List: ListView>(for listView: List) -> [Model] {
        return ["aaa", "bbb", "ccc"]
    }
}

class ExampleMultipleAdapterAdapter: CollectionListAdapter {
    typealias Model = ListViewConfigurable
    
    func listModels<List: ListView>(for listView: List) -> [Model] {
        return [ExampleListAdapter(), ExampleMultipleSectionAdapter()]
    }
}
```