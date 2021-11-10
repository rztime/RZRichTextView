//
//  RZRichTextViewUtils.swift
//  RZRichTextView
//
//  Created by rztime on 2021/10/17.
//

import UIKit
import Photos

@objcMembers
open class RZRichTextViewUtils: NSObject {
    // 获取当前显示的vc
    open class func rz_currentViewController() -> UIViewController? {
        let root = UIApplication.shared.keyWindow?.rootViewController
        return self.rz_getCurrentVCFrom(root)
    }
    open class func rz_getCurrentVCFrom(_ vc: UIViewController?) -> UIViewController? {
        guard let vc = vc else {
            return nil
        }
        var rootVC = vc
        var currentVC: UIViewController?
        if let vc = rootVC.presentedViewController {
            rootVC = self.rz_getCurrentVCFrom(vc) ?? rootVC
        }
        if let vc = rootVC as? UITabBarController {
            currentVC = self.rz_getCurrentVCFrom(vc.selectedViewController)
        } else if let vc = rootVC as? UINavigationController {
            currentVC = self.rz_getCurrentVCFrom(vc.visibleViewController)
        } else {
            currentVC = rootVC
        }
        return currentVC
    }
    // 模态跳转
    open class func rz_presentViewController(_ viewController: UIViewController, animated: Bool = true) {
        DispatchQueue.main.async {
            let vc = self.rz_currentViewController()
            let flag = vc?.definesPresentationContext ?? false
            vc?.definesPresentationContext = true
            viewController.modalPresentationStyle = .overCurrentContext
            viewController.modalTransitionStyle = .crossDissolve
            if ((vc?.navigationController?.viewControllers.count ?? 0) == 1 && (vc?.tabBarController == nil)) || (vc?.navigationController?.viewControllers.count ?? 0) > 0 {
                vc?.navigationController?.present(viewController, animated: animated, completion: { [weak vc] in
                    vc?.definesPresentationContext = flag
                })
            } else if let tempVc = vc?.tabBarController {
                tempVc.present(viewController, animated: animated) { [weak vc] in
                    vc?.definesPresentationContext = flag
                }
            } else {
                vc?.present(viewController, animated: animated, completion: { [weak vc] in
                    vc?.definesPresentationContext = flag
                })
            }
        }
    }
    /// 找到新的range
    /// - Parameters:
    ///   - attributedText: 原来的文本
    ///   - range: 原来的range
    ///   - attributedText1: 新的文本
    /// - Returns: 新的range
    open class func newRangeFor(origin attributedText: NSAttributedString?, range: NSRange, new attributedText1: NSAttributedString?) -> NSRange {
        guard let attributedText = attributedText, let attributedText1 = attributedText1 else {
            return range
        }
        // 先找到所有的段落range
        let allParagraphs = attributedText.allParapraghRange()
        if allParagraphs.count == 0 {
            return range
        }
        // 找到range所在段落的range数组
        let ranges = attributedText.paragraphRanges(for: range)

        // 找到第一段所在行
        let firstLine = allParagraphs.firstIndex(where: {$0 == ranges.first}) ?? 0
        // 找到最后一段所在行
        let lastLine = allParagraphs.firstIndex(where: {$0 == ranges.last}) ?? 0
        // 找到一段range起点的段区域
        let firstRange = attributedText.parapraghRange(for: .init(location: range.location, length: 0))
        // 找到range 结束点的段的区域
        let lastRange = attributedText.parapraghRange(for: .init(location: range.maxLength(), length: 0))
        // 新的所有段落range
        let newRanges = attributedText1.allParapraghRange()
        // 新的一段的range
        let newFirstRange = newRanges[firstLine]
        // 结束点的range
        let newLastRange = newRanges[lastLine]
        // 得到段尾长度
        let firstEnd = firstRange.maxLength() - range.location
        // 得到段尾长度
        let lastEnd = lastRange.maxLength() - range.maxLength()
        // 找到起点
        let star = max(newFirstRange.maxLength() - firstEnd, newFirstRange.location)
        // 找到终点
        let end = max(newLastRange.maxLength() - lastEnd, newLastRange.location)
        /// 核心方法：找到range所选区域的第一段和最后一段，然后计算第一段的起点，和最后一段的终点， 
        /// 如  1234
        ///    56789
        ///    12345678
        ///     allParagraphs  就是 [0, 4] [5, 5] [10, 8]
        ///  range 选择为的字符串为3456789123，
        ///     ranges 就是 [0, 4] [5, 5] [10, 8]
        ///     firstLine = 0
        ///     lastLine = 2
        ///   第一段 起点3 ，距离第一段末尾，还剩2
        ///   第三段 终点3，距离第三段末尾，还剩 5
        ///      attributedText1：
        ///        \t1234
        ///        \t56789
        ///        \t12345678
        ///    然后分别找到新的newRanges[0, 5] [5, 6] [11, 9]
        ///  新的range起点star就是第一段(0+5)-2 = 3，终点end就是第三段 (11+9) - 5 = 15，得到star end，就得到新的range
        ///
        return .init(location: star, length: end - star)
    }
}
// 正则，rt里主要用于验证是否包含制表符
public extension String {
    func rangesWith(pattern: String) -> [NSRange]? {
        let string = self as NSString
        let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        let matches = regex?.matches(in: self, options: [], range: NSMakeRange(0, string.length))
        return  matches?.map({$0.range})
    }
}
