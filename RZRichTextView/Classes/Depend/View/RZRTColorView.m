//
//  RZRTColorView.m
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/23.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import "RZRTColorView.h"
#import <Masonry/Masonry.h> 
#import "RZRichTextConstant.h"
#import "RZRichTextConfigureManager.h"
 
@interface RZRTColorView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger section;

@property (nonatomic, strong) UIButton *noColorBtn;

@end


@implementation RZRTColorView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.width = 40;
        if (rz_k_screen_width < 330) {
            self.width = 35;
        }
        self.row = 7;
        self.section = 3;
        
        UICollectionViewFlowLayout *layot = [[UICollectionViewFlowLayout alloc] init];
        layot.itemSize = CGSizeMake(self.width, self.width);
        layot.minimumLineSpacing = 4;
        layot.minimumInteritemSpacing = 4;
        layot.sectionInset = UIEdgeInsetsMake(4, 4, 4, 4);
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layot];
        [self addSubview:self.collectionView];
        self.collectionView.backgroundColor = RZRichTextConfigureManager.manager.keyboardColor;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.width.equalTo(@(self.width * self.row + 4 * (self.row + 1)));
            make.height.equalTo(@(self.width * self.section + 4 * (self.section + 1)));
            make.bottom.equalTo(self).offset(-10);
        }];
        [self.collectionView registerClass:[RZRTColorCell class] forCellWithReuseIdentifier:@"cell"];
        self.collectionView.layer.cornerRadius = 5;
        
        self.noColorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.noColorBtn];
        [self.noColorBtn setTitle:@"无颜色" forState:UIControlStateNormal];
        [self.noColorBtn setTitleColor:rz_rgba(153, 153, 153, 1) forState:UIControlStateNormal];
        [self.noColorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.collectionView.mas_top).offset(-10);
            make.width.equalTo(self.collectionView).offset(-8);
            make.height.equalTo(@30);
        }];
        self.noColorBtn.layer.borderWidth = 1;
        self.noColorBtn.layer.masksToBounds = YES;
        self.noColorBtn.layer.cornerRadius = 4;
        self.noColorBtn.layer.borderColor = rz_rgb(153, 153, 153).CGColor;
        [self.noColorBtn addTarget:self action:@selector(noColorBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.row * self.section;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RZRTColorCell *cell = (RZRTColorCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UIColor *color = [self colorByIndex:indexPath.row];
    cell.imageView.backgroundColor = color;
    BOOL equal = CGColorEqualToColor(self.color.CGColor, color.CGColor);
    if (equal) {
        cell.borderView.layer.borderWidth = 3;
    } else {
        cell.borderView.layer.borderWidth = 0;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.color = [self colorByIndex:indexPath.row];
    if (self.didSelectedColor) {
        self.didSelectedColor(self.color);
    }
    [collectionView reloadData];
}
- (void)noColorBtnClicked:(UIButton *)sender {
    self.color = [UIColor clearColor];
    if (self.didSelectedColor) {
        self.didSelectedColor(self.color);
    }
}

- (UIColor *)colorByIndex:(NSInteger)index {
    NSArray *colors =
    @[
      @[@0, @0 , @0], @[@51, @51, @51], @[@102, @102, @102], @[@153, @153, @153], @[@204, @204, @204], @[@238, @238, @238], @[@255, @255, @255],
      @[@130, @60, @20], @[@252, @13, @27], @[@251, @104, @104], @[@255, @127, @34], @[@255, @209, @103], @[@255, @255, @59], @[@230, @250, @74],
      @[@84, @128, @57], @[@41, @255, @49], @[@109, @249 , @127], @[@11, @36, @246], @[@55, @157, @255], @[@153, @38, @255], @[@120, @100, @200]
    ];
    NSArray *color = colors[index];
    return rz_rgba([color[0] integerValue], [color[1] integerValue], [color[2] integerValue], 1);
}

- (CGFloat)viewHeight {
    return self.width * self.section + 4 * (self.section + 1) + 20 + 30 + 20;
}

@end


@implementation RZRTColorCell

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
            make.edges.equalTo(self.contentView);
        }];
        _imageView.layer.masksToBounds = true;
        _imageView.layer.borderWidth = 0.5;
        _imageView.layer.borderColor = rz_rgba(0, 0, 0, 0.2).CGColor;
    }
    return _imageView;
}

- (UIButton *)borderView {
    if (!_borderView) {
        _borderView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_borderView];
        [_borderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
            make.edges.equalTo(self.contentView).inset(3);
        }];
        _borderView.userInteractionEnabled = NO;
        _borderView.layer.masksToBounds = true;
        _borderView.layer.borderWidth = 0;
        _borderView.layer.borderColor = UIColor.whiteColor.CGColor;
    }
    return _borderView;
}

-(void)layoutSubviews {
    _imageView.layer.cornerRadius = self.contentView.bounds.size.width / 2.0;
    _borderView.layer.cornerRadius = (self.contentView.bounds.size.width -6 )/ 2.0;
}
@end

