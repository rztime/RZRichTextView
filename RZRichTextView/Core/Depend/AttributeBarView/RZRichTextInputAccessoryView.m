//
//  RZRichTextInputAccessoryView.m
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/22.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import "RZRichTextInputAccessoryView.h"
#import <Masonry/Masonry.h>
#import "RZRichTextInputAVCell.h"
#import "RZRichTextConfigureManager.h"
#import "RZRichTextInputFontColorCell.h"
#import "RZRichTextInputFontBgColorCell.h"

@interface RZRichTextInputAccessoryView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) CGFloat keyBoardHeight;

@property (nonatomic, weak) UIView *tempView;

@end

@implementation RZRichTextInputAccessoryView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self closeBtn];
        [self collectionView];
        
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.equalTo(self);
            make.width.height.equalTo(@44);
        }];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self);
            make.height.equalTo(@44);
            make.right.equalTo(self.closeBtn.mas_left);
        }];
        
        [self registerClass:[RZRichTextInputAVCell class] forAccessoryItemCellWithIdentifier:@"defCell"];
        [self registerClass:[RZRichTextInputFontColorCell class] forAccessoryItemCellWithIdentifier:@"def1Cell"];
        [self registerClass:[RZRichTextInputFontBgColorCell class] forAccessoryItemCellWithIdentifier:@"def2Cell"];

        // 将自定义的加入
        NSDictionary *dict = [RZRichTextConfigureManager manager].registerCells.copy;
        for (NSString *key in dict.allKeys) {
            [self registerClass:dict[key] forAccessoryItemCellWithIdentifier:key];
        }

        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeItemKeyboard) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardInfo:) name:UIKeyboardDidChangeFrameNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_closeBtn];
        [_closeBtn setImage:k_rz_richImage(@"rz_jp_c") forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeKeyboard) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}
// 关闭键盘
- (void)closeKeyboard {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

- (void)closeItemKeyboard {
    
}
- (void)keyboardInfo:(NSNotification *)notification {
    NSValue *value = notification.userInfo[@"UIKeyboardFrameEndUserInfoKey"];
    CGRect frame = value.CGRectValue;
    self.keyBoardHeight = frame.size.height - 44; // 工具条还有44的高度需要减去
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = CGSizeMake(44, 44);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 300, 44) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [self addSubview:_collectionView];
        _collectionView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    }
    return _collectionView;
}

- (void)registerClass:(Class)class forAccessoryItemCellWithIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:class forCellWithReuseIdentifier:identifier];
}

- (void)reloadData {
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.rz_attributeItems.count;
};

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath { 
    RZRichTextAttributeItem *item = self.rz_attributeItems[indexPath.row];
    if (self.cellForItemAtIndePath) {
        UICollectionViewCell *cell = self.cellForItemAtIndePath(collectionView, indexPath, item);
        if (cell) {
            return cell;
        }
    }
    
    if (RZRichTextConfigureManager.manager.cellForItemAtIndePath) {
        UICollectionViewCell *cell = RZRichTextConfigureManager.manager.cellForItemAtIndePath(collectionView, indexPath, item);
        if (cell) {
            return cell;
        }
    }
    UIColor *color = item.exParams[@"color"];
    if (item.type == RZRichTextAttributeTypeFontColor || item.type == RZRichTextAttributeTypeStroke) {
        RZRichTextInputFontColorCell  *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"def1Cell" forIndexPath:indexPath];
        cell.imageView.image = item.displayImage;
        cell.colorImageView.backgroundColor = color;
        return cell;
    } else if (item.type == RZRichTextAttributeTypeFontBackgroundColor) {
        RZRichTextInputFontBgColorCell  *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"def2Cell" forIndexPath:indexPath];
        cell.imageView.image = item.displayImage;
        cell.colorImageView.backgroundColor = color;
        return cell;
    } else {
        RZRichTextInputAVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"defCell" forIndexPath:indexPath];
        cell.imageView.image = item.displayImage;
        return cell;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didClcikedAttrItemIndex) {
        self.didClcikedAttrItemIndex(indexPath.row);
    }
}

@end
