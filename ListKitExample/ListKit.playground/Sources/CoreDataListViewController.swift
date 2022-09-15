//
//  CoreDataListViewController.swift
//  ListKitExample
//
//  Created by Frain on 2020/8/20.
//

import CoreData
import ListKit
import UIKit

// swiftlint: disable unused_closure_parameter comment_spacing

//public class CoreDataListViewController: UIViewController, UpdatableListAdapter {
//    var fetchLimit = 3
//
//    public var toggle = true
//    lazy var todosList = configTodosList()
//    lazy var recent = configRecentList()
//    lazy var loadMore = configLoadMore()
//    lazy var tableView = _tableView
//
//    public typealias Model = Any
//    public var source: AnyTableSources {
//        AnyTableSources {
//            todosList
//                .tableConfig()
//                .headerTitleForSection { [unowned self] (context) -> String? in
//                    todosList.section(at: context.section).name == "0" ? "TODO" : "Done"
//                }
//            AnyTableSources(options: .removeEmptySection) {
//                recent
//                    .tableConfig()
//                if todosList.fetchedObjects.count > fetchLimit {
//                    loadMore
//                }
//            }
//            .headerTitleForSection("Recent")
//        }
//    }
//
//    func configTodosList() -> ListFetchedResultsController<ToDo> {
//        let fetchRequest = NSFetchRequest<ToDo>(entityName: ToDo.entityName)
//        fetchRequest.sortDescriptors = [
//            NSSortDescriptor(key: "done", ascending: true),
//            NSSortDescriptor(key: "priority", ascending: false),
//            NSSortDescriptor(key: "createAt", ascending: false),
//        ]
//        let controller = ListFetchedResultsController(
//            fetchRequest: fetchRequest,
//            managedObjectContext: Self.managedObjectContext,
//            sectionNameKeyPath: "done"
//        )
////        controller.shouldMoveItem = { [unowned tableView] (controller, todo, indexPath, _) in
////            controller.modelContext(for: tableView, at: indexPath).forEach {
////                $0.cell?.configUI(with: todo)
////            }
////            return true
////        }
//        try? controller.performFetch()
//        return controller
//    }
//
//    func configRecentList() -> ListFetchedResultsController<ToDo> {
//        let fetchRequest = NSFetchRequest<ToDo>(entityName: ToDo.entityName)
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createAt", ascending: false)]
//        fetchRequest.fetchLimit = 3
//        let controller = ListFetchedResultsController(
//            fetchRequest: fetchRequest,
//            managedObjectContext: Self.managedObjectContext
//        )
//        try? controller.performFetch()
//        return controller
//    }
//
//    func configLoadMore() -> ListAdaptation<ModelSources<String>, UITableView> {
//        Sources(model: "loadmore")
//            .cellForRow(UITableViewCell.self) { (cell, context, model) in
//                cell.textLabel?.text = model
//                cell.textLabel?.textAlignment = .center
//            }
//            .didSelectRow { [unowned self] (context, _) in
//                context.deselect(animated: true)
//                self.fetchLimit += 3
//                self.recent.fetchedResultController.fetchRequest.fetchLimit = self.fetchLimit
//                try? self.recent.performFetch()
//                self.recent.perform(.appendOrRemoveLast)
//                if self.recent.fetchedObjects.count <= self.fetchLimit {
////                    self.loadMore.perform(.remove)
//                }
//            }
//    }
//
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//
//        apply(by: tableView)
//
//        navigationItem.rightBarButtonItems = [
//            UIBarButtonItem(
//                barButtonSystemItem: .add,
//                target: self,
//                action: #selector(add)
//            ),
////            UIBarButtonItem(
////                barButtonSystemItem: .refresh,
////                target: self,
////                action: #selector(refresh)
////            )
//        ]
//    }
//}
//
//public class ToDo: NSManagedObject {
//    class var entityName: String { "ToDo" }
//
//    @NSManaged var title: String
//    @NSManaged var priority: Int16
//    @NSManaged var done: Bool
//    @NSManaged var createAt: Date
//
//    static func insert(title: String, priority: Int16) {
//        #if EXAMPLE
//        let toDo = ToDo(context: CoreDataListViewController.managedObjectContext)
//        toDo.title = title
//        toDo.priority = priority
//        toDo.createAt = .init()
//        #else
//        let toDo = NSEntityDescription.insertNewObject(
//            forEntityName: entityName,
//            into: CoreDataListViewController.managedObjectContext
//        )
//        toDo.setValue(title, forKey: "title")
//        toDo.setValue(priority, forKey: "priority")
//        toDo.setValue(Date(), forKey: "createAt")
//        #endif
//        CoreDataListViewController.saveContext()
//    }
//}
//
//#if EXAMPLE
//extension ToDo {
//    func toggle() {
//        done.toggle()
//        CoreDataListViewController.saveContext()
//    }
//
//    func delete() {
//        CoreDataListViewController.managedObjectContext.delete(self)
//        CoreDataListViewController.saveContext()
//    }
//}
//#else
//extension NSManagedObject {
//    func toggle() {
//        guard let done = value(forKey: "done") as? Bool else { return }
//        willChangeValue(forKey: "done")
//        setValue(!done, forKey: "done")
//        didChangeValue(forKey: "done")
//        CoreDataListViewController.saveContext()
//    }
//
//    func delete() {
//        CoreDataListViewController.managedObjectContext.delete(self)
//        CoreDataListViewController.saveContext()
//    }
//}
//#endif
//
//extension DataSource where Model == ToDo {
//    func tableConfig() -> ListAdaptation<AdapterBase, UITableView> {
//        cellForRow(UITableViewCell.self) { (cell, context, todo) in
//            cell.configUI(with: todo)
//        }
//        .didSelectRow { (context, todo) in
//            context.deselect(animated: true)
//            todo.toggle()
//        }
//        .canEditRow(true)
//        .commitEdittingStyleForRow { (context, style, todo) in
//            guard style == .delete else { return }
//            todo.delete()
//        }
//    }
//}
//
//extension UITableViewCell {
//    func configUI(with todo: ToDo) {
//        let isDone: Bool
//        textLabel?.text = todo.title
//        #if EXAMPLE
//        isDone = todo.done
//        #else
//        isDone = (todo.value(forKey: "done") as? Bool) == true
//        #endif
//        textLabel?.textColor = isDone ? UIColor.lightGray : UIColor.black
//        textLabel?.textAlignment = .natural
//    }
//}
//
//extension CoreDataListViewController {
//    static let persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "DataModel")
//        container.loadPersistentStores { description, error in
//            if let error = error { fatalError("Unable to load persistent stores: \(error)") }
//        }
//        return container
//    }()
//
//    static var managedObjectContext: NSManagedObjectContext {
//        persistentContainer.viewContext
//    }
//
//    static func saveContext () {
//        guard managedObjectContext.hasChanges else { return }
//        try? managedObjectContext.save()
//    }
//
//    var _tableView: UITableView {
//        let tableView = UITableView(frame: view.bounds)
//        tableView.allowsMultipleSelectionDuringEditing = true
//        view.addSubview(tableView)
//        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        return tableView
//    }
//
//    @objc func add() {
//        let alert = UIAlertController(title: "Add ToDo", message: nil, preferredStyle: .alert)
//        alert.addTextField { (textField) in
//            textField.text = "Title"
//            textField.selectAll(nil)
//        }
//
//        alert.addTextField { (textField) in
//            textField.placeholder = "priority"
//            textField.keyboardType = .numberPad
//        }
//
//        alert.addAction(UIAlertAction(title: "cancel", style: .cancel))
//
//        let ok = UIAlertAction(title: "Done", style: .default) { [unowned alert] _ in
//            guard let title = alert.textFields?.first?.text, !title.isEmpty else { return }
//            let priority = (alert.textFields?.last?.text).flatMap(Int16.init) ?? 0
//            ToDo.insert(title: title, priority: priority)
//        }
//
//        alert.addAction(ok)
//        present(alert, animated: true)
//        alert.textFields?.first?.selectAll(nil)
//    }
//}
//
//#if canImport(SwiftUI) && EXAMPLE
//
//import SwiftUI
//
//@available(iOS 13.0, *)
//struct CoreDataList_Preview: UIViewControllerRepresentable, PreviewProvider {
//    static var previews: some View { CoreDataList_Preview() }
//
//    func makeUIViewController(context: Self.Context) -> UINavigationController {
//        UINavigationController(rootViewController: CoreDataListViewController())
//    }
//
//    func updateUIViewController(_ uiViewController: UINavigationController, context: Self.Context) { }
//}
//
//#endif

