//
//  RZRictAttributeSetingViewController.h
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/22.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RZCustomerLabel : UILabel
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@end

@interface RZRictAttributeSetingViewController : UIViewController

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) RZCustomerLabel *displayLabel;

- (void)sliderValue:(CGFloat)value min:(CGFloat)min max:(CGFloat)max didSliderValueChanged:(void(^)(CGFloat value))changed complete:(void(^)(CGFloat value))complete;

- (void)color:(UIColor * __nullable)color didChanged:(void(^)(UIColor *color))coloChanged complete:(void(^)(UIColor *color))complete;

- (void)pargraph:(NSMutableParagraphStyle * __nullable)paragraph didChanged:(void(^)(NSMutableParagraphStyle *paragraph))paragraphChanged complete:(void(^)(NSMutableParagraphStyle *paragraph))complete;

- (void)shadow:(NSShadow * __nullable)shadow didChanged:(void(^)(NSShadow *shadow))shadowChanged complete:(void(^)(NSShadow *shadow))complete;

- (void)urlString:(NSAttributedString * __nullable)urlString didEditComplete:(void(^)(NSAttributedString *urlString))complete;
@end


NS_ASSUME_NONNULL_END
