//
//  ListDelegate+UIScrollView.swift
//  ListKit
//
//  Created by Frain on 2019/12/8.
//

#if os(iOS) || os(tvOS)
import UIKit

final class UIScrollListDelegate {
    typealias Delegate<Input, Output> = ListKit.Delegate<UIScrollView, Input, Output, Void>
    
    var didScroll = Delegate<Void, Void>(
        #selector(UIScrollViewDelegate.scrollViewDidScroll(_:))
    )
    
    var didZoom = Delegate<Void, Void>(
        #selector(UIScrollViewDelegate.scrollViewDidZoom(_:))
    )
    
    var willBeginDragging = Delegate<Void, Void>(
        #selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:))
    )
    
    var willEndDragging = Delegate<(CGPoint, UnsafeMutablePointer<CGPoint>), Void>(
        #selector(UIScrollViewDelegate.scrollViewWillEndDragging(_:withVelocity:targetContentOffset:))
    )
    
    var didEndDragging = Delegate<Bool, Void>(
        #selector(UIScrollViewDelegate.scrollViewDidEndDragging(_:willDecelerate:))
    )
    
    var willBeginDecelerating = Delegate<Void, Void>(
        #selector(UIScrollViewDelegate.scrollViewWillBeginDecelerating(_:))
    )
    
    var didEndDecelerating = Delegate<Void, Void>(
        #selector(UIScrollViewDelegate.scrollViewDidEndDecelerating(_:))
    )
    
    var didEndScrollingAnimation = Delegate<Void, Void>(
        #selector(UIScrollViewDelegate.scrollViewDidEndScrollingAnimation(_:))
    )
    
    var viewForZooming = Delegate<Void, UIView?>(
        #selector(UIScrollViewDelegate.viewForZooming(in:))
    )
    
    var willBeginZooming = Delegate<UIView?, Void>(
        #selector(UIScrollViewDelegate.scrollViewWillBeginZooming(_:with:))
    )
    
    var didEndZooming = Delegate<(UIView?, CGFloat), Void>(
        #selector(UIScrollViewDelegate.scrollViewDidEndZooming(_:with:atScale:))
    )
    
    var shouldScrollToTop = Delegate<Void, Bool>(
        #selector(UIScrollViewDelegate.scrollViewShouldScrollToTop(_:))
    )
    
    var didScrollToTop = Delegate<Void, Void>(
        #selector(UIScrollViewDelegate.scrollViewDidScrollToTop(_:))
    )
    
    private var anyDidChangeAdjustedContentInset: Any = {
        guard #available(iOS 11.0, *) else { return () }
        return Delegate<Void, Void>(
            #selector(UIScrollViewDelegate.scrollViewDidChangeAdjustedContentInset(_:))
        )
    }()

    @available(iOS 11.0, *)
    var didChangeAdjustedContentInset: Delegate<Void, Void> {
        get { anyDidChangeAdjustedContentInset as! Delegate<Void, Void> }
        set { anyDidChangeAdjustedContentInset = newValue }
    }
    
    func add(by selectorSets: inout SelectorSets) {
        selectorSets.add(didScroll)
        selectorSets.add(didZoom)
        selectorSets.add(willBeginDragging)
        selectorSets.add(willEndDragging)
        selectorSets.add(didEndDragging)
        selectorSets.add(willBeginDecelerating)
        selectorSets.add(didEndDecelerating)
        selectorSets.add(didEndScrollingAnimation)
        selectorSets.add(viewForZooming)
        selectorSets.add(willBeginZooming)
        selectorSets.add(didEndZooming)
        selectorSets.add(shouldScrollToTop)
        selectorSets.add(didScrollToTop)
        if #available(iOS 11.0, *) {
            selectorSets.add(didChangeAdjustedContentInset)
        }
    }
}

//MARK: - ScrollView Delegate
extension ListDelegate: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        apply(\.scrollListDelegate.didScroll, object: scrollView)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        apply(\.scrollListDelegate.didZoom, object: scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        apply(\.scrollListDelegate.willBeginDragging, object: scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        apply(\.scrollListDelegate.willEndDragging, object: scrollView, with: (velocity, targetContentOffset))
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        apply(\.scrollListDelegate.didEndDragging, object: scrollView, with: (decelerate))
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        apply(\.scrollListDelegate.willBeginDecelerating, object: scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        apply(\.scrollListDelegate.didEndDecelerating, object: scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        apply(\.scrollListDelegate.didEndScrollingAnimation, object: scrollView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        apply(\.scrollListDelegate.viewForZooming, object: scrollView)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        apply(\.scrollListDelegate.willBeginZooming, object: scrollView, with: (view))
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        apply(\.scrollListDelegate.didEndZooming, object: scrollView, with: (view, scale))
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        apply(\.scrollListDelegate.shouldScrollToTop, object: scrollView)
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        apply(\.scrollListDelegate.didScrollToTop, object: scrollView)
    }
    
    @available(iOS 11.0, *)
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        apply(\.scrollListDelegate.didChangeAdjustedContentInset, object: scrollView)
    }
}


#endif

