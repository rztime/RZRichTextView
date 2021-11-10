//
//  RZRichTextViewDelegate.swift
//  RZRichTextView
//
//  Created by rztime on 2021/10/15.
//

import UIKit
/// 转换一下RZTextView的delegate
@objcMembers
open class RZRichTextViewDelegate: NSObject, UITextViewDelegate {
    /// 转一次的delegte
    open weak var delegate: UITextViewDelegate?
    /// 真实的用户设置的delegate
    open weak var target: UITextViewDelegate?
    public init(target: UITextViewDelegate?, delegate: UITextViewDelegate?) {
        self.target = target
        self.delegate = delegate
    }
    open func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if let target = target {
            if !(target.textViewShouldBeginEditing?(textView) ?? true) {
                return false
            }
        }
        if let delegate = delegate {
            if !(delegate.textViewShouldBeginEditing?(textView) ?? true) {
                return false
            }
        }
        return true
    }
    open func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if let target = target {
            if !(target.textViewShouldEndEditing?(textView) ?? true) {
                return false
            }
        }
        if let delegate = delegate {
            if !(delegate.textViewShouldEndEditing?(textView) ?? true) {
                return false
            }
        }
        return true
    }
    open func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.textViewDidBeginEditing?(textView)
        target?.textViewDidBeginEditing?(textView)
    }
    open func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textViewDidEndEditing?(textView)
        target?.textViewDidEndEditing?(textView)
    }
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var typingAttributes = textView.typingAttributes
        typingAttributes[NSAttributedString.Key.link] = nil
        textView.typingAttributes = typingAttributes
        if let target = target {
            if !(target.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true) {
                return false
            }
        }
        if let delegate = delegate {
            if !(delegate.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true) {
                return false
            }
        }
        return true
    }
    open func textViewDidChange(_ textView: UITextView) {
        delegate?.textViewDidChange?(textView)
        target?.textViewDidChange?(textView)
    }
    open func textViewDidChangeSelection(_ textView: UITextView) {
        delegate?.textViewDidChangeSelection?(textView)
        target?.textViewDidChangeSelection?(textView)
    }
    @available(iOS 10.0, *)
    open func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let target = target {
            if !(target.textView?(textView, shouldInteractWith: URL, in: characterRange, interaction: interaction) ?? true) {
                return false
            }
        }
        if let delegate = delegate {
            if !(delegate.textView?(textView, shouldInteractWith: URL, in: characterRange, interaction: interaction) ?? true) {
                return false
            }
        }
        return true
    }
    @available(iOS 10.0, *)
    open func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let target = target {
            if !(target.textView?(textView, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction) ?? true) {
                return false
            }
        }
        if let delegate = delegate {
            if !(delegate.textView?(textView, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction) ?? true) {
                return false
            }
        }
        return true
    }
    @available(iOS, introduced: 7.0, deprecated: 10.0)
    open func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if let target = target {
            if !(target.textView?(textView, shouldInteractWith: URL, in: characterRange) ?? true) {
                return false
            }
        }
        if let delegate = delegate {
            if !(delegate.textView?(textView, shouldInteractWith: URL, in: characterRange) ?? true) {
                return false
            }
        }
        return true
    }
    open func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        if let target = target {
            if !(target.textView?(textView, shouldInteractWith: textAttachment, in: characterRange) ?? true) {
                return false
            }
        }
        if let delegate = delegate {
            if !(delegate.textView?(textView, shouldInteractWith: textAttachment, in: characterRange) ?? true) {
                return false
            }
        }
        return true
    }
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        target?.scrollViewDidScroll?(scrollView)
        delegate?.scrollViewDidScroll?(scrollView)
    }
    open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        target?.scrollViewDidZoom?(scrollView)
        delegate?.scrollViewDidZoom?(scrollView)
    }
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        target?.scrollViewWillBeginDragging?(scrollView)
        delegate?.scrollViewWillBeginDragging?(scrollView)
    }
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        target?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        delegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    @available(iOS 2.0, *)
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        target?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    @available(iOS 2.0, *)
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {// called on finger up as we are moving
        target?.scrollViewWillBeginDecelerating?(scrollView)
        delegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    @available(iOS 2.0, *)
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { // called when scroll view grinds to a halt
        target?.scrollViewDidEndDecelerating?(scrollView)
        delegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    @available(iOS 2.0, *)
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
        target?.scrollViewDidEndScrollingAnimation?(scrollView)
        delegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    @available(iOS 2.0, *)
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? { // return a view that will be scaled. if delegate returns nil, nothing happens
        if let view = target?.viewForZooming?(in: scrollView) {
            return view
        }
        if let view = delegate?.viewForZooming?(in: scrollView) {
            return view
        }
        return nil
    }
    @available(iOS 3.2, *)
    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) { // called before the scroll view begins zooming its content
        target?.scrollViewWillBeginZooming?(scrollView, with: view)
        delegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }
    @available(iOS 2.0, *)
    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) { // scale between minimum and maximum. called after any 'bounce' animations
        target?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
        delegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    @available(iOS 2.0, *)
    open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool { // return a yes if you want to scroll to the top. if not defined, assumes YES
        let y = (target?.scrollViewShouldScrollToTop?(scrollView) ?? true)
        if !y { return false }
        let y1 = (delegate?.scrollViewShouldScrollToTop?(scrollView) ?? true)
        if !y1 {return false}
        return true
    }
    @available(iOS 2.0, *)
    open func scrollViewDidScrollToTop(_ scrollView: UIScrollView) { // called when scrolling animation finished. may be called immediately if already at top
        target?.scrollViewDidScrollToTop?(scrollView)
        delegate?.scrollViewDidScrollToTop?(scrollView)
    }
    @available(iOS 11.0, *)
    open func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        target?.scrollViewDidChangeAdjustedContentInset?(scrollView)
        delegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
}
