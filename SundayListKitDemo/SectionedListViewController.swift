//
//  SectionedListViewController.swift
//  SundayListKitDemo
//
//  Created by Frain on 2019/8/26.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit
import SundayListKit

enum Crew: String {
    case iOS
    case android
    case frontBackend
}

struct CrewSection: Identifiable {
    let listUpdater = ListUpdater()
    
    var id: Crew
    var allMembers: [String]
    
    init(crew: Crew, members: [String]) {
        self.id = crew
        self.allMembers = members
    }
}

extension CrewSection: TableListAdapter {
    typealias Item = String
    var source: [String] {
        var members = allMembers.shuffled()
        members.removeFirst(Int.random(in: 1...3))
        return members.shuffled()
    }
    
    func tableContext(_ context: TableListContext, cellForItem item: String) -> UITableViewCell {
        return context.dequeueReusableCell(withCellClass: UITableViewCell.self) {
            $0.textLabel?.text = item
        }
    }
    
    func tableContext(_ context: TableListContext, viewForHeaderInSection section: Int) -> UIView? {
        let button = UIButton(type: .system)
        button.frame.size.height = 30
        button.setTitle("refresh \(id.rawValue)", for: .normal)
        button.addAction { self.performUpdate() }
        return button
    }
    
    func tableContext(_ context: TableListContext, didSelectItem item: String) {
        deleteItem(at: context.item)
    }
}

class SectionedListViewControlle: UIViewController, TableListAdapter {
    @IBOutlet weak var tableView: UITableView! {
        didSet { setTableView(tableView) }
    }
    
    typealias Item = String
    var source: [CrewSection] {
        var source = CrewSection.allCases.shuffled()
        if Bool.random() { source.remove(at: 0) }
        return source
    }
    
    @IBAction func onRefresh(_ sender: UIBarButtonItem) {
        performUpdate()
    }
}

extension CrewSection: CaseIterable {
    static var iOS: CrewSection { return CrewSection(crew: .iOS, members: ["Roy", "Pinlin", "Zhiyi", "Frain", "Jack", "Cookie", "Kubrick", "Jeremy"]) }
    static var android: CrewSection { return CrewSection(crew: .android, members: ["July", "Raynor", "Tonny", "Dooze", "Charlie", "Venry"]) }
    static var frontBackend: CrewSection { return CrewSection(crew: .frontBackend, members: ["Roy", "Bernard", "Mai", "Melissa", "Kippa", "Jerry"]) }
    static var allCases: [CrewSection] {
        return [.iOS, .android, .frontBackend]
    }
}

extension UIButton {
    private func actionHandler(action: (() -> Void)? = nil) {
        struct Action { static var action: (() -> Void)? }
        if action != nil { Action.action = action }
        else { Action.action?() }
    }
    
    @objc private func triggerActionHandler() {
        self.actionHandler()
    }
    
    func on(_ control: UIControl.Event, action: @escaping () -> Void) {
        self.actionHandler(action: action)
        self.addTarget(self, action: #selector(triggerActionHandler), for: control)
    }
}

extension UIButton {
    //Target Action helper class
    class ClosureWrapper: NSObject {
        let closure: () -> Void
        
        init (_ closure: @escaping () -> Void) {
            self.closure = closure
        }
    }
    
    static var targetClosure = "targetClosure"
    
    var targetClosure: (() -> Void)? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &UIButton.targetClosure) as? ClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &UIButton.targetClosure, ClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addAction(_ closure: @escaping () -> Void) {
        targetClosure = closure
        addTarget(self, action: #selector(UIButton.closureAction), for: .touchUpInside)
    }
    
    @objc func closureAction() {
        targetClosure?()
    }
}

extension CrewSection: CustomStringConvertible {
    var description: String {
        return "\(id)"
    }
}
