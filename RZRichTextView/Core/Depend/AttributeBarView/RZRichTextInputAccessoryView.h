//
//  RZRichTextInputAccessoryView.h
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/22.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZRichTextAttributeItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface RZRichTextInputAccessoryView : UIView

- (void)reloadData;

@property (nonatomic, copy) NSMutableArray <RZRichTextAttributeItem *> *rz_attributeItems;

@property (nonatomic, copy) UICollectionViewCell *(^cellForItemAtIndePath)(UICollectionView *collectionView, NSIndexPath *indexPath, RZRichTextAttributeItem *item);

@property (nonatomic, copy) void(^didClcikedAttrItemIndex)(NSInteger index);

@end

NS_ASSUME_NONNULL_END
