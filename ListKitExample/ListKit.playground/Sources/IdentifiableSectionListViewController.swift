import UIKit
import ListKit

public struct Room: UpdatableDataSource {
    public var coordinatorStorage = CoordinatorStorage<Room>()
    let name: String
    let people: [String]
}

extension Room: CollectionListAdapter {
    public typealias Item = String
    
    public var source: [String] { people.shuffled() }
    public var listDiffer: ListDiffer<Room> { .diff(id: \.name) }
    public var listOptions: ListOptions { .removeEmptySection }
    
    public var collectionList: CollectionList<Room> {
        collectionViewCellForItem(CenterLabelCell.self) { (cell, context, item) in
            cell.text = item
        }
        .collectionViewDidSelectItem { (context, item) in
            self.perform(.remove(at: context.item))
        }
        .collectionViewLayoutSizeForItem { (_, _, _) in
            CGSize(width: 70, height: 70)
        }
        .collectionViewLayoutInsetForSection { _, _ in
            UIEdgeInsets(top: 10, left: 10, bottom: 30, right: 10)
        }
        .collectionViewLayoutMinimumLineSpacingForSection { (_, _) in
            50
        }
        .collectionViewLayoutMinimumInteritemSpacingForSection { (_, _) in
            5
        }
        .collectionViewLayoutReferenceSizeForHeaderInSection { (_, _) in
            CGSize(width: UIScreen.main.bounds.width, height: 30)
        }
        .collectionViewSupplementaryViewForItem { [name] in
            let header = $0.dequeueReusableSupplementaryView(type: $1, TitleHeader.self)
            header.text = name
            return header
        }
    }
}

public class IdentifiableSectionListViewController: UIViewController, UpdatableCollectionListAdapter {
    public typealias Item = String
    
    public var source: [Room] {
        Room.random
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        apply(by: collectionView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refresh)
        )
    }
    
    @objc func refresh() {
        performUpdate()
    }
}

extension Room: CustomStringConvertible {
    static let members = [
        "Roy", "Pinlin", "Frain", "Jack", "Cookie", "Kubrick", "Jeremy",
        "July", "Raynor", "Tonny", "Dooze", "Charlie", "Venry",
        "Bernard", "Mai", "Melissa", "Kippa", "Jerry"
    ]
    
    static var toggle = false
    
    static var random: [Room] {
//        toggle.toggle()
//        if toggle {
//            return [Room("River View", ["Kubrick", "Jack"]), Room("Interview A", ["July", "Frain"]), Room("Interview B", ["Raynor"])]
//        } else {
//            return [Room("River View", ["Melissa", "Raynor", "Frain"]), Room("Interview B", ["Dooze", "Charlie"]), Room("Interview A", ["July"])]
//        }

        var shuffled = members.shuffled()
        var rooms = [
            ("Interview B", 2),
            ("Interview A", 2),
            ("River View", 4),
            ("Meeting", 6),
        ]
        var results = [Room]()

        while let (name, limit) = rooms.popLast() {
            let people = Bool.random() || Bool.random()
                ? (0...Int.random(in: 0..<limit)).compactMap { _ in shuffled.popLast() }
                : []
            results.append(.init(name, people))
        }

        return results.sorted { $0.people.count > $1.people.count }
    }
    
    
    init(_ name: String, _ people: [String]) {
        self.name = name
        self.people = people
    }
    init(_ name: String, _ people: [Int] = []) {
        self.name = name
        self.people = people.map { "\($0)" }
    }
    
    public var description: String { "Room(\"\(name)\", \(people))" }
}

// UI
extension IdentifiableSectionListViewController {
    var collectionView: UICollectionView {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .white
        return collectionView
    }
}

extension Room {
    final class CenterLabelCell: UICollectionViewCell {
        lazy private var label: UILabel = {
            let view = UILabel()
            view.backgroundColor = .clear
            view.textAlignment = .center
            view.textColor = .black
            view.font = .boldSystemFont(ofSize: 18)
            self.contentView.addSubview(view)
            return view
        }()
        
        var text: String? {
            get { return label.text }
            set { label.text = newValue }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            label.frame = contentView.bounds
        }
    }
    
    final class TitleHeader: UICollectionReusableView {
        lazy private var label: UILabel = {
            let view = UILabel(frame: bounds)
            view.backgroundColor = .clear
            view.textAlignment = .center
            view.textColor = .black
            view.font = .boldSystemFont(ofSize: 18)
            view.frame = bounds
            view.backgroundColor = .systemGray
            self.addSubview(view)
            return view
        }()
        
        lazy private var refreshButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Refresh", for: .normal)
            button.addTarget(self, action: #selector(refreshAction), for: .touchUpInside)
            button.isHidden = true
            button.sizeToFit()
            button.frame.origin.x = UIScreen.main.bounds.width - button.frame.size.width
            self.addSubview(button)
            return button
        }()
        
        var text: String? {
            get { return label.text }
            set { label.text = newValue }
        }
        
        var refresh: (() -> Void)? {
            didSet { refreshButton.isHidden = refresh == nil }
        }
        
        @objc func refreshAction() {
            refresh?()
        }
    }
}

#if canImport(SwiftUI) && EXAMPLE

import SwiftUI

@available(iOS 13.0, *)
struct IdentifiableSectionList_Preview: UIViewControllerRepresentable, PreviewProvider {
    static var previews: some View { IdentifiableSectionList_Preview() }
    
    func makeUIViewController(context: Self.Context) -> UINavigationController {
        UINavigationController(rootViewController: IdentifiableSectionListViewController())
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Self.Context) {
        
    }
}

#endif
