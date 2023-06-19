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
- [x] 支持定义缓存，可用于高度 / 大小缓存
- [x] 支持单一数据源绑定多个 List
- [x] 支持任何 `UICollectionViewLayout`
- [x] 支持 SwiftUI
- [x] 支持 CoreData

## 例子

除了 Readme 以外，本项目有 iOS Project，Playground，SwiftUI Preview 几种例子形式，强烈建议下载后在 ListKitExample 中查看

``` swift
class EmojiViewModel: ListAdapter {
    typealias Model = Character
    var source = "🥳🤭😇"
    var tableList: ListAdaptation<AdapterBase, UITableView> {
        cellForRow(UITableViewCell.self) { cell, context, element in
            cell.textLabel?.text = "\(model)"
        }
    }
}
```

通过 adopt 协议 `ListAdapter`，将 `String` 这个 `Collection` 的 `Element` —— `Charater` 指定为 `Model`，然后通过链式写法实现 `tableList` ，我们就以非常少量的代码实现了一个 `TableView` 的静态数据源

然后通过 `emojiViewModel.apply(by: tableView)` 即可将数据绑定至 UI

如果需要更新，可以 adopt 协议 `UpdatableListAdapter`，无需再添加任何代码就可以通过如下方法更新，通过 Diff，只会在 tableView 底部新插入两个 Cell

``` swift
emojiViewModel.source += "🧐😚"
emojiViewModel.performUpdate()
```

二维数组也支持，这个例子中还支持了点击 Cell 时打印对应数据模型

``` swift
class RoomViewModel: UpdatableListAdapter {
    typealias Model = Int
    var source = [[1, 2, 3], [4, 5, 6]] {
        didSet {
            performUpdate()
        }
    }
    
    var tableList: ListAdaptation<AdapterBase, UITableView> {
        cellForRow(UITableViewCell.self) { cell, context, element in
            cell.textLabel?.text = "\(model)"
        }
        didSelectRow { context, element in
            print(model)
        }
    }
}
```

跨行 Diff 也同样支持，下例中通过更新会看到 3 对应的 cell 会移动到下一个 section

``` swift
roomViewModel.source = [[1, 2], [4, 5, 6, 3]]
```

## 安装

### Carthage

将下面一行添加进 Cartfile 即可：

```text
github "Alpensegler/ListKit"
```

### Swift Package Manager

在 Xcode 中，点击 "Files -> Swift Package Manager -> Add Package Dependency..."，在搜索栏中输入 "https://github.com/Alpensegler/ListKit"
