* v2.5.0
    * . html转NSAttributedString时，可以加自定义属性，可用于标记或存储额外的信息
    * . 参考“MarkViewController”，String.rzcustomMark(key: "fix", id: id)，key可以与id相同，生成的NSAttributedString的属性里里将包含"fix" = id
    * . 可以遍历所有的自定义属性，然后进行需要的操作

* v2.4.1
    * . 新增 将PHAsset的图片加载方法抛出来，可以自行设置
    * . 适配Kingfisher, 因为kingfisher加了@MainActor,导致低版本下会有冲突，所以将所有的图片获取方法，移动到HowToUseDemo进行配置，当需要适配高版本时，适当地方加@MainActor即可

* v2.4.0
    * . 新增一个RZRichTextViewConfigure，用于配置一些全局设置
    
    * . 1.添加了块引用（blockquote）, 块引用和列表ul、ol可以同时存在、也可以二选一，参考HowToUseDemo进行配置
    * . 2.优化了附件、列表序号的加载方式：
            [updateSubViews] 里修复附件的bounds、附件的位置、序号，
            [updateSubViews] 放在layoutSubViews里，大幅提升了加载效率，减少卡顿，减少了textView未渲染完成而可能导致的加载错误
    * . 3.优化了html转NSAttributedString时，附件相关的加载逻辑
        在编辑、预览不同情况下，在html转换过程中，将已经加载过的附件，与边距相加，计算出最终显示的真实大小设置到NSAttachment里，这样可以在textView加载过程中，少一次修复附件的bounds的方法，提高了加载效率。

* v2.3.0 
    * . 修复某些情况下，加载慢（目前仅发现有一个手机，安装了三方键盘，在重新编辑加载html的时候，判断键盘输入法是否中文正在输入时，无法成功获取键盘信息导致加载变慢）（很难复现）
    * . 卡（也是上述手机，在初始化界面加载完且在附件加载完，在fixAttachmentViewFrame中无法获取到附件的正确位置，导致这里循环卡顿，解决方法是在这个方法里加了延迟处理）（很难复现）
    * . 感谢iostang提交代码（无序符号相关的配置）


* v2.2.0 
    * . 修复某些情况下，图片高度显示错误
    * . 添加超链接默认样式设置
    * . 可设置字数显示的label的位置
    * . 添加自定义下载资源的方法，需要实现RZRichTextViewConfigure里的两个属性 


* v2.1.3
    * . 修复输入文本中带特殊符号时，转换为html后可能被当做标签而被隐藏
    * . 修复selectedrange.length大于0，且光标在末尾时，修改属性之后，再在末尾编辑时，光标处属性依然为之前的属性的bug

* v2.1.2
    * . 系统字体中，不支持斜体中文，所以在导出到html时，斜体属性在富文本的NSOriginFont里，此时用NSOriginFont来覆盖原NSFont

* v2.1.1
    * . 修复只有一个附件，删除时，uploadAttachmentsComplete重新设值


* v2.1.0
    * . 优化列表功能，解决列表带来的一系列bug
    * . 支持gif等显示
    * . 其他一些bug修改


* v2.0.0
    * . 全新重构，可拓展功能。


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



