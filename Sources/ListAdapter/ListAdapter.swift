//
//  ListAdapter.swift
//  ListKit
//
//  Created by Frain on 2019/12/5.
//

public protocol ListAdapter: DataSource { }

#if os(iOS) || os(tvOS)
import UIKit
public extension ListAdapter where Self: UpdatableDataSource {
    @discardableResult
    func onScrollViewDidScroll(_ closure: @escaping (UIScrollView) -> Void) -> Self {
        listCoordinator.scrollViewDidScroll = closure
        return self
    }
    
    @discardableResult
    func onScrollViewDidZoom(_ closure: @escaping (UIScrollView) -> Void) -> Self {
        listCoordinator.scrollViewDidZoom = closure
        return self
    }
    
    @discardableResult
    func onScrollViewWillBeginDragging(_ closure: @escaping (UIScrollView) -> Void) -> Self {
        listCoordinator.scrollViewWillBeginDragging = closure
        return self
    }
    
    @discardableResult
    func onScrollViewWillEndDragging(_ closure: @escaping (UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>) -> Void) -> Self {
        listCoordinator.scrollViewWillEndDragging = closure
        return self
    }
    
    @discardableResult
    func onScrollViewDidEndDragging(_ closure: @escaping (UIScrollView, Bool) -> Void) -> Self {
        listCoordinator.scrollViewDidEndDragging = closure
        return self
    }
    
    @discardableResult
    func onScrollViewWillBeginDecelerating(_ closure: @escaping (UIScrollView) -> Void) -> Self {
        listCoordinator.scrollViewWillBeginDecelerating = closure
        return self
    }
    
    @discardableResult
    func onScrollViewDidEndDecelerating(_ closure: @escaping (UIScrollView) -> Void) -> Self {
        listCoordinator.scrollViewDidEndDecelerating = closure
        return self
    }
    
    @discardableResult
    func onScrollViewDidEndScrollingAnimation(_ closure: @escaping (UIScrollView) -> Void) -> Self {
        listCoordinator.scrollViewDidEndScrollingAnimation = closure
        return self
    }
    
    @discardableResult
    func provideViewForZooming(_ closure: @escaping (UIScrollView) -> UIView?) -> Self {
        listCoordinator.viewForZooming = closure
        return self
    }
    
    @discardableResult
    func onScrollViewWillBeginZooming(_ closure: @escaping (UIScrollView, UIView?) -> Void) -> Self {
        listCoordinator.scrollViewWillBeginZooming = closure
        return self
    }
    
    @discardableResult
    func onScrollViewDidEndZooming(_ closure: @escaping (UIScrollView, UIView?, CGFloat) -> Void) -> Self {
        listCoordinator.scrollViewDidEndZooming = closure
        return self
    }
    
    @discardableResult
    func provideScrollViewShouldScrollToTop(_ closure: @escaping (UIScrollView) -> Bool) -> Self {
        listCoordinator.scrollViewShouldScrollToTop = closure
        return self
    }
    
    @discardableResult
    func onScrollViewDidScrollToTop(_ closure: @escaping (UIScrollView) -> Void) -> Self {
        listCoordinator.scrollViewDidScrollToTop = closure
        return self
    }
    
    @discardableResult
    func onScrollViewDidChangeAdjustedContentInset(_ closure: @escaping (UIScrollView) -> Void) -> Self {
        listCoordinator.scrollViewDidChangeAdjustedContentInset = closure
        return self
    }
}

#endif
