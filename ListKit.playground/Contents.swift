import UIKit
import ListKit
import CoreData

class FakeDBItem: NSObject, NSFetchRequestResult { }
let tableView = UITableView()
let fakeFetchedResultController = NSFetchedResultsController<FakeDBItem>()

//一行写一个 DataSource
let sources1 = Sources(items: 0..<10).provideTableViewCell().apply(by: tableView)

//也可以多加点行为，多个 section 也是支持的
let source2 = Sources(sections: [0..<10, 1..<11])
    .provideTableViewCell()
    .onTableViewDidSelectItem { (context, item) in print(item) }
    .onScrollViewDidZoom { scrollView in }
    .apply(by: tableView)

//封装进一个 custom model
class CustomModel: TableListAdapter {
    typealias Item = Int
    var source: [Int] { [2, 3, 4] }
    
    var tableList: TableList<CustomModel> {
        provideTableViewCell()
    }
}

CustomModel().apply(by: tableView)

//Core Data 的时候
class CustomCoreDataModel: TableListAdapter {
    typealias Item = FakeDBItem
    var source = FetchedResultsController(fakeFetchedResultController)
        .provideTableViewCell()
}

//结构复杂的情况
struct CustomComplexModel: TableListAdapter {
    typealias Item = Any
    var source: AnyItemTableList {
        .init {
            AnyItemTableList {
                Sources(item: "a").provideTableViewCell()
                sources1
                    .onTableViewDidSelectItem { (context, item) in print(item) }
            }.onTableViewWillDisplayRow { (context, cell, item) in }
            source2
            CustomModel()
                .onTableViewWillDisplayRow { (context, cell, item) in }
            CustomCoreDataModel()
        }
    }
}



