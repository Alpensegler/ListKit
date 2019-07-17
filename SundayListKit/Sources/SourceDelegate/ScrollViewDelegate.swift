//
//  ScrollViewDelegate.swift
//  SundayListKit
//
//  Created by Frain on 2019/3/27.
//  Copyright © 2019 Frain. All rights reserved.
//

import UIKit

public protocol ScrollViewDelegate {
    // Responding to Scrolling and Dragging
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView)
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)

    //Managing Zooming
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?)
    func scrollViewDidZoom(_ scrollView: UIScrollView)
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat)

    //Responding to Scrolling Animations
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    
    //Responding to Inset Changes
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView)
}

public extension ScrollViewDelegate {
    // Responding to Scrolling and Dragging
    func scrollViewDidScroll(_ scrollView: UIScrollView) { }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) { }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) { }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) { }
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool { return true }
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) { }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) { }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { }

    //Managing Zooming
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { return nil }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) { }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) { }

    //Responding to Scrolling Animations
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) { }
    
    //Responding to Inset Changes
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) { }
}
