//
//  RZRichAlertViewController.m
//  RZRichTextView
//
//  Created by 若醉 on 2019/6/3.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import "RZRichAlertViewController.h"
#import "RZRichAlertViewCell.h"
#import "RZRichTextConstant.h"
#import <Masonry/Masonry.h>
#import "RZRichTextConfigureManager.h"

#define OperationButtonHeight 50
#define GridCellHeight        120
#define ViewColor             [UIColor whiteColor]

@interface RZRichAlertViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, assign) RZRichAlertViewType type;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UICollectionView *collertionView;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIImageView *rightImageView;

@property (nonatomic, strong) UIImageView *downImageView;
@end

@implementation RZRichAlertViewController

- (instancetype)init {
    if (self = [super init]) {
        _type = RZRichAlertViewTypeList;
        _showCancelButton = YES;
        _highLightIndex = NSNotFound;
        _highLightTextColor = rz_rgb(51,150,251);
    }
    return self;
}

- (instancetype)initWithType:(RZRichAlertViewType)type title:(NSString *)title {
    if (self = [super init]) {
        _type = type;
        _showCancelButton = YES;
        _highLightIndex = NSNotFound;
        _highLightTextColor = rz_rgb(51,150,251);
        _titleString = title;
    }
    return self;
}

- (instancetype)initWithType:(RZRichAlertViewType)type {
    return [self initWithType:type title:nil];
}
#pragma mark ----------------------------- 生命周期 ------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    self.view.frame = [UIScreen mainScreen].bounds;
    // 初始化默认数据
    [self createDefaultData];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = self.view.bounds;
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(didClickedCancel:) forControlEvents:UIControlEventTouchUpInside];
    
    // 初始化界面
    [self createUI];
    
    if (_type == RZRichAlertViewTypeGrid && _titles.count > 4) {
        self.rightImageView = [[UIImageView alloc]init];
        [self.contentView addSubview:self.rightImageView];
        [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.collertionView);
            make.right.equalTo(self.collertionView);
        }];
        self.rightImageView.image = k_rz_richImage(@"rzActionSheetMore");
    } else if (_type == RZRichAlertViewTypeList && _titles.count > 6) {
        self.downImageView = [[UIImageView alloc]init];
        [self.contentView addSubview:self.downImageView];
        [self.downImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.collertionView);
            make.bottom.equalTo(self.collertionView);
        }];
        self.downImageView.image = k_rz_richImage(@"rzActionSheetMoreD");
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showCollectionView];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideCollectionView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)dealloc {
}

#pragma mark - 初始化默认数据
- (void)createDefaultData {
    
}

- (void)showCollectionView {
    CGFloat x = 1;
    x = 0.7;
    rz_weakObj(self);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:x initialSpringVelocity:4 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        CGRect tempframe = [selfWeak.view convertRect:selfWeak.view.bounds toView:UIApplication.sharedApplication.keyWindow];    // 非全屏弹窗中，显示了此视图时，会有偏差
        selfWeak.contentView.frame = ({
            CGRect frame = selfWeak.contentView.frame;
            CGFloat bottomMargin = rz_iPhone_liuhai? rz_kSafeBottomMargin: 15;
            frame.origin.y = rz_k_screen_height - bottomMargin - frame.size.height - tempframe.origin.y;
            frame;
        });
    } completion:^(BOOL finished) {
        if (selfWeak.highLightIndex != NSNotFound && selfWeak.highLightIndex >= 0 && selfWeak.highLightIndex < selfWeak.titles.count) {
            if (selfWeak.type == RZRichAlertViewTypeList) {
                [selfWeak.collertionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:selfWeak.highLightIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
            } else {
                [selfWeak.collertionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:selfWeak.highLightIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            }
        }
    }];
}

- (void)hideCollectionView {
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.frame = ({
            CGRect frame = self.contentView.frame;
            frame.origin.y = rz_k_screen_height;
            frame;
        });
    } completion:nil];
}

