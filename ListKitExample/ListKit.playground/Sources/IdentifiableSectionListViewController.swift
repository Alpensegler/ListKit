// swiftlint:disable comment_spacing orphaned_doc_comment

import ListKit
import UIKit

public class Room {
    let name: String
    let people: [String]

    init(_ name: String, _ people: [String]) {
        self.name = name
        self.people = people
    }
}

extension Room: UpdatableCollectionListAdapter {
    public var list: CollectionList {
        Models(people.shuffled())
            .cellForItem(CenterLabelCell.self, identifier: "") { (cell, context, model) in
                cell.text = model
            }
            .didSelectItem { [weak self] (context, model) in
                self?.performUpdate()
            }
            .layoutSizeForItem(CGSize(width: 70, height: 70))
            .layoutInsetForSection(UIEdgeInsets(top: 10, left: 10, bottom: 30, right: 10))
            .layoutMinimumLineSpacingForSection(50)
            .layoutMinimumInteritemSpacingForSection(5)
            .layoutReferenceSizeForHeaderInSection(CGSize(width: UIScreen.main.bounds.width, height: 30))
            .supplementaryViewForItem { [name] in
                let header = $0.dequeueReusableSupplementaryView(type: $1, TitleHeader.self)
                header.text = name
                return header
            }
    }
}

public class IdentifiableSectionListViewController: UIViewController, UpdatableCollectionListAdapter {
    public var list: CollectionList {
        DataSources(Room.random)
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

    static var random: [Room] {
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
            results.append(.init(name, people.map { "\($0)" }))
        }

        let random = results.sorted { $0.people.count > $1.people.count }
        print(random)
        return random
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