//extension CoreDataListViewController {
//    struct ItemSource: UpdatableTableListAdapter {
//        var coordinatorStorage = CoordinatorStorage<ItemSource>()
//
//        typealias Item = Any
//
//        var value = true
//
//        var listOptions: ListOptions { .preferSection }
//
//        var source: AnyTableSources {
//            AnyTableSources {
//                if value {
//                    Sources(model: 1.0).tableViewCellForRow()
//                }
//            }
//        }
//    }
//
//    static var itemSource = ItemSource()
//
//    public typealias Item = Any
//    public var source: AnyTableSources {
//        AnyTableSources {
//            Self.itemSource
//            if toggle {
//                Sources(model: 0)
//                    .tableViewCellForRow()
//            }
//            todosList
//                .tableConfig()
//                .tableViewHeaderTitleForSection { [unowned self] (context) -> String? in
//                    self.todosList.sectionInfo[context.section].name == "0" ? "Todo" : "Done"
//                }
//        }
//    }
//
//    @objc func refresh() {
//        Self.itemSource.value.toggle()
//        Self.itemSource.performUpdate()
//    }
//}
//
//extension CoreDataListViewController {
//    static var source = [TableList<ListFetchedResultsController<ToDo>>]()
//
//    public typealias Item = ToDo
//    public var source: [TableList<ListFetchedResultsController<ToDo>>] { Self.source }
//    public var listOptions: ListOptions { .preferSection }
//
//    @objc func refresh() {
//        let list = todosList.tableConfig()
//        perform(.append(list))
//    }
//}
