//
//  RZRichItemView.m
//  RZRichTextView
//
//  Created by Admin on 2018/12/19.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichItemView.h"
#import "RZRichItemCell.h"
#import <Masonry/Masonry.h>
#import <RZColorful/RZColorful.h>
#import "RZRichItemConfigure.h"

#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define kgray RGBA(102,102,102,1)
#define kblue RGBA(37,119,239,1)
#define kbluea RGBA(37,119,239,0.4)
@interface RZRichItemView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger hightLightIndex;

@property (nonatomic, strong) UISwitch *switchBtn;

@end

@implementation RZRichItemView

+ (instancetype)initWithNumber:(CGFloat)number type:(RZRichItemViewType)type title:(NSString *)title complete:(RZRichItemComplete)complete {
    RZRichItemView *view = [[RZRichItemView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 88)];
    view.type = type;
    view.number = number;
    NSInteger index = 0;
    switch (type) {
        case RZRichItemViewType_fontSize: {
            index = [RZRichItemConfigure indexByFontSize:number];
            break;
        }
        case RZRichItemViewType_stroke:
        case RZRichItemViewType_expansion:
        case RZRichItemViewType_shadow:
        case RZRichItemViewType_shadowRadius: {
            index = [RZRichItemConfigure indexBynumber:number];
            break ;
        }
        default:
            break;
    }
    
    view.hightLightIndex = index;
    view.complete = complete;
    view.title = title;
    [view refreshLabel];
    dispatch_async(dispatch_get_main_queue(), ^{
        [view.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    });
    return view;
}

+ (instancetype)initWithColor:(UIColor *)color type:(RZRichItemViewType)type title:(NSString *)title complete:(RZRichItemComplete)complete {
    RZRichItemView *view = [[RZRichItemView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 88)];
    view.type = type;
    view.color = color;
    NSInteger index = [RZRichItemConfigure indexByColor:color];
    view.hightLightIndex = index;
    view.complete = complete;
    view.title = title;
    [view refreshLabel];
    dispatch_async(dispatch_get_main_queue(), ^{
        [view.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    });
    return view;
}

+ (instancetype)initWithAligment:(NSTextAlignment)aligment title:(NSString *)title complete:(RZRichItemComplete)complete {
    RZRichItemView *view = [[RZRichItemView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 88)];
    view.type = RZRichItemViewType_textAligment; 
    NSInteger index = [RZRichItemConfigure indexByAligment:aligment];
    view.hightLightIndex = index;
    view.complete = complete;
    view.title = title;
    [view refreshLabel];
    dispatch_async(dispatch_get_main_queue(), ^{
        [view.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    });
    return view;
}

+ (instancetype)initWithFuncEnable:(BOOL)enable title:(NSString *)title complete:(RZRichItemComplete)complete {
    RZRichItemView *view = [[RZRichItemView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 88)];
    view.complete = complete;
    view.title = title;
    [view refreshLabel];
    view.switchBtn.on = enable;
    
    return view;
}

- (void)refreshLabel {
    [self.label rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
        confer.text(self.title).font([UIFont systemFontOfSize:17]).textColor(RGBA(51, 51, 51, 1));
        switch (self.type) {
            case RZRichItemViewType_textColor:
            case RZRichItemViewType_textBgColor: {
                confer.text(@"  当前为：").font([UIFont systemFontOfSize:14]).textColor(RGBA(221, 51, 51, 1));
                if (self.color) {
                    confer.text(@"口").textColor(self.color).backgroundColor(self.color);
                } else {
                    confer.text(@"无").textColor(RGBA(221, 51, 51, 1));
                }
                break;
            }
            case RZRichItemViewType_fontSize:
            case RZRichItemViewType_stroke:
            case RZRichItemViewType_expansion:
            case RZRichItemViewType_shadow:
            case RZRichItemViewType_shadowRadius: {
                confer.text([NSString stringWithFormat:@" (当前为%@)", @(self.number)]).textColor(RGBA(221, 51, 51, 1)).font([UIFont systemFontOfSize:14]);
                break;
            }
            default:
                break;
        }
    }];
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        [self addSubview:_label];
        _label.font = [UIFont systemFontOfSize:15];
        _label.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
        _label.numberOfLines = 0;
        _label.textAlignment = NSTextAlignmentCenter;
        [_label setAdjustsFontSizeToFitWidth:YES];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.equalTo(@44);
            make.width.equalTo(@([UIScreen mainScreen].bounds.size.width));
        }];
    }
    return _label;
}

