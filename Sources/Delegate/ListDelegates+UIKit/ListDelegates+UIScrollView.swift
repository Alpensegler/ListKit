//
//  ListDelegates+UIScrollView.swift
//  ListKit
//
//  Created by Frain on 2019/12/8.
//

#if os(iOS) || os(tvOS)
import UIKit

//MARK: - ScrollView Delegate
extension Delegate: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        apply(scrollViewDidScroll, object: scrollView)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        apply(scrollViewDidZoom, object: scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        apply(scrollViewWillBeginDragging, object: scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        apply(scrollViewWillEndDragging, object: scrollView, with: (velocity, targetContentOffset))
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        apply(scrollViewDidEndDragging, object: scrollView, with: (decelerate))
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        apply(scrollViewWillBeginDecelerating, object: scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        apply(scrollViewDidEndDecelerating, object: scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        apply(scrollViewDidEndScrollingAnimation, object: scrollView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        apply(viewForZooming, object: scrollView) ?? nil
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        apply(scrollViewWillBeginZooming, object: scrollView, with: (view))
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        apply(scrollViewDidEndZooming, object: scrollView, with: (view, scale))
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        apply(scrollViewShouldScrollToTop, object: scrollView) ?? true
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        apply(scrollViewDidScrollToTop, object: scrollView)
    }
    
    @available(iOS 11.0, *)
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        apply(scrollViewDidChangeAdjustedContentInset, object: scrollView)
    }
}


#endif

