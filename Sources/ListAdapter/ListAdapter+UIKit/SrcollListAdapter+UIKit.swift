//
//  ScrollListAdapter+UIKit.swift
//  ListKit
//
//  Created by Frain on 2019/12/10.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension DataSource {
    typealias ScrollContext = ListContext<UIScrollView, Self>
    typealias ScrollFunction<Input, Output, Closure> = ListDelegate.Function<UIScrollView, Self, ScrollList<AdapterBase>, Input, Output, Closure>

    var scrollViewDidScroll: ScrollFunction<Void, Void, (ScrollContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidScroll), toClosure())
    }

    var scrollViewDidZoom: ScrollFunction<Void, Void, (ScrollContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidZoom), toClosure())
    }

    var scrollViewWillBeginDragging: ScrollFunction<Void, Void, (ScrollContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewWillBeginDragging), toClosure())
    }

    var scrollViewWillEndDragging: ScrollFunction<(CGPoint, UnsafeMutablePointer<CGPoint>), Void, (ScrollContext, CGPoint, UnsafeMutablePointer<CGPoint>) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewWillEndDragging), toClosure())
    }

    var scrollViewDidEndDragging: ScrollFunction<Bool, Void, (ScrollContext, Bool) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidEndDragging), toClosure())
    }

    var scrollViewWillBeginDecelerating: ScrollFunction<Void, Void, (ScrollContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewWillBeginDecelerating), toClosure())
    }

    var scrollViewDidEndDecelerating: ScrollFunction<Void, Void, (ScrollContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidEndDecelerating), toClosure())
    }

    var scrollViewDidEndScrollingAnimation: ScrollFunction<Void, Void, (ScrollContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidEndScrollingAnimation), toClosure())
    }

    var viewForZooming: ScrollFunction<Void, UIView?, (ScrollContext) -> UIView?> {
        toFunction(#selector(UIScrollViewDelegate.viewForZooming), toClosure())
    }

    var scrollViewWillBeginZooming: ScrollFunction<UIView?, Void, (ScrollContext, UIView?) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewWillBeginZooming), toClosure())
    }

    var scrollViewDidEndZooming: ScrollFunction<(UIView?, CGFloat), Void, (ScrollContext, UIView?, CGFloat) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidEndZooming), toClosure())
    }

    var scrollViewShouldScrollToTop: ScrollFunction<Void, Bool, (ScrollContext) -> Bool> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewShouldScrollToTop), toClosure())
    }

    var scrollViewDidScrollToTop: ScrollFunction<Void, Void, (ScrollContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidScrollToTop), toClosure())
    }

    @available(iOS 11.0, *)
    var scrollViewDidChangeAdjustedContentInset: ScrollFunction<Void, Void, (ScrollContext) -> Void> {
        toFunction(#selector(UIScrollViewDelegate.scrollViewDidChangeAdjustedContentInset), toClosure())
    }
}

#endif