#pragma mark - 初始化界面
- (void)createUI {
    CGFloat leftMargin = 0;
    //    if (iPhoneX) {
    leftMargin = 15;
    //    }
    CGFloat viewWidth = rz_k_screen_width - 2 * leftMargin;
    CGFloat viewHeight = 0;
    
    if (_titleString.length > 0) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, viewWidth, OperationButtonHeight)];
        _titleLabel.backgroundColor = ViewColor;
        _titleLabel.text = _titleString;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = _highLightTextColor;
        
        viewHeight += OperationButtonHeight;
    }
    if (_titles.count > 0) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        if (_type == RZRichAlertViewTypeGrid) { // 格子类型需要按个数排列
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            if (_titles.count == 1) {
                layout.itemSize = CGSizeMake(viewWidth, GridCellHeight);
            } else if (_titles.count == 2) {
                layout.itemSize = CGSizeMake(GridCellHeight , GridCellHeight);
                
                CGFloat text1 = 0;
                CGFloat text2 = 0;
                for (int i = 0; i < 2; i++) {
                    NSDictionary *dic = self.titles[i];
                    NSString *titlestring;
                    UIImage *image;
                    NSArray *keys = dic.allKeys;
                    for (id key in keys) {
                        id value = [dic objectForKey:key];
                        if ([value isKindOfClass:[NSString class]]) {
                            titlestring = value;
                            continue;
                        }
                        if ([value isKindOfClass:[UIImage class]]) {
                            image = value;
                            continue;
                        }
                    }
                    CGFloat textW = 0;
                    if (image) {
                        textW += image.size.width;
                    } else {
                        textW += titlestring.length * 16;
                    }
                    if (i == 0) {
                        text1 = textW;
                    } else {
                        text2 = textW;
                    }
                }
                // 左中右 之间区分 2  3  2
                CGFloat margin = (viewWidth - text1 - text2);
                // 左侧间距
                CGFloat leftMargin = margin * 2 / 7 - (GridCellHeight - text1)/2;
                // 中间间距
                CGFloat leftMargin2 = margin * 3 / 7 - (GridCellHeight - text1)/2 - (GridCellHeight - text2)/2;
                
                layout.sectionInset = UIEdgeInsetsMake(0, leftMargin, 0, 0);
                layout.minimumLineSpacing = leftMargin2;
            } else if (_titles.count == 3) {
                layout.itemSize = CGSizeMake(viewWidth / 3, GridCellHeight);
            } else {
                layout.itemSize = CGSizeMake(viewWidth / 4, GridCellHeight);
            }
        } else { // 列表模式
            layout.scrollDirection = UICollectionViewScrollDirectionVertical;
            layout.itemSize = CGSizeMake(viewWidth, OperationButtonHeight);
        }
        
        _collertionView = [[UICollectionView alloc]initWithFrame:({
            CGRect frame = CGRectMake(0, viewHeight, viewWidth, GridCellHeight);
            if (_type == RZRichAlertViewTypeList) {
                frame.size.height = MIN(OperationButtonHeight * _titles.count, OperationButtonHeight * 6);
            }
            viewHeight += frame.size.height;
            frame;
        }) collectionViewLayout:layout];
        _collertionView.backgroundColor = ViewColor;
        _collertionView.delegate = self;
        _collertionView.dataSource = self;
        _collertionView.showsVerticalScrollIndicator = NO;
        _collertionView.showsHorizontalScrollIndicator = NO;
        _collertionView.pagingEnabled = YES;
        [_collertionView registerClass:[RZRichAlertViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    
    if (_showCancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(0, viewHeight + 5, viewWidth, OperationButtonHeight);
        [_cancelButton setTitle:@"取消" forState:0];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cancelButton setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(didClickedCancel:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setBackgroundColor:ViewColor];
        viewHeight += OperationButtonHeight;
        viewHeight += 5;
    }
    
    _contentView = [[UIView alloc]initWithFrame:CGRectMake(leftMargin, rz_k_screen_height, viewWidth, viewHeight)];
    if (_titleLabel) {
        [_contentView addSubview:_titleLabel];
    }
    if (_collertionView) {
        [_contentView addSubview:_collertionView];
    }
    if (_cancelButton) {
        [_contentView addSubview:_cancelButton];
    }
    [self.view addSubview:_contentView];
    self.view.backgroundColor = rz_rgba(0, 0, 0, 0.4);
    
    //    if (iPhoneX) {
    _contentView.layer.masksToBounds = YES;
    _contentView.layer.cornerRadius = 15;
    
    if (_cancelButton) {
        _cancelButton.layer.masksToBounds = YES;
        _cancelButton.layer.cornerRadius = 15;
    }
    
    
    _collertionView.layer.masksToBounds = YES;
    _collertionView.layer.cornerRadius = 15;
    
    if (_titleLabel) {
        UIView *view = [[UIView alloc]initWithFrame:_titleLabel.frame];
        [self.contentView insertSubview:view belowSubview:_titleLabel];
        view.backgroundColor = ViewColor;
        view.frame = ({
            CGRect frame = view.frame;
            frame.origin.y = frame.size.height - 20;
            frame;
        });
    }
    //    }
}

#pragma mark ----------------------------- 其他方法 ------------------------------

#pragma mark ----------------------------- 公用方法 ------------------------------

#pragma mark ----------------------------- 网络请求 ------------------------------

#pragma mark ----------------------------- 代理方法 ------------------------------

#pragma mark --------------------------- setter&getter -------------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titles.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    RZRichAlertViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.type = self.type;
    cell.title = self.titles[indexPath.row];
    cell.hightLightTextColor = self.highLightTextColor;
    cell.hightLight = _highLightIndex == indexPath.row;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.didSelected) {
            self.didSelected(indexPath.row, NO);
        }
    }];
}

- (void)show {
    [RZRichTextConfigureManager presentViewController:self animated:YES];
}

- (void)didClickedCancel:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if(self.didSelected) {
            self.didSelected(NSNotFound, YES);
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_type == RZRichAlertViewTypeGrid && self.titles.count > 4) {
        if (scrollView.contentOffset.x + _collertionView.frame.size.width + 2 < scrollView.contentSize.width) {
            self.rightImageView.hidden = NO;
        } else {
            self.rightImageView.hidden = YES;
        }
    } else if (_type == RZRichAlertViewTypeList && self.titles.count > 6) {
        if (scrollView.contentOffset.y + _collertionView.frame.size.width  + 2 < scrollView.contentSize.height) {
            self.downImageView.hidden = NO;
        } else {
            self.downImageView.hidden = YES;
        }
    }
}
@end
