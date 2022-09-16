//
//  ListDelegates+UIScrollView.swift
//  ListKit
//
//  Created by Frain on 2019/12/8.
//

#if os(iOS) || os(tvOS)
import UIKit

//extension Delegate: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        apply(#selector(UIScrollViewDelegate.scrollViewDidScroll(_:)), view: scrollView, default: ())
//    }
//
//    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        apply(#selector(UIScrollViewDelegate.scrollViewDidZoom(_:)), view: scrollView, default: ())
//    }
//
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        apply(#selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:)), view: scrollView, default: ())
//    }
//
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        apply(#selector(UIScrollViewDelegate.scrollViewWillEndDragging(_:withVelocity:targetContentOffset:)), view: scrollView, with: (velocity, targetContentOffset), default: ())
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        apply(#selector(UIScrollViewDelegate.scrollViewDidEndDragging(_:willDecelerate:)), view: scrollView, with: (decelerate), default: ())
//    }
//
//    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//        apply(#selector(UIScrollViewDelegate.scrollViewWillBeginDecelerating(_:)), view: scrollView, default: ())
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        apply(#selector(UIScrollViewDelegate.scrollViewDidEndDecelerating(_:)), view: scrollView, default: ())
//    }
//
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        apply(#selector(UIScrollViewDelegate.scrollViewDidEndScrollingAnimation(_:)), view: scrollView, default: ())
//    }
//
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        apply(#selector(UIScrollViewDelegate.viewForZooming(in:)), view: scrollView, default: nil)
//    }
//
//    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
//        apply(#selector(UIScrollViewDelegate.scrollViewWillBeginZooming(_:with:)), view: scrollView, with: (view), default: ())
//    }
//
//    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//        apply(#selector(UIScrollViewDelegate.scrollViewDidEndZooming(_:with:atScale:)), view: scrollView, with: (view, scale), default: ())
//    }
//
//    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
//        apply(#selector(UIScrollViewDelegate.scrollViewShouldScrollToTop(_:)), view: scrollView, default: true)
//    }
//
//    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
//        apply(#selector(UIScrollViewDelegate.scrollViewDidScrollToTop(_:)), view: scrollView, default: ())
//    }
//
//    @available(iOS 11.0, *)
//    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
//        apply(#selector(UIScrollViewDelegate.scrollViewDidChangeAdjustedContentInset(_:)), view: scrollView, default: ())
//    }
//}

#endif
