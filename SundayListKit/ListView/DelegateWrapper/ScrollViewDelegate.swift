//
//  ScrollViewDelegate.swift
//  SundayListKit
//
//  Created by Frain on 2019/3/27.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit

class ScrollViewDelegateWrapper: NSObject, UIScrollViewDelegate {
    let scrollViewDidScrollBlock: (UIScrollView) -> Void
    let scrollViewDidZoomBlock: (UIScrollView) -> Void
    let scrollViewWillBeginDraggingBlock: (UIScrollView) -> Void
    let scrollViewWillEndDraggingBlock: (UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>) -> Void
    let scrollViewDidEndDraggingBlock: (UIScrollView, Bool) -> Void
    let scrollViewWillBeginDeceleratingBlock: (UIScrollView) -> Void
    let scrollViewDidEndDeceleratingBlock: (UIScrollView) -> Void
    let scrollViewDidEndScrollingAnimationBlock: (UIScrollView) -> Void
    let viewForZoomingBlock: (UIScrollView) -> UIView?
    let scrollViewWillBeginZoomingBlock: (UIScrollView, UIView?) -> Void
    let scrollViewDidEndZoomingBlock: (UIScrollView, UIView?, CGFloat) -> Void
    let scrollViewShouldScrollToTopBlock: (UIScrollView) -> Bool
    let scrollViewDidScrollToTopBlock: (UIScrollView) -> Void
    let scrollViewDidChangeAdjustedContentInsetBlock: (UIScrollView) -> Void
    
    init(_ delegate: ScrollViewDelegate) {
        scrollViewDidScrollBlock = { [unowned delegate] in delegate.scrollViewDidScroll($0) }
        scrollViewDidZoomBlock = { [unowned delegate] in delegate.scrollViewDidZoom($0) }
        scrollViewWillBeginDraggingBlock = { [unowned delegate] in delegate.scrollViewWillBeginDragging($0) }
        scrollViewWillEndDraggingBlock = { [unowned delegate] in delegate.scrollViewWillEndDragging($0, withVelocity: $1, targetContentOffset: $2) }
        scrollViewDidEndDraggingBlock = { [unowned delegate] in delegate.scrollViewDidEndDragging($0, willDecelerate: $1) }
        scrollViewWillBeginDeceleratingBlock = { [unowned delegate] in delegate.scrollViewWillBeginDecelerating($0) }
        scrollViewDidEndDeceleratingBlock = { [unowned delegate] in delegate.scrollViewDidEndDecelerating($0) }
        scrollViewDidEndScrollingAnimationBlock = { [unowned delegate] in delegate.scrollViewDidEndScrollingAnimation($0) }
        viewForZoomingBlock = { [unowned delegate] in delegate.viewForZooming(in: $0) }
        scrollViewWillBeginZoomingBlock = { [unowned delegate] in delegate.scrollViewWillBeginZooming($0, with: $1) }
        scrollViewDidEndZoomingBlock = { [unowned delegate] in delegate.scrollViewDidEndZooming($0, with: $1, atScale: $2) }
        scrollViewShouldScrollToTopBlock = { [unowned delegate] in delegate.scrollViewShouldScrollToTop($0) }
        scrollViewDidScrollToTopBlock = { [unowned delegate] in delegate.scrollViewDidScrollToTop($0) }
        scrollViewDidChangeAdjustedContentInsetBlock = { [unowned delegate] in delegate.scrollViewDidChangeAdjustedContentInset($0) }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScrollBlock(scrollView)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewDidZoomBlock(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewWillBeginDraggingBlock(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollViewWillEndDraggingBlock(scrollView, velocity, targetContentOffset)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDidEndDraggingBlock(scrollView, decelerate)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollViewWillBeginDeceleratingBlock(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndDeceleratingBlock(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimationBlock(scrollView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return viewForZoomingBlock(scrollView)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollViewWillBeginZoomingBlock(scrollView, view)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollViewDidEndZoomingBlock(scrollView, view, scale)
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return scrollViewShouldScrollToTopBlock(scrollView)
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollViewDidScrollToTopBlock(scrollView)
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        scrollViewDidChangeAdjustedContentInsetBlock(scrollView)
    }
}

public protocol ScrollViewDelegate: class {
    func scrollViewDidScroll(_ scrollView: UIScrollView) // any offset changes
    func scrollViewDidZoom(_ scrollView: UIScrollView) // any zoom scale changes
    
    // called on start of dragging (may require some time and or distance to move)
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    
    // called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    
    // called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) // called on finger up as we are moving
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) // called when scroll view grinds to a halt
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
    func viewForZooming(in scrollView: UIScrollView) -> UIView? // return a view that will be scaled. if delegate returns nil, nothing happens
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) // called before the scroll view begins zooming its content
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) // scale between minimum and maximum. called after any 'bounce' animations
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool // return a yes if you want to scroll to the top. if not defined, assumes YES
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) // called when scrolling animation finished. may be called immediately if already at top
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView)
    
    var asScrollViewDelegate: UIScrollViewDelegate { get }
}

private var scrollViewDelegateKey: Void?

public extension ScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) { }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) { }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) { }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) { }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) { }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) { }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { return nil }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) { }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) { }
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool { return true }
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) { }
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) { }
    
    var asScrollViewDelegate: UIScrollViewDelegate {
        return Associator.getValue(key: &scrollViewDelegateKey, from: self, initialValue: ScrollViewDelegateWrapper(self))
    }
}