- (UISwitch *)switchBtn {
    if (!_switchBtn) {
        _switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        [self addSubview:_switchBtn];
    
        [_switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
            make.left.mas_greaterThanOrEqualTo(self);
            make.right.mas_lessThanOrEqualTo(self);
            make.centerX.equalTo(self);
            make.top.equalTo(self.label.mas_bottom);
            make.height.equalTo(@44);
        }];
        [_switchBtn addTarget:self action:@selector(funcStatus:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchBtn;
}

- (void)funcStatus:(UISwitch *)sender {
    NSNumber *value = [NSNumber numberWithBool:sender.on];
    if (self.complete) {
        self.complete(value);
    }
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
        
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
            make.left.mas_greaterThanOrEqualTo(self);
            make.right.mas_lessThanOrEqualTo(self);
            make.centerX.equalTo(self);
            make.top.equalTo(self.label.mas_bottom);
            make.height.equalTo(@44);
            if (self.type == RZRichItemViewType_textAligment) {
                make.width.equalTo(@132);
            }
        }];
    }
    return _collectionView;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (self.type) {
        case RZRichItemViewType_fontSize: {
            return [RZRichItemConfigure fontSizeCount];
        }
        case RZRichItemViewType_textColor: {
            return [RZRichItemConfigure colorCount];
        }
        case RZRichItemViewType_textBgColor: {
            return [RZRichItemConfigure colorCount] + 1;
        }
        case RZRichItemViewType_textAligment: {
            return [RZRichItemConfigure aligmentCount];
        }
        case RZRichItemViewType_stroke:
        case RZRichItemViewType_expansion:
        case RZRichItemViewType_shadow:
        case RZRichItemViewType_shadowRadius: {
            return [RZRichItemConfigure numberCount];
        }
        default:
            break;
    }
    return 0;
};

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RZRichItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    switch (self.type) {
        case RZRichItemViewType_fontSize: {
            [cell.label rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
                NSNumber *font = [RZRichItemConfigure fontSizeByIndex:indexPath.row];
                confer.text([NSString stringWithFormat:@"%@",font]).font([UIFont systemFontOfSize:15]).textColor(indexPath.row == self.hightLightIndex? kblue:kgray);
            }];
            break;
        }
        case RZRichItemViewType_textColor: {
            cell.imageView.backgroundColor = [RZRichItemConfigure colorByIndex:indexPath.row];
            cell.contentView.backgroundColor = self.hightLightIndex == indexPath.row? kbluea : nil;
            break;
        }case RZRichItemViewType_textBgColor: {
            if (indexPath.row == 0) {
                cell.label.text = @"无";
                cell.label.hidden = NO;
                cell.imageView.hidden = YES;
            } else {
                cell.imageView.backgroundColor = [RZRichItemConfigure colorByIndex:indexPath.row -1];
                cell.label.hidden = YES;
                cell.imageView.hidden = NO;
            }
            cell.contentView.backgroundColor = self.hightLightIndex == indexPath.row? kbluea : nil;
            break;
        }
        case RZRichItemViewType_textAligment: {
            cell.imageView.layer.borderWidth = 0;
            cell.imageView.image = [RZRichItemConfigure aligmentByIndex:indexPath.row];
            cell.contentView.backgroundColor = self.hightLightIndex == indexPath.row? kbluea : nil;
            break;
        }
        case RZRichItemViewType_stroke :
        case RZRichItemViewType_expansion:
        case RZRichItemViewType_shadow:
        case RZRichItemViewType_shadowRadius: {
            [cell.label rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
                NSInteger shadow = [RZRichItemConfigure numberByIndex:indexPath.row];
                confer.text([NSString stringWithFormat:@"%@", @(shadow)]).font([UIFont systemFontOfSize:15]).textColor(indexPath.row == self.hightLightIndex? kblue:kgray);
            }];
            break ;
        }
        default:
            break;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id value;
    switch (self.type) {
        case RZRichItemViewType_fontSize: {
            NSNumber *font = [RZRichItemConfigure fontSizeByIndex:indexPath.row];
            value = font;
            self.number = font.integerValue;
            break;
        }
        case RZRichItemViewType_textColor: {
            value = [RZRichItemConfigure colorByIndex:indexPath.row];
            self.color = value;
            break;
        }
        case RZRichItemViewType_textBgColor: {
            if (indexPath.row == 0) {
                value = nil;
            } else {
                value = [RZRichItemConfigure colorByIndex:indexPath.row - 1];
            }
            self.color = value;
            break;
        }
        case RZRichItemViewType_textAligment: {
            value = @(indexPath.row);
            self.aligment = indexPath.row;
            break;
        }
        case RZRichItemViewType_stroke:
        case RZRichItemViewType_expansion:
        case RZRichItemViewType_shadow:
        case RZRichItemViewType_shadowRadius: {
            NSInteger shadow = [RZRichItemConfigure numberByIndex:indexPath.row];
            value = @(shadow);
            self.number = shadow;
            break;
        }
        default:
            break;
    }
    if (self.complete) {
        self.complete(value);
    }
    self.hightLightIndex = indexPath.row;
    [self refreshLabel];
    [collectionView reloadData];
}
@end
