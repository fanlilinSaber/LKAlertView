//
//  PayAffirmView.m
//  LKAlertView IOS Example
//
//  Created by Fan Li Lin on 2022/12/2.
//

#import "PayAffirmView.h"
#import <Masonry/Masonry.h>

@interface TitleView : UIView
/// <##>
@property (nonatomic, strong) UILabel *titleLabel;
/// <##>
@property (nonatomic, strong) UILabel *valueLabel;
@end

@implementation TitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.valueLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.bottom.mas_equalTo(0);
        }];
        [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.top.bottom.mas_equalTo(0);
        }];
    }
    return self;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = UILabel.new;
        _titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        _titleLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
    }
    return _titleLabel;
}

- (UILabel *)valueLabel
{
    if (_valueLabel == nil) {
        _valueLabel = UILabel.new;
        _valueLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        _valueLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    }
    return _valueLabel;
}

@end



@interface PayAffirmView () <UITextFieldDelegate>
/// <##>
@property (nonatomic, strong) NSMutableArray *textFields;
@end

@implementation PayAffirmView

//View初始化
#pragma mark - view init

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _textFields = NSMutableArray.array;
        NSArray *titles = @[@"本次支付金额", @"本次支付手续费", @"本次支付合计金额"];
        NSArray *valus = @[@"¥1000", @"¥2", @"¥100022"];
        
        UIView *topContentView = UIView.new;
        [self addSubview:topContentView];
        
        [topContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
        }];
        
        NSMutableArray *array = NSMutableArray.array;
        for (int i = 0; i < titles.count; i ++) {
            TitleView *view = TitleView.new;
            view.titleLabel.text = titles[i];
            view.valueLabel.text = valus[i];
            [topContentView addSubview:view];
            [array addObject:view];
        }
        
        [array mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:10 leadSpacing:0 tailSpacing:0];
        [array mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
        }];
        
        UILabel *titleLabel = UILabel.new;
        titleLabel.text = @"请输入支付密码进行确认支付";
        titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
        titleLabel.textColor = [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0];
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(topContentView.mas_bottom).offset(15);
            make.centerX.mas_equalTo(0);
        }];
        
        UIStackView *bottomContentView = UIStackView.new;
        bottomContentView.backgroundColor = [UIColor colorWithRed:222/255.0 green:223/255.0 blue:224/255.0 alpha:1.0];;
        bottomContentView.axis = UILayoutConstraintAxisHorizontal;
        bottomContentView.distribution = UIStackViewDistributionFillEqually;
//        bottomContentView.LK_separatorColor = [UIColor colorWithRed:222/255.0 green:223/255.0 blue:224/255.0 alpha:1.0];
        bottomContentView.spacing = 2 / [UIScreen mainScreen].scale;
        bottomContentView.layer.borderColor = [UIColor colorWithRed:222/255.0 green:223/255.0 blue:224/255.0 alpha:1.0].CGColor;
        bottomContentView.layer.borderWidth = 2 / [UIScreen mainScreen].scale;
        [self addSubview:bottomContentView];
        [bottomContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).offset(10);
            make.centerX.mas_equalTo(0);
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.bottom.mas_equalTo(-12);
            make.height.mas_equalTo(40);
        }];
        
        for (int i = 0; i < 6; i ++) {
            UITextField *textField = UITextField.new;
            textField.backgroundColor = UIColor.whiteColor;
            textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 40)];
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.leftViewMode = UITextFieldViewModeAlways;
            textField.delegate = self;
            [bottomContentView addArrangedSubview:textField];
            [self.textFields addObject:textField];
        }
    }
    return self;
}

//View的配置、布局设置
#pragma mark - view config

- (void)addSubviews {}

- (void)layoutPageSubviews {}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChangeSelection:(UITextField *)textField
{
    if (textField.text.length > 0) {
        textField.text = [textField.text substringWithRange:NSMakeRange(0, 1)];
        NSInteger index = [self.textFields indexOfObject:textField];
        if (index + 1 >= self.textFields.count) {
            [textField resignFirstResponder];
            return;
        }
        UITextField *nextTextField = self.textFields[index + 1];
        [nextTextField becomeFirstResponder];
    }
}

//私有方法
#pragma mark - private method

//View的生命周期
#pragma mark - view life

//更新View的接口
#pragma mark - update view

//处理View的事件
#pragma mark - handle view event

//发送View的事件
#pragma mark - send view event

//公有方法
#pragma mark - public method

//Setters方法
#pragma mark - setters

//Getters方法
#pragma mark - getters

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
