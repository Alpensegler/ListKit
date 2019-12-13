import UIKit
import ListKit
import PlaygroundSupport

let tableView = UITableView(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 500)))

let sources = Sources(sections: [[1, 2, 3], [2, 3, 4]])
    .provideTableViewCell()
    .onTableViewDidSelectItem { (context, item) in
        context.deselectItem(animated: false)
        print(item)
    }

struct CustomStruct: TableListAdapter {
    typealias Item = Int
    
    var source = sources
}

let structSource = CustomStruct().apply(by: tableView)

PlaygroundPage.current.liveView = tableView


