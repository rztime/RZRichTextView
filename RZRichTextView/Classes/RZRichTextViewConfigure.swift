//
//  RZRichTextViewConfigure.swift
//  RZRichTextView
//
//  Created by rztime on 2024/8/23.
//

import UIKit
import Kingfisher

open class RZRichTextViewConfigure: NSObject {
    public static var shared: RZRichTextViewConfigure = .init()
    /// 图片或者音频view上下左右边距（可编辑时）
    public var imageViewEdgeInsets: UIEdgeInsets = .init(top: 15, left: 3, bottom: 3, right: 15)
    /// 图片或者音频view上下左右边距（不可编辑时，即预览时）
    public var imageViewEdgeInsetsNormal: UIEdgeInsets = .init(top: 3, left: 3, bottom: 3, right: 3)
    /// 这个颜色将生成一张占位图
    public var backgroundColor: UIColor = .clear
    /// 加载失败的图片，gif的话可以参照初始化方法设置
    public var loadErrorImage: UIImage?
    /// 加载中的图片，gif的话可以参照初始化方法设置
    public var loadingImage: UIImage?
    /// 同步获取图片，可以按需设置请求图片的方法，注意gif、视频首帧图
    public var sync_imageBy: ((_ source: String?) -> UIImage?)?
    /// 异步获取图片，complete里的source需要于图片对应，可以按需设置请求图片的方法，注意gif、视频首帧图
    public var async_imageBy: ((_ source: String?, _ complete: ((_ source: String?, _ image: UIImage?) -> Void)?) -> Void)?
    
    public override init() {
        super.init()
        /// 同步获取图片
        self.sync_imageBy = { source in
            let imgView = AnimatedImageView()
            imgView.kf.setImage(with: source?.qtoURL)
            return imgView.image
        }
        /// 异步获取图片(当图片获取失败时，则用默认的错误图片替代)
        self.async_imageBy = { [weak self] source, complete in
            let comp = complete
            guard let s = source else {
                comp?(source, self?.loadErrorImage)
                return
            }
            var imgView : AnimatedImageView? = .init()
            imgView?.kf.setImage(with: source?.qtoURL) { result in
                let image = try? result.get().image
                if image == nil {
                    /// 图片获取失败，当做视频去请求首帧，并缓存
                    UIImage.qimageByVideoUrl(s) { _, image in
                        if let image = image {
                            ImageCache.default.store(image, forKey: s)
                        }
                        comp?(s, image ?? self?.loadErrorImage)
                        imgView = nil
                    }
                } else {
                    comp?(s, image ?? self?.loadErrorImage)
                    imgView = nil
                }
            }
        }
        /// 加载中, 默认gif
        let loading: URL? = RZRichImage.imagePathWith("loading.gif")
        AnimatedImageView().kf.setImage(with: loading) { [weak self] result in
            self?.loadingImage = try? result.get().image
        }
        /// 加载失败
        self.loadErrorImage = RZRichImage.imageWith("loaderror")
    }
}
