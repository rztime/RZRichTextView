* v1.0.1
    
    * 
        修改了bug：多次交替输入图片、回车后，图片遮罩显示位置不对的问题
        
    ***

    * . 修改了`RZRichTextView`里的`func rectFor(range: NSRange?) -> CGRect`方法
    * . 修改了`RZRichTextBase`里`public protocol RZRichTextProtocol { }`方法
    * . 新增`RZRichTextViewHelper`里
    `textView.layoutManager.ensureLayout(for: textView.textContainer)`代码
    

* v1.0.0
    
    * 整体重构，现在使用的是Swift，如果要在OC中使用，可以使用桥接引入，所有的属性和方法都是公开的，如果要自定义或者替换，都是可以的
    
    *** 
    
    * . 支持插入**图片、视频**，并且在NSAttachment中添加rzrt：可以设置相关的图片、视频信息，以及maskView遮罩，可以在maskView上添加删除，进度等自定义UI。maskView相当于是添加在UITextView上的覆盖在NSAttachment上与图片一样大小的遮罩。
    * . **重新设置了滑动控件**的UI
    * . **粗体、斜体、下划线、删除线**
    * . 支持**列表** 也就是<ul, ol>
    * . 增加引用，引用和列表目前还存在一点点冲突，需要优化
    ***
 

* v0.4.0
    * 优化了一下界面
    * 修复了编辑链接时，删除图片无效的bug
    * 如果要NSAttributedString 与 html 互相转换
        * 请参考 [RZColorful](https://github.com/rztime/RZColorful)
            [NSAttributedString+RZHtml.m](https://github.com/rztime/RZColorful/blob/master/RZColorfulExample/RZColorful/AttributeCore/NSAttributedString%2BRZHtml.m)
```objc
 - (NSString *)rz_codingToCompleteHtmlByWeb;
```
        系统方法转换时，会丢失部分属性，所以取巧，用这种方法来加上style，供借鉴和学习，如果有更好的方法，可以一起交流


* v0.3.1
    * 优化文本属性配置功能，解决在输入文字时，动态修改当前输入文本的属性，会跳动的问题
    * 新增在选择模式下，配置文本属性，可对当前选择的文本属性直接进行修改
    * 其他一些优化

* v0.3.0
    * 适配iOS 13 Light/Dark 下的UI颜色
    * 修复插入图片时，在相同属性行里插入图片，被前一次插入的图片覆盖的bug（只显示前一次插入的图片的bug）
    * 修复在新系统下，在输入TextView里插入了超链接文本时，点击超链接会跳转浏览器
    * 在插入超链接时，将对url中的中文进行转码（对应在获取原文时需解码）

* v0.2.0  
    * 修复在use_frameworks!下键盘工具条图片不显示的bug



