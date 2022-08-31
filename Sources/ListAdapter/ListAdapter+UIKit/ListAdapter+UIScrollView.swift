//
//  ScrollListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension ListAdapter where View: UIScrollView {
    var didScroll: Function<Void, Void, (ListContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidScroll), toClosure())
    }

    var didZoom: Function<Void, Void, (ListContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidZoom), toClosure())
    }

    var willBeginDragging: Function<Void, Void, (ListContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewWillBeginDragging), toClosure())
    }

    var willEndDragging: Function<(CGPoint, UnsafeMutablePointer<CGPoint>), Void, (ListContext, CGPoint, UnsafeMutablePointer<CGPoint>) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewWillEndDragging), toClosure())
    }

    var didEndDragging: Function<Bool, Void, (ListContext, Bool) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidEndDragging), toClosure())
    }

    var willBeginDecelerating: Function<Void, Void, (ListContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewWillBeginDecelerating), toClosure())
    }

    var didEndDecelerating: Function<Void, Void, (ListContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidEndDecelerating), toClosure())
    }

    var didEndScrollingAnimation: Function<Void, Void, (ListContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidEndScrollingAnimation), toClosure())
    }

    var viewForZooming: Function<Void, UIView?, (ListContext) -> UIView?> {
        toFunction(#selector(UIScrollViewDelegate.viewForZooming), toClosure())
    }

    var willBeginZooming: Function<UIView?, Void, (ListContext, UIView?) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewWillBeginZooming), toClosure())
    }

    var didEndZooming: Function<(UIView?, CGFloat), Void, (ListContext, UIView?, CGFloat) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidEndZooming), toClosure())
    }

    var shouldScrollToTop: Function<Void, Bool, (ListContext) -> Bool> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewShouldScrollToTop), toClosure())
    }

    var didScrollToTop: Function<Void, Void, (ListContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidScrollToTop), toClosure())
    }

    @available(iOS 11.0, *)
    var didChangeAdjustedContentInset: Function<Void, Void, (ListContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidChangeAdjustedContentInset), toClosure())
    }
}

#endif
