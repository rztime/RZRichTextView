# RZRichTextView


可以直接添加

```objc
pod 'RZRichTextView'
```

* UITextView富文本编辑器

* RZRichTextView 继承自UITextView

* 暂时只做一个demo，提供部分功能

    * 图片
    * 粗体
    * 斜体
    * 下划线
    * 删除线
    * 字体大小
    * 字体颜色
    * 对齐方式
    
空了在继续优化吧

* 插入图片到富文本之后，在转换成HTML标签之前，需要将图片上传至服务器得到URL，最后将URL替换图片之后，生成HTML标签
```objc
/**
获取输入框中的所有图片

@return 按照图片插入顺序排列
*/
- (NSArray <UIImage *> *)rz_rictTextImages;
```

```objc
/**
将富文本内容转换成HTML标签语言 urls需与图片顺序、数量一致（倒叙方式插入，缺失可能导致图片顺序不准确）

@param urls 图片的链接，如果有图片，则请将图片先上传至自己的服务器中，得到地址。然后在转换成HTML时，urls图片顺序将与[- (NSArray <UIImage *> *)rz_rictTextImages]方法得到的图片顺序一致
@return HTML标签string。
*/
- (NSString *)rz_codingToHtmlWithImageURLS:(NSArray <NSString *> *)urls;

```

