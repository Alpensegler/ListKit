//
//  ScrollListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension ListAdapter where View: UIScrollView {
    var scrollViewDidScroll: Function<Void, Void, (ListContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidScroll), toClosure())
    }

    var scrollViewDidZoom: Function<Void, Void, (ListContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidZoom), toClosure())
    }

    var scrollViewWillBeginDragging: Function<Void, Void, (ListContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewWillBeginDragging), toClosure())
    }

    var scrollViewWillEndDragging: Function<(CGPoint, UnsafeMutablePointer<CGPoint>), Void, (ListContext, CGPoint, UnsafeMutablePointer<CGPoint>) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewWillEndDragging), toClosure())
    }

    var scrollViewDidEndDragging: Function<Bool, Void, (ListContext, Bool) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidEndDragging), toClosure())
    }

    var scrollViewWillBeginDecelerating: Function<Void, Void, (ListContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewWillBeginDecelerating), toClosure())
    }

    var scrollViewDidEndDecelerating: Function<Void, Void, (ListContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidEndDecelerating), toClosure())
    }

    var scrollViewDidEndScrollingAnimation: Function<Void, Void, (ListContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidEndScrollingAnimation), toClosure())
    }

    var viewForZooming: Function<Void, UIView?, (ListContext) -> UIView?> {
        toFunction(#selector(UIScrollViewDelegate.viewForZooming), toClosure())
    }

    var scrollViewWillBeginZooming: Function<UIView?, Void, (ListContext, UIView?) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewWillBeginZooming), toClosure())
    }

    var scrollViewDidEndZooming: Function<(UIView?, CGFloat), Void, (ListContext, UIView?, CGFloat) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidEndZooming), toClosure())
    }

    var scrollViewShouldScrollToTop: Function<Void, Bool, (ListContext) -> Bool> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewShouldScrollToTop), toClosure())
    }

    var scrollViewDidScrollToTop: Function<Void, Void, (ListContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidScrollToTop), toClosure())
    }

    @available(iOS 11.0, *)
    var scrollViewDidChangeAdjustedContentInset: Function<Void, Void, (ListContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidChangeAdjustedContentInset), toClosure())
    }
}

#endif
