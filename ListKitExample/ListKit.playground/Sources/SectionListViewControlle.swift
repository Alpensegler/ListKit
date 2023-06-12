import ListKit
import UIKit

// swiftlint:disable comment_spacing

public class SectionListViewControlle: UIViewController, UpdatableCollectionListAdapter {
    static let emojis = (0x1F600...0x1F647).compactMap { UnicodeScalar($0) }

    public var models: [[UnicodeScalar]] {
        (0..<Int.random(in: 2...4)).map { _ in
            Array(Self.emojis.shuffled()[0..<Int.random(in: 20...30)])
        }
    }

    public var list: CollectionList {
        Sections(models)
            .cellForItem(CenterLabelCell.self) { (cell, _, model) in
                cell.text = "\(model)"
            }
            .layoutSizeForItem(CGSize(width: 30, height: 30))
            .layoutInsetForSection(UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10))
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

// UI
extension SectionListViewControlle {
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

    var collectionView: UICollectionView {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .white
        return collectionView
    }
}

#if canImport(SwiftUI) && EXAMPLE

import SwiftUI

@available(iOS 13.0, *)
struct SectionList_Preview: UIViewControllerRepresentable, PreviewProvider {
    static var previews: some View { SectionList_Preview() }

    func makeUIViewController(context: Self.Context) -> UINavigationController {
        UINavigationController(rootViewController: SectionListViewControlle())
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Self.Context) {

    }
}

#endif
