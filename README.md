# RZRichTextView

[![CI Status](https://img.shields.io/travis/rztime/RZRichTextView.svg?style=flat)](https://travis-ci.org/rztime/RZRichTextView)
[![Version](https://img.shields.io/cocoapods/v/RZRichTextView.svg?style=flat)](https://cocoapods.org/pods/RZRichTextView)
[![License](https://img.shields.io/cocoapods/l/RZRichTextView.svg?style=flat)](https://cocoapods.org/pods/RZRichTextView)
[![Platform](https://img.shields.io/cocoapods/p/RZRichTextView.svg?style=flat)](https://cocoapods.org/pods/RZRichTextView)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

RZRichTextView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RZRichTextView'
```

## Author

rztime, rztime@vip.qq.com qq交流群：580839749

## License

RZRichTextView is available under the MIT license. See the LICENSE file for more info.


# 简介

RZRichTextView继承UITextView，实现富文本编辑功能。使用Swift完成，基本所有的方法和属性都是公开的，方便继承或自定义修改，如果OC项目使用，可以使用桥接。

#### 支持的功能

    . 插入图片、视频
    . 字体样式（大小、颜色、背景色、粗体斜体、下划线、删除线）等等
    . 列表，即html里的ul、ol标签
    . 上下标（偏移）
    . 描边
    . 阴影
    . 拉伸
    . 段落样式（对齐方式、行距、缩进）
    . 插入url链接：插入的方式很多，可以参考demo。 url进行了一次转码`text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)`，否则输入中文，点击会崩溃，所以这里设置、取用需注意转码解码

# 功能说明

支持的功能，可以查看demo。  
UITextView的typingAttributes，会根据光标位置改变，自动改变成上一个文本的相关属性，在输入文字之后，会自动填充到新的文本中  
文本操作分 插入，新增，删除，替换，就是对UITextView的attributedText的不断修改，然后设置正确的selectedRange  
  
  
#### 1.关于[RZColorful](https://github.com/rztime/RZColorful) [RZColorfulSwift](https://github.com/rztime/RZColorfulSwift) 
为方便Swift或者OC能够使用RZRichTextView，此次版本将RZColorful分开，将不在依赖，避免RZColorful RZColorfulSwift两个版本的冲突，需要使用时，按项目类型自行添加RZColorful，不了解RZColorful的功能的话，可以去看看[RZColorful](https://github.com/rztime/RZColorful)

#### 依赖库
    SnapKit：用于设置自动布局

#### 2.插入视频、图片

`NSTextAttachment`
```Swift
class func creatWith(image: UIImage, asset: PHAsset? = nil) -> NSTextAttachment {
    let attach = NSTextAttachment.init()
    attach.image = image
    let obj = RZRichAttachmentObj.init()
    obj.asset = asset
    obj.image = image
    obj.type = asset?.mediaType == .video ? .video : .image
    obj.identifier = asset?.localIdentifier ?? "\(image.description)"
    attach.rzrt = obj
    return attach
}
```
    
在`RZRichTextAttachment.swift`中给NSTextAttachment添加了一个属性**rzrt**: **RZRichAttachmentObj**，包含了**图片、PHAsset, Type信息，maskView**

    maskView：图片上的遮罩View，与图片大小一致，添加在UITextView上，跟随图片在文本中的位置而改变，可以在maskView上添加删除、进度、播放、预览等自定义UI
    
#### 3.字体设置

> 1.**斜体字**：中文不支持斜体，所以可以找第三方支持中文的斜体字库来实现，原先通过`obliqueness`来实现的斜体，就是通过旋转字体来实现，但是在NSAttributedString与html互转时，无法互通，所以建议使用中文斜体字库来实现。[RZColorful](https://github.com/rztime/RZColorful)中codingToCompleteHtmlByWeb，就是通过旋转字体来实现斜体字，但是无法从html还原到NSAttributedString
    
> 2.**字体大小、颜色、高亮色、上下标（偏移）、描边、阴影、拉伸**：是对NSAttributedString.Key的使用

> 3.**列表（有序、无序）**：html中的ul、ol，这一个功能的实现逻辑比较复杂，在iOS中不支持，属于私有API，这里通过插入html里的《ul》《/ul》《ol》《/ol》生成一个NSTextList,再在**NSParagraphStyle**复制引用NSTextList,为了能连续，整个过程使用单利初始化的NSTextList，这样在编辑过程中，相邻两段，才能组成一个列表。一些逻辑处理也比较复杂，可能不全面，目前处理的方式是，当新的一行未输入内容的，点按回车或者删除，这一行列表输入就将取消。如果有其他交互逻辑，可以反馈给我。

NSTextList在MacOS上支持，在iOS中并未公开，仅做私有属性，所以无法自行设置，但是在设置html ul ol之后，打印NSParagraphStyle可以看到NSTextList的描述信息。

> 4.**插入url**：在插入url时，分了两种情况，1.插入图片或者文字，然后给图片文字添加链接，这样生成html的时候，url会隐藏，但是点击文字图片可以跳转。2.仅插入url，这样生成html时，url是当做文字同时显示并且可点击的


# 使用说明

#### 1.RZRichTextViewOptions
    RZRichTextViewOptions配置文件，包含了常规设置
    字体，  
    颜色，  
    工具条图片，  
    工具条item分类，  
    各种事件的回调，  
    url  

需要实现`openPhotoLibrary`方法，打开相册选择图片或者视频，完成后调用complete（image, PHAsset）,将图片视频插入到textView中

插入的图片，可以在`willInsetImage`中进行统一处理

要绑定上传进度等等自定义UI功能，`didInsetAttachment`、`didRemovedAttachment`可以管理进度和UI，在NSTextAttachment中，rzrh里的maskView上可以添加自定义UI。

在输入过程中，因为涉及到删除，重新写入，撤销，恢复等操作，所以一张图片可能会重复插入，didInsetAttachment会重复调用，所以在插入自定义UI时，最好判断是否已经加载有了，防止重复插入

#### 2.RZRichTextView

初始化的时候，
```
 public init(frame: CGRect, options: RZRichTextViewOptions = .shared)
```
RZRichTextViewOptions,可以使用shared，或者init（）一个新的，这样方便全局使用或者单独使用

#### 3.RZRichTextViewHelper

专门用于处理TextView相关的插入、删除、工具条点击事件等等方法集合

要调用或者修改,可以直接通过textView.helper.didSelectedToolbarItem()方式来调用方法

也可以继承RZRichTextViewHelper，重写里边的方法来实现自己想要的功能，只需要初始化之后，设置到textView.helper上

# 示例

简单使用
```
let options = RZRichTextViewOptions.init()
/// 对要插入的图片进行处理，比如加水印等等
options.willInsetImage = { image in
    return image
}
/// 插入了一个图片或视频，这里返回附件
options.didInsetAttachment = { attahcment in
    // 这是图片上的蒙层，可以添加一些进度控件、删除控件等等
    attahcment.rzrt.maskView.backgroundColor = UIColor.init(red: 1, green: 0, blue: 0, alpha: 0.3)
    // 也可以根据需要绑定上传
}
/// 移除了附件
options.didRemovedAttachment = { attachments in
    print("移除了\(attachments.description)")
}

let textView = RZRichTextView.init(frame: .zero, options: options)
self.view.addSubview(textView)
textView.backgroundColor = .lightGray
```
### 选择图片视频
image必须存在，才能设置NSAttachment，也就是插入到textView中才有效，不然也看不见

请自行选择合适的图片选择库，来实现图片视频的选择功能
```
// 打开相册
options.openPhotoLibrary = { complete in
    let vc = TZImagePickerController.init(maxImagesCount: 1, delegate: nil)
    vc?.allowPickingImage = true
    vc?.allowPickingVideo = true
    vc?.allowTakeVideo = false
    vc?.allowTakePicture = false
    vc?.allowCrop = false
    vc?.didFinishPickingPhotosHandle = { (photos, assets, _) in
        if let image = photos?.first {
            let asset = assets?.first as? PHAsset
            complete(image, asset)
        }
    }
    vc?.didFinishPickingVideoHandle = { (image, asset) in
        if let image = image {
            complete(image, asset)
        }
    }
    RZRichTextViewUtils.rz_currentViewController()?.present(vc!, animated: true, completion: nil)
}
```


自定义工具条cell
```
/// 自定义工具条上的cell
options.willRegisterAccessoryViewCell = { collectionView in
    collectionView.register(CustomCell.self, forCellWithReuseIdentifier: "CustomCell")
}
/// 实现工具条cell的样式UI
options.accessoryViewCellFor = { (collectionView, item, indexPath) -> UICollectionViewCell? in
    switch item.type {
    case CustomToolBar.custom1.rawValue:
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as? CustomCell {
            cell.imageView.image = item.displayImage()
            cell.textLabel.text = "\(CustomToolBar.custom1)"
            return cell
        }
    case CustomToolBar.custom2.rawValue:
        print("自行处理时，return cell 否则return nil")
        return nil
    case CustomToolBar.custom3.rawValue:
        print("自行处理时，return cell 否则return nil")
        return nil
    default: break
    }
    return nil
}
```

自定义实现工具条点击的事件
```
/// 自定义实现点击事件
options.didSelectedToolbarItem = { (item, index) -> Bool in
    switch item.type {
    case CustomToolBar.custom1.rawValue:
        print("点击了cell时，若需自己实现，return false: \(CustomToolBar.custom1)")
        return false
    case CustomToolBar.custom2.rawValue:
        print("点击了cell时，若需自己实现，return false: \(CustomToolBar.custom2)")
        return false
    case CustomToolBar.custom3.rawValue:
        print("点击了cell时，若需自己实现，return false: \(CustomToolBar.custom3)")
        return false
    default: break
    }
    return true
}
```
