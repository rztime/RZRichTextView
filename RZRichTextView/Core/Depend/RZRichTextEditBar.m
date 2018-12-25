//
//  RZRichTextEditBar.m
//  RZRichTextView
//
//  Created by Admin on 2018/12/14.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichTextEditBar.h" 
#import "RZRichItemCell.h"
#import <Masonry/Masonry.h>
#import "UIView+RZFrame.h"
#import <TZImagePickerController/TZImagePickerController.h>

@interface RZRichTextEditBar ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UIButton *closeItemBtn;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) CGFloat keyBoardHeight;

@property (nonatomic, weak) UIView *tempView;

@end

@implementation RZRichTextEditBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setViewModel:(RZRichTextViewModel *)viewModel {
    _viewModel = viewModel;
    __weak typeof(self) weakSelf = self;
    _viewModel.rz_didEditBarclickedShowExView = ^(UIView * _Nonnull view) {
        [weakSelf.tempView removeFromSuperview];
        if (view) {
            view.y = 44;
            ((UIScrollView *)view).contentSize = CGSizeMake(0, view.height);
            CGFloat height = MIN([UIScreen mainScreen].bounds.size.height - weakSelf.keyBoardHeight - 88 - 44, view.height);
            view.height = MAX(height, 88);
            weakSelf.height = view.height + 44;
            
            [weakSelf addSubview:view];
            
            weakSelf.closeItemBtn.hidden = NO;
            [UIView animateWithDuration:0.3 animations:^{
                [weakSelf.closeItemBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@44);
                }];
                weakSelf.frame = CGRectMake(0, -weakSelf.height + 44, [UIScreen mainScreen].bounds.size.width, weakSelf.height);
                
            } completion:^(BOOL finished) { }];
            weakSelf.tempView = view;
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                [weakSelf.closeItemBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@0);
                }];
                weakSelf.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
            } completion:^(BOOL finished) { weakSelf.closeItemBtn.hidden = YES;}];
        }
    };
    
    _viewModel.rz_valueChangedRefreshEditBar = ^(BOOL refresh) {
        if (refresh) {
            [weakSelf.collectionView reloadData];
        }
    };
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.9];
        [self closeBtn];
        [self closeItemBtn];
        [self collectionView];
        
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.equalTo(self);
            make.width.height.equalTo(@44);
        }];
        
        [self.closeItemBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.closeBtn);
            make.right.equalTo(self.closeBtn.mas_left);
            make.width.equalTo(@0);
        }];
        self.closeItemBtn.hidden = YES;
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self);
            make.height.equalTo(@44);
            make.right.equalTo(self.closeItemBtn.mas_left);
        }];
        
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
        [_closeBtn setImage:[UIImage imageNamed:@"RZRichResource.bundle/关闭键盘"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeKeyboard) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}
- (UIButton *)closeItemBtn {
    if (!_closeItemBtn) {
        _closeItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_closeItemBtn];
        [_closeItemBtn setImage:[UIImage imageNamed:@"RZRichResource.bundle/收起"] forState:UIControlStateNormal];
        [_closeItemBtn addTarget:self action:@selector(closeItemKeyboard) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeItemBtn;
}

- (void)closeKeyboard {
    if (self.viewModel.rz_didEditBarClicked) {
        self.viewModel.rz_didEditBarClicked(RZRichTextFunc_closeKeyboard);
    }
}
- (void)closeItemKeyboard {
    if (self.viewModel.rz_didEditBarClicked) {
        self.viewModel.rz_didEditBarClicked(RZRichTextFunc_closeEXItemView);
    }
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
        [_collectionView registerClass:[RZRichItemCell class] forCellWithReuseIdentifier:@"cell"];
        _collectionView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    }
    return _collectionView;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewModel.editBarSource.count;
};

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RZRichItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    RZRichTextFunc func = [self.viewModel.editBarSource[indexPath.row] integerValue];
    cell.label.attributedText = [self.viewModel contentByFunc:func];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RZRichTextFunc func = [self.viewModel.editBarSource[indexPath.row] integerValue];
    if (self.viewModel.rz_didEditBarClicked) {
        self.viewModel.rz_didEditBarClicked(func);
    }
    [collectionView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    });
}

@end
