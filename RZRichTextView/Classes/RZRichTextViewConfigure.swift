//
//  RZRichTextViewConfigure.swift
//  RZRichTextView
//
//  Created by rztime on 2024/8/23.
//

import UIKit
import Photos
/// 一些配置不方便写在viewModel里,所以加了一个configure,做一些额外的配置
open class RZRichTextViewConfigure: NSObject {
    public static var shared: RZRichTextViewConfigure = .init()
    /// 图片或者音频view上下左右边距（可编辑时）
    public var imageViewEdgeInsets: UIEdgeInsets = .init(top: 15, left: 3, bottom: 3, right: 15)
    /// 图片或者音频view上下左右边距（不可编辑时，即预览时）
    public var imageViewEdgeInsetsNormal: UIEdgeInsets = .init(top: 3, left: 3, bottom: 3, right: 3)
    /// 这个颜色将生成一张占位图
    public var attachBackgroundColor: UIColor = .clear
    /// 加载失败的图片，gif的话可以参照初始化方法设置
    public var loadErrorImage: UIImage?
    /// 加载中的图片，gif的话可以参照初始化方法设置
    public var loadingImage: UIImage?
    
    /*** 同步、异步获取图片，参考HowToUseDemo里进行配置，这里默认没有实现，因为kingfisher加了MainActor，会有一定的冲突，
     解决办法：加 @MainActor
     @MainActor
     public extension RZRichTextViewModel {  }
     https://github.com/rztime/RZRichTextView/blob/master/Example/RZRichTextView/HowToUseDemo.swift
     ***/
    /// 同步获取图片，可以按需设置请求图片的方法，注意gif、视频首帧图
    public var sync_imageBy: ((_ source: String?) -> UIImage?)?
    /// 异步获取图片，complete里的source需要于图片对应，可以按需设置请求图片的方法，注意gif、视频首帧图
    public var async_imageBy: ((_ source: String?, _ complete: ((_ source: String?, _ image: UIImage?) -> Void)?) -> Void)?
    /// 异步获取图片，complete里的source需要于图片对应，可以按需设置请求图片的方法，注意gif、视频首帧图
    public var async_imageByAsset: ((_ asset: PHAsset?, _ complete: ((_ asset: PHAsset?, _ image: UIImage?) -> Void)?) -> Void)?
    
    /// 转换为html时,blockquote的style
    public var blockquoteStyle = #"border-left: 5px solid #eeeeee;"#
    /// 块\列表只能存在一个,默认true   (false时,可以同时存在)
    open var quoteOrTab = true
    /// 列表ul\ol是否可用 默认true可用
    open var tabEnable = true
    /// 无序列表前序号的配置
    open var ulSymbol: String = "·"
    /// 无序列表文本对齐方式
    open var ulSymbolAlignment: NSTextAlignment = .right
    /// nil时,将与文本对应的font一致
    open var ulSymbolFont: UIFont?
    
    /// 块是否可用,默认false
    open var quoteEnable = false
    /// 块引用(前方贴一个背景色view)
    open var quoteColor = UIColor.qhex(0xcccccc)
    
    public override init() {
        super.init()
        /// 加载失败
        self.loadErrorImage = RZRichImage.imageWith("loaderror")
        
#if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
            if self?.async_imageBy == nil ||
                self?.sync_imageBy == nil ||
                self?.async_imageByAsset == nil {
                let text = """
------------ 请参考HowToUseDemo, 配置图片加载方法 ------------
https://github.com/rztime/RZRichTextView/blob/master/Example/RZRichTextView/HowToUseDemo.swift

如有必要，请加@MainActor 到
    @MainActor
    public extension RZRichTextViewModel {  }
----------------------------------------------------------
"""
                print(text)
            }
        })
#endif
    }
}
