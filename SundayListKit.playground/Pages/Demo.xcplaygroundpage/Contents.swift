import SundayListKit
import PlaygroundSupport
import UIKit

let models = ["Roy", "Pinlin", "Zhiyi", "Frain", "Jack", "Cookie", "Kubrick", "Jeremy"]
func randomModels() -> [String] {
    var shuffledModels = models.shuffled()
    shuffledModels.removeFirst()
    shuffledModels.removeLast()
    return shuffledModels.shuffled()
}

class ViewController: UIViewController, TableListAdapter {
    override func viewDidLoad() {
        super.viewDidLoad()
        let tableView = UITableView(frame: view.bounds)
        view.addSubview(tableView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refresh)
        )
        
        tableView.coordinator = tableCoordinator()
    }
    
    @objc func refresh() {
        performUpdate()
    }
}

extension ViewController: TableListAdapter {
    typealias Item = String
    var source: [String] {
        return randomModels()
    }
    
    func tableContext(_ context: TableListContext, cellForItem item: String) -> UITableViewCell {
        return context.dequeueReusableCell(withCellClass: UITableViewCell.self) {
            $0.textLabel?.text = item
        }
    }
}


let viewController = ViewController()
let navigationController = UINavigationController(rootViewController: viewController)
navigationController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 600)
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = navigationController.view
