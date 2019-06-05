//
//  NSAttributedString+RZColorful.m
//  RZColorfulExample
//
//  Created by rztime on 2017/11/15.
//  Copyright © 2017年 rztime. All rights reserved.
//

#import "NSAttributedString+RZColorful.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation NSAttributedString (RZColorful)

+ (NSAttributedString *)rz_colorfulConfer:(void(^)(RZColorfulConferrer *confer))attribute {
    if(!attribute) {
        return [NSAttributedString new];
    }
    RZColorfulConferrer *conferrer = [[RZColorfulConferrer alloc]init];
    attribute(conferrer);
    return [conferrer confer].copy;
}

- (NSAttributedString *)attributedStringByAppend:(NSAttributedString *)attributedString {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:self];
    [attr appendAttributedString:attributedString];
    return attr.copy;
}

/**
 固定宽度，计算高
 
 @param width 固定宽度
 @return <#return value description#>
 */
- (CGSize)sizeWithConditionWidth:(CGFloat)width {
    CGSize size = [self sizeWithCondition:CGSizeMake(width, CGFLOAT_MAX)];
    size.width = width;
    return size;
}


/**
 固定高度，计算宽
 
 @param height 固定高度
 @return <#return value description#>
 */
- (CGSize)sizeWithConditionHeight:(CGFloat)height {
    CGSize size = [self sizeWithCondition:CGSizeMake(CGFLOAT_MAX, height)];
    size.height = height;
    return size;
}
/**
 计算富文本的size
 如需计算高度 size = CGSizeMake(300, CGFLOAT_MAX)
 如需计算宽度 size = CGSizeMake(CGFLOAT_MAX, 18)
 
 @param size 约定的size，以宽高做条件，定宽时，计算得到高度（此时忽略宽度）
 定高时，计算得到宽度 （此时忽略高度）
 @return <#return value description#>
 */
- (CGSize)sizeWithCondition:(CGSize)size {
    CGRect rect = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return rect.size;
}

// 将html转换成 NSAttributedString
+ (NSAttributedString *)htmlString:(NSString *)html {
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType};
    NSError *error;
    NSAttributedString *htmlString = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:nil error:&error];
    if (!error) {
        return htmlString;
    } else {
        NSLog(@"__%s__\n 富文本html转换有误:\n%@", __FUNCTION__, error);
        return [NSAttributedString new];
    }
}

// 获取富文本中的图片
- (NSArray <UIImage *> *)rz_images {
    NSMutableArray *arrays = [NSMutableArray new];
    [self enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:[NSTextAttachment class]]) {
            NSTextAttachment *imageMent = value;
            if (imageMent.image) {
                [arrays addObject:imageMent.image];
            } else if(imageMent.fileWrapper.regularFileContents) {
                UIImage *image = [UIImage imageWithData:imageMent.fileWrapper.regularFileContents];
                if (image) {
                    [arrays addObject:image];
                }
            }
        }
    }];
    return arrays.copy;
}

/**
 将富文本编码成html标签，如果有图片，用此方法
 
 @param urls 图片的url，url需要先获取图片，然后自行上传到服务器，最后按照【- (NSArray <UIImage *> *)images;】此方法得到的图片顺序排列url
 @return HTML标签
 */
- (NSString *)rz_codingToHtmlWithImagesURLSIfHad:(NSArray <NSString *> *)urls {
    NSMutableAttributedString *tempAttr = self.mutableCopy;
    // 先将图片占位，等替换完成html标签之后，在将图片url替换回准确的
    __block NSInteger idx = 0;
    NSMutableArray *tempPlaceHolders = [NSMutableArray new];
    [tempAttr enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, tempAttr.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:[NSTextAttachment class]]) {
            NSString *placeHolder = [NSString stringWithFormat:@"rz_attributed_image_placeHolder_index_%lu", (unsigned long)idx];
            idx++;
            [tempAttr replaceCharactersInRange:range withString:placeHolder];
            [tempPlaceHolders addObject:placeHolder];
        }
    }];
    NSString *html = [tempAttr rz_codingToCompleteHtml];
    NSInteger index = 0;
    for (NSInteger i = tempPlaceHolders.count - 1; i >= 0; i--) {
        NSString *placeholder = tempPlaceHolders[i];
        NSString *url = index < urls.count? urls[index]:@"";
        NSString *img = [NSString stringWithFormat:@"<img style=\"max-width:98%%;height:auto;\" src=\"%@\" alt=\"图片缺失\">", url];
        index++; 
        html = [html stringByReplacingOccurrencesOfString:placeholder withString:img];
    }
    return html;
}

- (NSString *)rz_codingToCompleteHtml {
    NSDictionary *exportParams = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSData *htmlData = [self dataFromRange:NSMakeRange(0, self.length) documentAttributes:exportParams error:nil];
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"pt;" withString:@"px;"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"pt}" withString:@"px}"];
    return htmlString;
}
@end

#pragma clang diagnostic pop
