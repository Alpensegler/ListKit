# ListKit

## 核心功能

- [x] 无须直接调用 `performBatchUpdates(_:, completion:)` 或 `reloadData()`
- [x] 更加现代的链式 Swift API
- [x] 支持基于 `Result Builder` 的声明式构建写法，支持 `Flow control`
- [x] 支持 `Property Wrapper` 形式的数据源
- [x] **自动**根据数据模型选择更新方式 (基于 `Diff`)，且可自定义
- [x] 一维列表支持任意 `Collection` 作为数据模型
- [x] 创建具有多个数据类型的列表
- [x] 支持不限于二维的复杂 `Diff`
- [x] 支持单一数据源绑定多个 List
- [x] 支持任何 `UICollectionViewLayout`
- [x] 支持 SwiftUI

## 例子

除了 Readme 以外，本项目有 iOS Project，Playground，SwiftUI Preview 几种例子形式，强烈建议下载后在 ListKitExample 中查看

``` swift
class EmojisViewModel: TableListAdapter {
    var data = "🥳🤭😇"
    var tableList: TableList {
        CollectionElements(data)
            .cellForRow(UITableViewCell.self) { cell, context, char in
                cell.textLabel?.text = "\(char)"
            }
    }
}
```

通过 adopt 协议 `TableListAdapter`，将 `String` 这个 `Collection` 传入 `CollectionElements.init(_ collection: some Collection)`，然后通过链式写法实现 `tableList` ，我们就以非常少量的代码实现了一个 `TableView` 的静态数据源
然后通过 `tableView.adapted(by: adapter)` 即可将数据绑定至 UI。
如需更新，可以通过如下方法更新，通过 Diff，只会在 tableView 底部新插入两个 Cell

``` swift
emojiViewModel.data += "🧐😚"
emojiViewModel.performUpdate()
```

二维数组也支持，这个例子中还支持了点击 Cell 时打印对应数据模型

``` swift
class NumbersViewModel: TableListAdapter {
    var data = [[1, 2, 3], [4, 5, 6]] {
        didSet {
            performUpdate()
        }
    }
    
    var tableList: TableList {
        SectionsElements(data)
            .cellForRow(UITableViewCell.self) { cell, context, element in
                cell.textLabel?.text = "\(element)"
            }
            .didSelectRow { context, element in
                print(element)
            }
    }
}
```

跨行 Diff 也同样支持，下例中通过更新会看到 3 对应的 cell 会移动到下一个 section

``` swift
roomViewModel.data = [[1, 2], [4, 5, 6, 3]]
```

## 安装

### Carthage

将下面一行添加进 Cartfile 即可：

```text
github "Alpensegler/ListKit"
```

### Swift Package Manager

在 Xcode 中，点击 "Files -> Swift Package Manager -> Add Package Dependency..."，在搜索栏中输入 "https://github.com/Alpensegler/ListKit"
