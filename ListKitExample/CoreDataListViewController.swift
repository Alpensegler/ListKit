//
//  CoreDataListViewController.swift
//  ListKitExample
//
//  Created by Frain on 2020/8/20.
//

import CoreData
import UIKit
import ListKit

public class CoreDataListViewController: UIViewController, UpdatableTableListAdapter {
    var fetchLimit = 3
    
    lazy var todosList = configTodosList()
    lazy var recent = configRecentList()
    lazy var loadMore = configLoadMore()
    
    public typealias Item = Any
    public var source: AnyTableSources {
        AnyTableSources {
            todosList
                .tableConfig()
                .tableViewHeaderTitleForSection { [unowned self] (context) -> String? in
                    self.todosList.sectionInfo[context.section].name == "0" ? "TODO" : "Done"
                }
            AnyTableSources {
                recent
                    .tableConfig()
                if todosList.fetchedObjects.count > fetchLimit {
                    loadMore
                }
            }
            .tableViewHeaderTitleForSection { (context) -> String? in
                "Recent"
            }
        }
    }
    
    func configTodosList() -> ListFetchedResultsController<ToDo> {
        let fetchRequest = NSFetchRequest<ToDo>(entityName: ToDo.entityName)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "done", ascending: true),
            NSSortDescriptor(key: "priority", ascending: false),
            NSSortDescriptor(key: "createAt", ascending: false),
        ]
        let controller = ListFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: Self.managedObjectContext,
            sectionNameKeyPath: "done"
        )
        try? controller.performFetch()
        return controller
    }
    
    func configRecentList() -> ListFetchedResultsController<ToDo> {
        let fetchRequest = NSFetchRequest<ToDo>(entityName: ToDo.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createAt", ascending: false)]
        fetchRequest.fetchLimit = 3
        let controller = ListFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: Self.managedObjectContext
        )
        try? controller.performFetch()
        return controller
    }
    
    func configLoadMore() -> AnyTableSources {
        AnyTableSources {
            Sources(item: "loadmore")
                .tableViewCellForRow(UITableViewCell.self) { (cell, context, _) in
                    cell.textLabel?.text = "loadmore"
                    cell.textLabel?.textAlignment = .center
                }
                .tableViewDidSelectRow { [unowned self] (context, _) in
                    context.deselectItem(animated: true)
                    self.fetchLimit += 3
                    self.recent.fetchedResultController.fetchRequest.fetchLimit = self.fetchLimit
                    try? self.recent.performFetch()
                    self.recent.perform(.appendOrRemoveLast)
                    if self.recent.fetchedObjects.count <= self.fetchLimit {
                        self.loadMore.perform(.remove)
                    }
                }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        apply(by: tableView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(add)
        )
    }
}

class ToDo: NSManagedObject {
    class var entityName: String { "ToDo" }
    
    @NSManaged var title: String
    @NSManaged var priority: Int16
    @NSManaged var done: Bool
    @NSManaged var createAt: Date
    
    static func insert(title: String, priority: Int16) {
        let toDo = ToDo(context: CoreDataListViewController.managedObjectContext)
        toDo.title = title
        toDo.priority = priority
        toDo.createAt = .init()
        CoreDataListViewController.saveContext()
    }
    
    func toggleDone() {
        done.toggle()
        CoreDataListViewController.saveContext()
    }
    
    func delete() {
        CoreDataListViewController.managedObjectContext.delete(self)
        CoreDataListViewController.saveContext()
    }
}

extension DataSource where Item == ToDo {
    func tableConfig() -> TableList<SourceBase> {
        tableViewCellForRow(UITableViewCell.self) { (cell, context, todo) in
            cell.configUI(with: todo)
        }
        .tableViewDidSelectRow { (context, todo) in
            context.deselectItem(animated: true)
            let cell = context.cell
            todo.toggleDone()
            cell?.configUI(with: todo)
        }
        .tableViewCanEditRow { (context, todo) -> Bool in
            true
        }
        .tableViewCommitEdittingStyleForRow { (context, style, todo) in
            guard style == .delete else { return }
            todo.delete()
        }
    }
}

extension UITableViewCell {
    func configUI(with todo: ToDo) {
        textLabel?.text = todo.title
        textLabel?.textColor = todo.done ? UIColor.lightGray : UIColor.black
        textLabel?.textAlignment = .natural
    }
}

extension CoreDataListViewController {
    static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { description, error in
            if let error = error { fatalError("Unable to load persistent stores: \(error)") }
        }
        return container
    }()
    
    static var managedObjectContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    static func saveContext () {
        guard managedObjectContext.hasChanges else { return }
        try? managedObjectContext.save()
    }
    
    var tableView: UITableView {
        let tableView = UITableView(frame: view.bounds)
        tableView.allowsMultipleSelectionDuringEditing = true
        view.addSubview(tableView)
        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return tableView
    }
    
    @objc func add() {
        let alert = UIAlertController(title: "Add ToDo", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "Title"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "priority"
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel))
        
        let ok = UIAlertAction(title: "Done", style: .default) { [unowned alert] _ in
            guard let title = alert.textFields?.first?.text, !title.isEmpty else { return }
            let priority = (alert.textFields?.last?.text).flatMap(Int16.init) ?? 0
            ToDo.insert(title: title, priority: priority)
        }
        
        alert.addAction(ok)
        present(alert, animated: true)
        alert.textFields?.first?.selectAll(nil)
    }
}
