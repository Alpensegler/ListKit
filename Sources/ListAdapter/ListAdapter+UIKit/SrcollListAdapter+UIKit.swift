//
//  ScrollListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension ScrollListAdapter {
    @discardableResult
    func scrollViewDidScroll(_ closure: @escaping (ScrollContext<SourceBase>) -> Void) -> ScrollList<SourceBase> {
        scrollList.set(\.didScroll) { closure($0.0) }
    }
    
    @discardableResult
    func scrollViewDidZoom(_ closure: @escaping (ScrollContext<SourceBase>) -> Void) -> ScrollList<SourceBase> {
        scrollList.set(\.didZoom) { closure($0.0) }
    }
    
    @discardableResult
    func scrollViewWillBeginDragging(_ closure: @escaping (ScrollContext<SourceBase>) -> Void) -> ScrollList<SourceBase> {
        scrollList.set(\.willBeginDragging) { closure($0.0) }
    }
    
    @discardableResult
    func scrollViewWillEndDragging(_ closure: @escaping (ScrollContext<SourceBase>, CGPoint, UnsafeMutablePointer<CGPoint>) -> Void) -> ScrollList<SourceBase> {
        scrollList.set(\.willEndDragging) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    @discardableResult
    func scrollViewDidEndDragging(_ closure: @escaping (ScrollContext<SourceBase>, Bool) -> Void) -> ScrollList<SourceBase> {
        scrollList.set(\.didEndDragging) { closure($0.0, $0.1) }
    }
    
    @discardableResult
    func scrollViewWillBeginDecelerating(_ closure: @escaping (ScrollContext<SourceBase>) -> Void) -> ScrollList<SourceBase> {
        scrollList.set(\.willBeginDecelerating) { closure($0.0) }
    }
    
    @discardableResult
    func scrollViewDidEndDecelerating(_ closure: @escaping (ScrollContext<SourceBase>) -> Void) -> ScrollList<SourceBase> {
        scrollList.set(\.didEndDecelerating) { closure($0.0) }
    }
    
    @discardableResult
    func scrollViewDidEndScrollingAnimation(_ closure: @escaping (ScrollContext<SourceBase>) -> Void) -> ScrollList<SourceBase> {
        scrollList.set(\.didEndScrollingAnimation) { closure($0.0) }
    }
    
    @discardableResult
    func provideViewForZooming(_ closure: @escaping (ScrollContext<SourceBase>) -> UIView?) -> ScrollList<SourceBase> {
        scrollList.set(\.viewForZooming) { closure($0.0) }
    }
    
    @discardableResult
    func scrollViewWillBeginZooming(_ closure: @escaping (ScrollContext<SourceBase>, UIView?) -> Void) -> ScrollList<SourceBase> {
        scrollList.set(\.willBeginZooming) { closure($0.0, $0.1) }
    }
    
    @discardableResult
    func scrollViewDidEndZooming(_ closure: @escaping (ScrollContext<SourceBase>, UIView?, CGFloat) -> Void) -> ScrollList<SourceBase> {
        scrollList.set(\.didEndZooming) { closure($0.0, $0.1.0, $0.1.1) }
    }
    
    @discardableResult
    func provideScrollViewShouldScrollToTop(_ closure: @escaping (ScrollContext<SourceBase>) -> Bool) -> ScrollList<SourceBase> {
        scrollList.set(\.shouldScrollToTop) { closure($0.0) }
    }
    
    @discardableResult
    func scrollViewDidScrollToTop(_ closure: @escaping (ScrollContext<SourceBase>) -> Void) -> ScrollList<SourceBase> {
        scrollList.set(\.didScrollToTop) { closure($0.0) }
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func scrollViewDidChangeAdjustedContentInset(_ closure: @escaping (ScrollContext<SourceBase>) -> Void) -> ScrollList<SourceBase> {
        scrollList.set(\.didChangeAdjustedContentInset) { closure($0.0) }
    }
}

#endif
