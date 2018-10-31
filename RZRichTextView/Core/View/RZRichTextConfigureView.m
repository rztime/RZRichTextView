//
//  RZRichTextConfigureView.m
//  RZRichTextView
//
//  Created by Admin on 2018/10/29.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichTextConfigureView.h"
#import "RZRichSelectionCell.h"
#import "RZRichTextViewModel.h"
#import "RZColoseKeyBoardView.h"
#import <Masonry/Masonry.h>

#import "RZFontConfigureView.h"
#import "RZAlignConfigureView.h"

@interface RZRichTextConfigureView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) RZColoseKeyBoardView *closeKeyboard;
@end

@implementation RZRichTextConfigureView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (RZRichTextViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[RZRichTextViewModel alloc] init];
        kWeakSelf;
        _viewModel.rz_insertImage = ^(UIImage *image) {
            if (weakSelf.rz_insertImage) {
                weakSelf.rz_insertImage(image);
            }
            
            UIView *view = [weakSelf viewWithTag:1024];
            [view removeFromSuperview];
            weakSelf.viewModel.hadShowFontView = NO;
            
            UIView *view1 = [weakSelf viewWithTag:2048];
            [view1 removeFromSuperview];
            weakSelf.viewModel.hadShowAlignView = NO;
            return ;
        };
        _viewModel.rz_changeRich = ^(BOOL changed) {
            if (weakSelf.rz_changeRich) {
                weakSelf.rz_changeRich(changed);
            }
            [weakSelf.collectionView reloadData];
            
            UIView *view = [weakSelf viewWithTag:1024];
            [view removeFromSuperview];
            weakSelf.viewModel.hadShowFontView = NO;
            
            UIView *view1 = [weakSelf viewWithTag:2048];
            [view1 removeFromSuperview];
            weakSelf.viewModel.hadShowAlignView = NO;
            return ;
        };
        
        _viewModel.rz_showFontView = ^(CGFloat starX, BOOL hide) {
            if (hide) {
                UIView *view = [weakSelf viewWithTag:1024];
                [view removeFromSuperview];
                weakSelf.viewModel.hadShowFontView = NO;
                return ;
            }
            if (!weakSelf.viewModel.hadShowFontView) {
                CGRect showViewFrame = [weakSelf convertRect:weakSelf.bounds toView:[UIApplication sharedApplication].keyWindow];
                CGFloat height = CGRectGetMaxY(showViewFrame);
                CGRect frame = CGRectMake(0, -height + 44, UIScreen.mainScreen.bounds.size.width, height);
                RZFontConfigureView *view = [[RZFontConfigureView alloc] initWithFrame:frame viewModel:weakSelf.viewModel locationX:starX];
                view.tag = 1024;
                [weakSelf addSubview:view];
            } else {
                UIView *view = [weakSelf viewWithTag:1024];
                [view removeFromSuperview];
            }
            weakSelf.viewModel.hadShowFontView = !weakSelf.viewModel.hadShowFontView; 
        };
        
        _viewModel.rz_showAlignView = ^(CGFloat starX, BOOL hide) {
            if (hide) {
                UIView *view = [weakSelf viewWithTag:2048];
                [view removeFromSuperview];
                weakSelf.viewModel.hadShowAlignView = NO;
                return ;
            }
            if (!weakSelf.viewModel.hadShowAlignView) {
                CGRect showViewFrame = [weakSelf convertRect:weakSelf.bounds toView:[UIApplication sharedApplication].keyWindow];
                CGFloat height = CGRectGetMaxY(showViewFrame);
                CGRect frame = CGRectMake(0, -height + 44, UIScreen.mainScreen.bounds.size.width, height);
                RZAlignConfigureView *view = [[RZAlignConfigureView alloc] initWithFrame:frame viewModel:weakSelf.viewModel locationX:starX];
                view.tag = 2048;
                [weakSelf addSubview:view];
            } else {
                UIView *view = [weakSelf viewWithTag:2048];
                [view removeFromSuperview];
            }
            weakSelf.viewModel.hadShowAlignView = !weakSelf.viewModel.hadShowAlignView;
        };
    }
    return _viewModel;
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint myPoint = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, myPoint)) {
                return subView;
            }
        }
    }
    return view;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return YES;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.masksToBounds = NO;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(44, 44);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [self addSubview:_collectionView];
        _collectionView.backgroundColor = [UIColor whiteColor];
        __weak typeof(self) weakSelf = self;
        [self.viewModel.dataSource enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [weakSelf.collectionView registerClass:[NSClassFromString(obj) class] forCellWithReuseIdentifier:obj];
        }];
        
        self.closeKeyboard = [[RZColoseKeyBoardView alloc]init];
        [self addSubview:self.closeKeyboard];
        [self.closeKeyboard mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.bottom.equalTo(self.collectionView);
            make.height.width.equalTo(@44);
        }];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.equalTo(self);
            make.right.equalTo(self.closeKeyboard.mas_left);
            make.height.equalTo(@44);
        }]; 
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewModel.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellName = self.viewModel.dataSource[indexPath.row];
    RZRichSelectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellName forIndexPath:indexPath];
    cell.viewModel = self.viewModel;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    RZRichSelcectionItem *item = self.viewModel.dataSource[indexPath.row];
//    item.hightLight = !item.hightLight;
//    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

@end
