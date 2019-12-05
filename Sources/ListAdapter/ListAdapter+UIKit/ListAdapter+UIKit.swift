//
//  ListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

#if os(iOS) || os(tvOS)
import UIKit
public extension ListAdapter where Self: UpdatableDataSource {
    @discardableResult
    func onScrollViewDidScroll(_ closure: @escaping (UIScrollView) -> Void) -> Self {
        set(\.scrollViewDelegates.didScroll) { closure($0.0) }
    }
    
    @discardableResult
    func onScrollViewDidZoom(_ closure: @escaping (UIScrollView) -> Void) -> Self {
        set(\.scrollViewDelegates.didZoom) { closure($0.0) }
    }
    
    @discardableResult
    func onScrollViewWillBeginDragging(_ closure: @escaping (UIScrollView) -> Void) -> Self {
        set(\.scrollViewDelegates.willBeginDragging) { closure($0.0) }
    }
    
    @discardableResult
    func onScrollViewWillEndDragging(_ closure: @escaping (UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>) -> Void) -> Self {
        set(\.scrollViewDelegates.willEndDragging) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    @discardableResult
    func onScrollViewDidEndDragging(_ closure: @escaping (UIScrollView, Bool) -> Void) -> Self {
        set(\.scrollViewDelegates.didEndDragging) { closure($0.0, $0.1) }
    }
    
    @discardableResult
    func onScrollViewWillBeginDecelerating(_ closure: @escaping (UIScrollView) -> Void) -> Self {
        set(\.scrollViewDelegates.willBeginDecelerating) { closure($0.0) }
    }
    
    @discardableResult
    func onScrollViewDidEndDecelerating(_ closure: @escaping (UIScrollView) -> Void) -> Self {
        set(\.scrollViewDelegates.didEndDecelerating) { closure($0.0) }
    }
    
    @discardableResult
    func onScrollViewDidEndScrollingAnimation(_ closure: @escaping (UIScrollView) -> Void) -> Self {
        set(\.scrollViewDelegates.didEndScrollingAnimation) { closure($0.0) }
    }
    
    @discardableResult
    func provideViewForZooming(_ closure: @escaping (UIScrollView) -> UIView?) -> Self {
        set(\.scrollViewDelegates.viewForZooming) { closure($0.0) }
    }
    
    @discardableResult
    func onScrollViewWillBeginZooming(_ closure: @escaping (UIScrollView, UIView?) -> Void) -> Self {
        set(\.scrollViewDelegates.willBeginZooming) { closure($0.0, $0.1) }
    }
    
    @discardableResult
    func onScrollViewDidEndZooming(_ closure: @escaping (UIScrollView, UIView?, CGFloat) -> Void) -> Self {
        set(\.scrollViewDelegates.didEndZooming) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    @discardableResult
    func provideScrollViewShouldScrollToTop(_ closure: @escaping (UIScrollView) -> Bool) -> Self {
        set(\.scrollViewDelegates.shouldScrollToTop) { closure($0.0) }
    }
    
    @discardableResult
    func onScrollViewDidScrollToTop(_ closure: @escaping (UIScrollView) -> Void) -> Self {
        set(\.scrollViewDelegates.didScrollToTop) { closure($0.0) }
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func onScrollViewDidChangeAdjustedContentInset(_ closure: @escaping (UIScrollView) -> Void) -> Self {
        set(\.scrollViewDelegates.didChangeAdjustedContentInset) { closure($0.0) }
    }
}

#endif
