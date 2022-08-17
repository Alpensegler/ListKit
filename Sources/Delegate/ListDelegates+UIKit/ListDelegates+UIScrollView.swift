//
//  ListDelegates+UIScrollView.swift
//  ListKit
//
//  Created by Frain on 2019/12/8.
//

#if os(iOS) || os(tvOS)
import UIKit

extension Delegate: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        apply(#selector(UIScrollViewDelegate.scrollViewDidScroll(_:)), view: scrollView) ?? ()
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        apply(#selector(UIScrollViewDelegate.scrollViewDidZoom(_:)), view: scrollView) ?? ()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        apply(#selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:)), view: scrollView) ?? ()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        apply(#selector(UIScrollViewDelegate.scrollViewWillEndDragging(_:withVelocity:targetContentOffset:)), view: scrollView, with: (velocity, targetContentOffset)) ?? ()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        apply(#selector(UIScrollViewDelegate.scrollViewDidEndDragging(_:willDecelerate:)), view: scrollView, with: (decelerate)) ?? ()
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        apply(#selector(UIScrollViewDelegate.scrollViewWillBeginDecelerating(_:)), view: scrollView) ?? ()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        apply(#selector(UIScrollViewDelegate.scrollViewDidEndDecelerating(_:)), view: scrollView) ?? ()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        apply(#selector(UIScrollViewDelegate.scrollViewDidEndScrollingAnimation(_:)), view: scrollView) ?? ()
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        apply(#selector(UIScrollViewDelegate.viewForZooming(in:)), view: scrollView) ?? nil
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        apply(#selector(UIScrollViewDelegate.scrollViewWillBeginZooming(_:with:)), view: scrollView, with: (view)) ?? ()
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        apply(#selector(UIScrollViewDelegate.scrollViewDidEndZooming(_:with:atScale:)), view: scrollView, with: (view, scale)) ?? ()
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        apply(#selector(UIScrollViewDelegate.scrollViewShouldScrollToTop(_:)), view: scrollView) ?? true
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        apply(#selector(UIScrollViewDelegate.scrollViewDidScrollToTop(_:)), view: scrollView) ?? ()
    }

    @available(iOS 11.0, *)
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        apply(#selector(UIScrollViewDelegate.scrollViewDidChangeAdjustedContentInset(_:)), view: scrollView) ?? ()
    }
}

#endif
