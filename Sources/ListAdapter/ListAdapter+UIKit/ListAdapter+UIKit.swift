//
//  ListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

#if os(iOS) || os(tvOS)
import UIKit
public extension ScrollListAdapter {
    @discardableResult
    func onScrollViewDidScroll(_ closure: @escaping (UIScrollView) -> Void) -> ScrollList<SourceBase> {
        set(\.scrollViewDelegates.didScroll) { closure($0.0) }
    }
    
    @discardableResult
    func onScrollViewDidZoom(_ closure: @escaping (UIScrollView) -> Void) -> ScrollList<SourceBase> {
        set(\.scrollViewDelegates.didZoom) { closure($0.0) }
    }
    
    @discardableResult
    func onScrollViewWillBeginDragging(_ closure: @escaping (UIScrollView) -> Void) -> ScrollList<SourceBase> {
        set(\.scrollViewDelegates.willBeginDragging) { closure($0.0) }
    }
    
    @discardableResult
    func onScrollViewWillEndDragging(_ closure: @escaping (UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>) -> Void) -> ScrollList<SourceBase> {
        set(\.scrollViewDelegates.willEndDragging) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    @discardableResult
    func onScrollViewDidEndDragging(_ closure: @escaping (UIScrollView, Bool) -> Void) -> ScrollList<SourceBase> {
        set(\.scrollViewDelegates.didEndDragging) { closure($0.0, $0.1) }
    }
    
    @discardableResult
    func onScrollViewWillBeginDecelerating(_ closure: @escaping (UIScrollView) -> Void) -> ScrollList<SourceBase> {
        set(\.scrollViewDelegates.willBeginDecelerating) { closure($0.0) }
    }
    
    @discardableResult
    func onScrollViewDidEndDecelerating(_ closure: @escaping (UIScrollView) -> Void) -> ScrollList<SourceBase> {
        set(\.scrollViewDelegates.didEndDecelerating) { closure($0.0) }
    }
    
    @discardableResult
    func onScrollViewDidEndScrollingAnimation(_ closure: @escaping (UIScrollView) -> Void) -> ScrollList<SourceBase> {
        set(\.scrollViewDelegates.didEndScrollingAnimation) { closure($0.0) }
    }
    
    @discardableResult
    func provideViewForZooming(_ closure: @escaping (UIScrollView) -> UIView?) -> ScrollList<SourceBase> {
        set(\.scrollViewDelegates.viewForZooming) { closure($0.0) }
    }
    
    @discardableResult
    func onScrollViewWillBeginZooming(_ closure: @escaping (UIScrollView, UIView?) -> Void) -> ScrollList<SourceBase> {
        set(\.scrollViewDelegates.willBeginZooming) { closure($0.0, $0.1) }
    }
    
    @discardableResult
    func onScrollViewDidEndZooming(_ closure: @escaping (UIScrollView, UIView?, CGFloat) -> Void) -> ScrollList<SourceBase> {
        set(\.scrollViewDelegates.didEndZooming) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    @discardableResult
    func provideScrollViewShouldScrollToTop(_ closure: @escaping (UIScrollView) -> Bool) -> ScrollList<SourceBase> {
        set(\.scrollViewDelegates.shouldScrollToTop) { closure($0.0) }
    }
    
    @discardableResult
    func onScrollViewDidScrollToTop(_ closure: @escaping (UIScrollView) -> Void) -> ScrollList<SourceBase> {
        set(\.scrollViewDelegates.didScrollToTop) { closure($0.0) }
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func onScrollViewDidChangeAdjustedContentInset(_ closure: @escaping (UIScrollView) -> Void) -> ScrollList<SourceBase> {
        set(\.scrollViewDelegates.didChangeAdjustedContentInset) { closure($0.0) }
    }
}

#endif
