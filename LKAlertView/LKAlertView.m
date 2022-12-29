//
//  LKAlertView.m
//  LKAlertView
//
//  Created by Fan Li Lin on 2021/4/16.
//

#import "LKAlertView.h"

/// 默认的标题字体
#define LKAlertViewDefaultTitleFont [UIFont systemFontOfSize:18 weight:UIFontWeightRegular]
/// 默认的消息字体
#define LKAlertViewDefaultMessageFont [UIFont systemFontOfSize:16 weight:UIFontWeightRegular]
/// 默认的标题颜色
#define LKAlertViewDefaultTitleColor UIColor.blackColor
/// 默认的消息颜色
#define LKAlertViewDefaultMessageColor [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]

@interface LKAlertTextFieldMaker (Inner)
- (id)initWithTextField:(UITextField *)textField
            contentView:(UIView *)contentView
               mainView:(UIStackView *)mainView;
@end

@interface LKAlertStackView : UIStackView
/// 分割线颜色
@property (nonatomic, strong) UIColor *separatorColor;
@property (nonatomic, copy) NSArray *separatorViews;
@property (nonatomic) UIEdgeInsets separatorInset;
/// 弱引用对象
@property (nonatomic, strong) NSMapTable<UIView *, NSNumber *> *customSpacings;

- (void)setCustomSpacing:(CGFloat)spacing afterView:(UIView *)arrangedSubview API_AVAILABLE(ios(9.0));

- (CGFloat)customSpacingAfterView:(UIView *)arrangedSubview API_AVAILABLE(ios(9.0));

@end

@implementation LKAlertStackView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    if (@available(iOS 11.0, *)) {
        return;
    }
    
    /**
     layout constraints should like this
     
        next.top = target.bottom + spacing
        or
        next.leading = target.trailing + spacing
     */
    __block NSMutableArray<NSLayoutConstraint *> *firstContstraints = nil;
    [_customSpacings.keyEnumerator.allObjects enumerateObjectsUsingBlock:^(UIView *view, NSUInteger _, BOOL *stop) {
        if (![view.superview isEqual:self]) {
            // view is removed from self
            [_customSpacings removeObjectForKey:view];
            return;
        }
        if (firstContstraints == nil) {
            NSLayoutAttribute firstAttribute = self.axis == UILayoutConstraintAxisVertical ? NSLayoutAttributeTop : NSLayoutAttributeLeading;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.firstAttribute == %ld", firstAttribute];
            firstContstraints = [[self.constraints filteredArrayUsingPredicate:predicate] mutableCopy];
        }
        if (firstContstraints.count == 0) {
            *stop = YES; return; // break;
        }
        
        NSLayoutAttribute secondAttribute = self.axis == UILayoutConstraintAxisVertical ? NSLayoutAttributeBottom : NSLayoutAttributeTrailing;
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"SELF.secondItem == %@ AND SELF.secondAttribute == %ld", view, secondAttribute];
        NSArray<NSLayoutConstraint *> *matchedConstraints = [firstContstraints filteredArrayUsingPredicate:predicate2];
        if (matchedConstraints.count > 0) {
            matchedConstraints.firstObject.constant = [self customSpacingAfterView:view];
            [firstContstraints removeObjectsInArray:matchedConstraints];
        }
    }];
}

- (void)setCustomSpacing:(CGFloat)spacing afterView:(UIView *)view
{
    if (@available(iOS 11.0, *)) {
        [super setCustomSpacing:spacing afterView:view];
        return;
    }
    if (![self.arrangedSubviews containsObject:view]) {
        return;
    }
    [self.customSpacings setObject:@(spacing) forKey:view];
    [self setNeedsUpdateConstraints];
}

- (CGFloat)customSpacingAfterView:(UIView *)arrangedSubview
{
    if (@available(iOS 11.0, *)) {
        return [super customSpacingAfterView:arrangedSubview];
    } else {
        NSNumber *value = [self.customSpacings objectForKey:arrangedSubview];
        if (value) {
            return [value doubleValue];
        } else {
            return FLT_MAX;
        }
    }
}

- (void)removeArrangedSubview:(UIView *)view
{
    [self.customSpacings removeObjectForKey:view];
    [super removeArrangedSubview:view];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self makeSeparators];
}

- (void)makeSeparators
{
    [self.separatorViews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    self.separatorViews = nil;
    
    NSMutableArray *separatorViews = @[].mutableCopy;
    
    __block UIView *previousView = nil;
    [self.arrangedSubviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx == 0) {
            previousView = obj;
            return;
        }
        
        UIView *separatorView = [UIView new];
        separatorView.backgroundColor = self.separatorColor;
        
        if (self.axis == UILayoutConstraintAxisHorizontal) {
            
            separatorView.frame = CGRectMake(CGRectGetMaxX(previousView.frame) + self.separatorInset.left, CGRectGetMinY(previousView.frame) + self.separatorInset.top, self.spacing - self.separatorInset.left - self.separatorInset.right, CGRectGetHeight(self.frame) - self.separatorInset.top - self.separatorInset.bottom);
        } else {
            separatorView.frame = CGRectMake(CGRectGetMinX(previousView.frame) + self.separatorInset.left, CGRectGetMaxY(previousView.frame) + self.separatorInset.top, CGRectGetWidth(self.frame) - self.separatorInset.left - self.separatorInset.right, self.spacing - self.separatorInset.top - self.separatorInset.bottom);
        }
        
        [self addSubview:separatorView];
        [separatorViews addObject:separatorView];
        previousView = obj;
    } ];
    
    self.separatorViews = separatorViews.copy;
}

- (NSMapTable<UIView *,NSNumber *> *)customSpacings
{
    if (_customSpacings == nil) {
        _customSpacings = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory capacity:0];
    }
    return _customSpacings;
}

@end

@interface LKAlertAction ()
@property (nonatomic, copy) void (^handler)(LKAlertAction *);
@property (nonatomic, copy) BOOL (^canClose)(LKAlertAction *);
@property (nonatomic, assign) NSInteger setTitleColorCount;
@end

@implementation LKAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(LKAlertActionStyle)style handler:(void (^)(LKAlertAction *))handler
{
    return [self actionWithTitle:title style:style handler:handler canClose:nil];
}

+ (instancetype)actionWithTitle:(NSString *)title image:(UIImage *)image style:(LKAlertActionStyle)style
{
    return [self actionWithTitle:title image:image style:style handler:nil canClose:nil];
}

+ (instancetype)actionWithTitle:(NSString *)title
                          image:(UIImage *)image
                          style:(LKAlertActionStyle)style
                        handler:(void (^)(LKAlertAction *action))handler
{
    return [self actionWithTitle:title image:image style:style handler:handler canClose:nil];
}

+ (instancetype)actionWithTitle:(NSString *)title
                          style:(LKAlertActionStyle)style
                        handler:(void (^)(LKAlertAction *action))handler
                       canClose:(BOOL (^)(LKAlertAction *action))canClose
{
    return [self actionWithTitle:title image:nil style:style handler:handler canClose:canClose];
}

+ (instancetype)actionWithTitle:(NSString *)title
                          image:(UIImage *)image
                          style:(LKAlertActionStyle)style
                        handler:(void (^)(LKAlertAction *action))handler
                       canClose:(BOOL (^)(LKAlertAction *action))canClose
{
    LKAlertAction *action = [[LKAlertAction alloc] init];
    action.image = image;
    action.style = style;
    action.handler = handler;
    action.canClose = canClose;
    action.imagePadding = 10;
    switch (style) {
        case LKAlertActionStyleDefault:
            action.title = title ?: @"确定";
            action.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
            action.titleColor = [UIColor colorWithRed:87/255.0 green:146/255.0 blue:253/255.0 alpha:1.0];
            break;
        case LKAlertActionStyleCancel:
            action.title = title ?: @"取消";
            action.font = [UIFont systemFontOfSize:18 weight:UIFontWeightRegular];
            action.titleColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
            break;
        case LKAlertActionStyleDelete:
            action.title = title ?: @"删除";
            action.font = [UIFont systemFontOfSize:18 weight:UIFontWeightRegular];
            action.titleColor = [UIColor colorWithRed:239/255.0 green:64/255.0 blue:51/255.0 alpha:1.0];
            break;
            
        default:
            action.title = title;
            action.font = [UIFont systemFontOfSize:18 weight:UIFontWeightRegular];
            action.titleColor = [UIColor blackColor];
            break;
    }
    return action;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    _setTitleColorCount ++;
}

@end

@interface LKAlertView ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *titleContentView;
@property (nonatomic, strong) UIView *horizontalLine;
@property (nonatomic, copy) NSArray <LKAlertAction *>*alertActions;
@property (nonatomic, copy) NSArray <UITextField *> *addTextFields;
@property (nonatomic, strong) LKAlertStackView *contentStackView;
@property (nonatomic, strong) LKAlertStackView *actionsStackView;
@property (nonatomic, strong) LKAlertStackView *bottomActionsStackView;
@property (nonatomic, strong) LKAlertStackView *textFieldStackView;
@property (nonatomic, strong) LKAlertStackView *customViewStackView;
@property (nonatomic, copy) NSArray <NSAttributedString *>*attributedContents;
@property (nonatomic, assign) LKAlertViewStyle preferredStyle;
@property (nonatomic, assign) BOOL customMessage;

@property (nonatomic, strong) NSLayoutConstraint *titleContentViewConstraintBottom;
@property (nonatomic, strong) NSLayoutConstraint *titleContentViewConstraintMinimumHeight;
@property (nonatomic, strong) NSLayoutConstraint *titleContentViewConstraintHeight;
@property (nonatomic, strong) NSLayoutConstraint *titleLabelConstraintCenterY;
@property (nonatomic, strong) NSLayoutConstraint *titleLabelConstraintTop;

@property (nonatomic, strong) NSLayoutConstraint *contentStackViewConstraintTop;
@property (nonatomic, strong) NSLayoutConstraint *contentStackViewConstraintBottom;
@property (nonatomic, strong) NSLayoutConstraint *contentStackViewConstraintHeight;
@end

@implementation LKAlertView

//View初始化
#pragma mark - view init

+ (instancetype)alertViewWithTitle:(NSString *)title
                           message:(NSString *)message
                    preferredStyle:(LKAlertViewStyle)preferredStyle
{
    LKAlertView *alertView = [[LKAlertView alloc] initWithTitle:title message:message preferredStyle:preferredStyle];
    return alertView;
}

+ (instancetype)alertViewWithTitle:(NSString *)title
                attributedMessages:(NSArray<NSAttributedString *> *)messages
                    preferredStyle:(LKAlertViewStyle)preferredStyle
{
    LKAlertView *alertView = [[LKAlertView alloc] initWithTitle:title attributedMessages:messages preferredStyle:preferredStyle];
    return alertView;
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
            preferredStyle:(LKAlertViewStyle)preferredStyle
                   actions:(NSArray<LKAlertAction *> *)actions {
    
    LKAlertView *alertView = [[LKAlertView alloc] initWithTitle:title message:message preferredStyle:preferredStyle];
    [alertView addActions:actions];
    [alertView show];
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
               preferredStyle:(LKAlertViewStyle)preferredStyle
{
    if (self = [super init]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        self.customMessage = NO;
        self.title = title;
        if (message && message.length > 0) {
            self.attributedContents = @[[[NSMutableAttributedString alloc] initWithString:message attributes:@{NSFontAttributeName: LKAlertViewDefaultMessageFont,NSForegroundColorAttributeName: LKAlertViewDefaultMessageColor}].copy];
        }
        self.preferredStyle = preferredStyle;
        self.titleColor = LKAlertViewDefaultTitleColor;
        self.titleFont = LKAlertViewDefaultTitleFont;
        _message = [message copy];
        _messageColor = LKAlertViewDefaultMessageColor;
        _messageFont = LKAlertViewDefaultMessageFont;
        _messageAlignment = NSTextAlignmentCenter;
        [self addSubviews];
        [self setupAppearance];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
           attributedMessages:(NSArray <NSAttributedString *>*)messages
               preferredStyle:(LKAlertViewStyle)preferredStyle
{
    if (self = [super init]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        self.customMessage = YES;
        self.title = title;
        self.attributedContents = messages;
        self.preferredStyle = preferredStyle;
        self.titleColor = LKAlertViewDefaultTitleColor;
        self.titleFont = LKAlertViewDefaultTitleFont;
        _messageAlignment = NSTextAlignmentCenter;
        [self addSubviews];
        [self setupAppearance];
    }
    return self;
}

//View的配置、布局设置
#pragma mark - view config

- (void)addSubviews
{
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.titleContentView];
    [self.titleContentView addSubview:self.titleLabel];
    [self.containerView addSubview:self.horizontalLine];
    [self.containerView addSubview:self.contentStackView];
    [self.containerView addSubview:self.actionsStackView];
    
    [self layoutPageSubviews];
    [self updateTitleContentView];
    [self updateContentStackView];
}

- (void)layoutPageSubviews
{
    if (self.preferredStyle == LKAlertViewStyleActionSheet || self.preferredStyle == LKAlertViewStyleChooseSheet) {
        self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.containerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0].active = YES;
        [self.containerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0].active = YES;
        [self.containerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0].active = YES;
        
        self.titleContentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.titleContentView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor].active = YES;
        [self.titleContentView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor].active = YES;
        [self.titleContentView.topAnchor constraintEqualToAnchor:self.containerView.topAnchor].active = YES;
        self.titleContentViewConstraintBottom = [self.titleContentView.bottomAnchor constraintEqualToAnchor:self.contentStackView.bottomAnchor constant:10];
        self.titleContentViewConstraintBottom.active = YES;
        self.titleContentViewConstraintMinimumHeight = [self.titleContentView.heightAnchor constraintGreaterThanOrEqualToConstant:49];
        self.titleContentViewConstraintMinimumHeight.active = YES;
        self.titleContentViewConstraintHeight = [self.titleContentView.heightAnchor constraintEqualToConstant:0];
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.titleContentView.centerXAnchor].active = YES;
        self.titleLabelConstraintCenterY = [self.titleLabel.centerYAnchor constraintEqualToAnchor:self.titleContentView.centerYAnchor];
        self.titleLabelConstraintTop = [self.titleLabel.topAnchor constraintEqualToAnchor:self.containerView.topAnchor constant:14];
        
        self.contentStackView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentStackView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:15].active = YES;
        [self.contentStackView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-15].active = YES;
        self.contentStackViewConstraintTop = [self.contentStackView.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:12];
        self.contentStackViewConstraintTop.active = YES;
        
        self.horizontalLine.translatesAutoresizingMaskIntoConstraints = NO;
        [self.horizontalLine.topAnchor constraintEqualToAnchor:self.titleContentView.bottomAnchor].active = YES;
        [self.horizontalLine.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor].active = YES;
        [self.horizontalLine.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor].active = YES;
        [self.horizontalLine.heightAnchor constraintEqualToConstant:2 / [UIScreen mainScreen].scale].active = YES;
        [self.horizontalLine.bottomAnchor constraintEqualToAnchor:self.actionsStackView.topAnchor constant:0].active = YES;
        
        self.actionsStackView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.actionsStackView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor].active = YES;
        [self.actionsStackView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor].active = YES;
        NSLayoutConstraint *actionsStackViewBottom = [self.actionsStackView.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor];
        actionsStackViewBottom.active = YES;
        actionsStackViewBottom.priority = 900;
    } else {
        self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.containerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:52].active = YES;
        [self.containerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-52].active = YES;
        [self.containerView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        
        self.titleContentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.titleContentView.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor].active = YES;
        [self.titleContentView.trailingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor].active = YES;
        [self.titleContentView.topAnchor constraintEqualToAnchor:self.titleLabel.topAnchor].active = YES;
        [self.titleContentView.bottomAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor].active = YES;
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:30].active = YES;
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-30].active = YES;
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.containerView.topAnchor constant:22].active = YES;
        
        self.contentStackView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentStackView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:15].active = YES;
        [self.contentStackView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-15].active = YES;
        self.contentStackViewConstraintHeight = [self.contentStackView.heightAnchor constraintGreaterThanOrEqualToConstant:38];
        self.contentStackViewConstraintHeight.active = YES;
        self.contentStackViewConstraintTop = [self.contentStackView.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:16];
        self.contentStackViewConstraintTop.active = YES;
        self.contentStackViewConstraintBottom = [self.contentStackView.bottomAnchor constraintEqualToAnchor:self.horizontalLine.topAnchor constant:-16];
        self.contentStackViewConstraintBottom.active = YES;
        
        self.horizontalLine.translatesAutoresizingMaskIntoConstraints = NO;
        [self.horizontalLine.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor].active = YES;
        [self.horizontalLine.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor].active = YES;
        [self.horizontalLine.heightAnchor constraintEqualToConstant:2 / [UIScreen mainScreen].scale].active = YES;
        [self.horizontalLine.bottomAnchor constraintEqualToAnchor:self.actionsStackView.topAnchor constant:0].active = YES;
        
        self.actionsStackView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.actionsStackView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor].active = YES;
        [self.actionsStackView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor].active = YES;
        [self.actionsStackView.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor].active = YES;
    }
}

//私有方法
#pragma mark - private method

- (void)setupAppearance
{
    if (self.preferredStyle == LKAlertViewStyleActionSheet || self.preferredStyle == LKAlertViewStyleChooseSheet) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.numberOfLines = 0;
        self.titleContentView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
        self.titleLabel.textColor = [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0];
        self.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        self.containerView.layer.cornerRadius = 0;
        self.containerView.layer.masksToBounds = YES;
        self.containerView.backgroundColor = UIColor.whiteColor;
        self.actionsStackView.separatorColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0];
        self.horizontalLine.hidden = YES;
    } else {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.backgroundColor = UIColor.clearColor;
        self.titleLabel.textColor = UIColor.blackColor;
        self.containerView.layer.cornerRadius = 14;
        self.containerView.layer.masksToBounds = YES;
        self.containerView.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.95];
        self.actionsStackView.separatorColor = [UIColor colorWithRed:222/255.0 green:223/255.0 blue:224/255.0 alpha:1.0];
        self.horizontalLine.hidden = NO;
    }
}

- (void)updateAttributedContents
{
    if (self.message) {
        NSMutableDictionary *attributes = @{}.mutableCopy;
        [attributes setValue:self.messageFont forKey:NSFontAttributeName];
        [attributes setValue:self.messageColor forKey:NSForegroundColorAttributeName];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.message attributes:attributes];
        self.attributedContents = @[attributedString.copy];
    }
}

- (void)setupButtonLayout:(UIButton *)button actionStyle:(LKAlertActionStyle)style imagePadding:(CGFloat)imagePadding
{
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [button.imageView sizeToFit];
    [button.titleLabel sizeToFit];
    
    CGFloat image_w = button.imageView.image.size.width;
    CGFloat title_w = button.titleLabel.intrinsicContentSize.width;
    
    UIEdgeInsets imageEdge = UIEdgeInsetsZero;
    UIEdgeInsets titleEdge = UIEdgeInsetsZero;
    
    switch (style) {
        case LKAlertActionStyleCenterImageLeft:
            titleEdge = UIEdgeInsetsMake(0, imagePadding, 0, 0);
            imageEdge = UIEdgeInsetsMake(0, 0, 0, imagePadding);
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            break;
        case LKAlertActionStyleCenterImageRight:
            titleEdge = UIEdgeInsetsMake(0, -image_w - imagePadding, 0, image_w);
            imageEdge = UIEdgeInsetsMake(0, title_w + imagePadding, 0, -title_w);
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            break;
            
        default:
            break;
    }
    
    button.imageEdgeInsets = imageEdge;
    button.titleEdgeInsets = titleEdge;
}

- (UIButton *)createActionButton:(LKAlertAction *)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:action.title forState:UIControlStateNormal];
    [button setTitleColor:action.titleColor forState:UIControlStateNormal];
    button.titleLabel.font = action.font ?: [UIFont systemFontOfSize:18];
    button.backgroundColor = UIColor.clearColor;
    [button setImage:action.image forState:UIControlStateNormal];
    if (action.style == LKAlertActionStyleCenterImageLeft || action.style == LKAlertActionStyleCenterImageRight) {
        [self setupButtonLayout:button actionStyle:action.style imagePadding:action.imagePadding];
    }
    [button addTarget:self action:@selector(handleActionEvent:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

//View的生命周期
#pragma mark - view life

//更新View的接口
#pragma mark - update view

- (void)updateContentStackView
{
    [self.contentStackView.arrangedSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (NSAttributedString *string in self.attributedContents) {
        UILabel *label = UILabel.new;
        label.numberOfLines = 0;
        label.attributedText = string;
        label.textAlignment = self.messageAlignment;
        [self.contentStackView addArrangedSubview:label];
    }
    
    if (self.preferredStyle == LKAlertViewStyleActionSheet) {
        self.contentStackViewConstraintTop.constant = self.attributedContents.count > 0 ? 12 : 0;
    } else if (self.preferredStyle == LKAlertViewStyleChooseSheet) {
        self.contentStackViewConstraintTop.constant = self.attributedContents.count > 0 ? 12 : 0;
    } else {
        if (self.attributedContents.count > 0) {
            self.contentStackViewConstraintHeight.constant = 38;
            self.contentStackViewConstraintTop.constant = 16;
            self.contentStackViewConstraintBottom.constant = -16;
        } else {
            self.contentStackViewConstraintHeight.constant = 0;
            self.contentStackViewConstraintBottom.constant = 0;
            self.contentStackViewConstraintTop.constant = 16;
        }
    }
}

- (void)updateTitleContentView
{
    if (self.preferredStyle == LKAlertViewStyleActionSheet || self.preferredStyle == LKAlertViewStyleChooseSheet) {
        if (self.title.length > 0 && self.message.length > 0) {
            self.titleContentViewConstraintMinimumHeight.constant = 49;
            self.titleContentViewConstraintHeight.active = NO;
            self.titleLabelConstraintCenterY.active = NO;
            self.titleLabelConstraintTop.active = YES;
        } else if (self.title.length > 0) {
            self.titleContentViewConstraintMinimumHeight.constant = 49;
            self.titleContentViewConstraintHeight.active = NO;
            self.titleLabelConstraintCenterY.active = YES;
            self.titleLabelConstraintTop.active = NO;
        } else if (self.message.length > 0) {
            self.titleContentViewConstraintMinimumHeight.constant = 49;
            self.titleContentViewConstraintHeight.active = NO;
            self.titleLabelConstraintCenterY.active = NO;
            self.titleLabelConstraintTop.active = YES;
            self.titleLabelConstraintTop.constant = 0;
        } else {
            self.titleContentViewConstraintMinimumHeight.constant = 0;
            self.titleContentViewConstraintHeight.active = YES;
            self.titleContentViewConstraintHeight.constant = 0;
            self.titleLabelConstraintCenterY.active = NO;
            self.titleLabelConstraintTop.active = NO;
        }
    }
    
    /// 添加额外的按钮
    if (self.preferredStyle == LKAlertViewStyleChooseSheet) {
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setTitle:@"取消" forState:UIControlStateNormal];
        [leftButton setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] forState:UIControlStateNormal];
        leftButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setTitle:@"确定" forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor colorWithRed:87/255.0 green:146/255.0 blue:253/255.0 alpha:1.0] forState:UIControlStateNormal];
        rightButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        
        [self.titleContentView addSubview:leftButton];
        [self.titleContentView addSubview:rightButton];
        
        leftButton.translatesAutoresizingMaskIntoConstraints = NO;
        [leftButton.centerYAnchor constraintEqualToAnchor:self.titleContentView.centerYAnchor].active = YES;
        [leftButton.leftAnchor constraintEqualToAnchor:self.titleContentView.leftAnchor constant:15].active = YES;
        
        rightButton.translatesAutoresizingMaskIntoConstraints = NO;
        [rightButton.centerYAnchor constraintEqualToAnchor:self.titleContentView.centerYAnchor].active = YES;
        [rightButton.rightAnchor constraintEqualToAnchor:self.titleContentView.rightAnchor constant:-15].active = YES;
    }
}

//处理View的事件
#pragma mark - handle view event

- (void)handleActionEvent:(UIButton *)sender
{
    LKAlertAction *action = self.alertActions[sender.tag];
    if (action.handler) {
        action.handler(action);
    } else if (self.actionHandler) {
        self.actionHandler(action);
    }
    if (action.canClose) {
        if (action.canClose(action)) {
            [self hide];
        }
    } else {
        [self hide];
    }
}

//发送View的事件
#pragma mark - send view event

//公有方法
#pragma mark - public method

- (void)addAction:(LKAlertAction *)action
{
    /// 只能存在一个取消按钮样式
    if (self.preferredStyle == LKAlertViewStyleActionSheet || self.preferredStyle == LKAlertViewStyleChooseSheet) {
        NSInteger cancelStyleCount = 0;
        for (LKAlertAction *action in self.alertActions) {
            if (action.style == LKAlertActionStyleCancel) {
                cancelStyleCount ++;
            }
        }
        if (action.style == LKAlertActionStyleCancel) {
            NSAssert(cancelStyleCount == 0, @"`LKAlertViewStyleActionSheet`样式下按钮Action `LKAlertActionStyleCancel`只能存在一个");
            /// 修改默认颜色值
            if (action.setTitleColorCount == 1) {
                action.titleColor = UIColor.blackColor;
            }
            [self addBottomAction:action];
            return;
        }
    }
    
    NSMutableArray *alertActions = self.alertActions.mutableCopy ? : NSMutableArray.new;
    [alertActions addObject:action];
    self.alertActions = alertActions.copy;
    
    CGFloat height = self.preferredStyle == (LKAlertViewStyleActionSheet || LKAlertViewStyleChooseSheet) ? 49 : 44;
    
    if (self.alertActions.count > 2 || self.preferredStyle == LKAlertViewStyleActionSheet) {
        self.actionsStackView.axis = UILayoutConstraintAxisVertical;
        self.actionsStackView.distribution = UIStackViewDistributionFill;
    } else {
        self.actionsStackView.axis = UILayoutConstraintAxisHorizontal;
        self.actionsStackView.distribution = UIStackViewDistributionFillEqually;
    }
    
    UIButton *button = [self createActionButton:action];
    if (self.preferredStyle == LKAlertViewStyleActionSheet || self.preferredStyle == LKAlertViewStyleChooseSheet) {
        [self.actionsStackView insertArrangedSubview:button atIndex:0];
    } else {
        [self.actionsStackView addArrangedSubview:button];
    }
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button.heightAnchor constraintEqualToConstant:height].active = YES;
    button.tag = self.alertActions.count - 1;
}

- (void)addActions:(NSArray <LKAlertAction *>*)actions
{
    for (LKAlertAction *action in actions) {
        [self addAction:action];
    }
}

- (void)addBottomAction:(LKAlertAction *)action
{
    NSMutableArray *alertActions = self.alertActions.mutableCopy ? : NSMutableArray.new;
    [alertActions addObject:action];
    self.alertActions = alertActions.copy;
    
    CGFloat height = 49;
    UIButton *button = [self createActionButton:action];
    if (self.bottomActionsStackView.superview == nil) {
        
        UIView *bottomContainerView = [UIView new];
        bottomContainerView.backgroundColor = UIColor.whiteColor;
        [self.containerView addSubview:bottomContainerView];
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        [bottomContainerView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:0].active = YES;
        [bottomContainerView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:0].active = YES;
        [bottomContainerView.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor].active = YES;

        UIView *line = UIView.new;
        line.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
        line.translatesAutoresizingMaskIntoConstraints = NO;
        [bottomContainerView addSubview:line];
        [line.heightAnchor constraintEqualToConstant:5].active = YES;
        [line.topAnchor constraintEqualToAnchor:bottomContainerView.topAnchor constant:0].active = YES;
        [line.leadingAnchor constraintEqualToAnchor:bottomContainerView.leadingAnchor constant:0].active = YES;
        [line.trailingAnchor constraintEqualToAnchor:bottomContainerView.trailingAnchor constant:0].active = YES;
        
        [bottomContainerView addSubview:self.bottomActionsStackView];
        
        self.bottomActionsStackView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.bottomActionsStackView.topAnchor constraintEqualToAnchor:line.bottomAnchor constant:0].active = YES;
        [self.bottomActionsStackView.leadingAnchor constraintEqualToAnchor:bottomContainerView.leadingAnchor constant:0].active = YES;
        [self.bottomActionsStackView.trailingAnchor constraintEqualToAnchor:bottomContainerView.trailingAnchor constant:0].active = YES;

        CGFloat adjust = 0;
        if (@available(iOS 11.0, *)) {
            adjust = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
        }
        [self.bottomActionsStackView.bottomAnchor constraintEqualToAnchor:bottomContainerView.bottomAnchor constant:-adjust].active = YES;
        
        NSLayoutConstraint *actionsStackViewBottom = [self.actionsStackView.bottomAnchor constraintEqualToAnchor:bottomContainerView.topAnchor constant:0];
        actionsStackViewBottom.active = YES;
        actionsStackViewBottom.priority = 950;
    }
    
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button.heightAnchor constraintEqualToConstant:height].active = YES;
    button.tag = self.alertActions.count - 1;
    [self.bottomActionsStackView insertArrangedSubview:button atIndex:0];
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField, UIView *contentView, LKAlertTextFieldMaker *make))configurationHandler
{
    /// 输入控件
    UITextField *textField = UITextField.new;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    
    /// 输入控件父视图
    UIView *contentView = UIView.new;
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:textField];
    
    /// 整个内容容器
    UIView *containerView = UIView.new;
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:contentView];
    
    [self.textFieldStackView addArrangedSubview:containerView];
    
    NSMutableArray *array = self.addTextFields.mutableCopy ? : NSMutableArray.new;
    [array addObject:textField];
    self.addTextFields = array.copy;
    
    if (self.textFieldStackView.superview != self.containerView) {
        [self.containerView addSubview:self.textFieldStackView];
        self.textFieldStackView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.textFieldStackView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:0].active = YES;
        [self.textFieldStackView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:0].active = YES;
        [self.textFieldStackView.topAnchor constraintEqualToAnchor:self.contentStackView.bottomAnchor constant:0].active = YES;
        [self.textFieldStackView.bottomAnchor constraintEqualToAnchor:self.horizontalLine.topAnchor constant:0].active = YES;
        
        if (self.preferredStyle == LKAlertViewStyleActionSheet || self.preferredStyle == LKAlertViewStyleChooseSheet) {
            self.titleContentViewConstraintBottom.active = NO;
        } else {
            self.contentStackViewConstraintBottom.active = NO;
            self.contentStackViewConstraintHeight.active = NO;
            self.contentStackViewConstraintTop.constant = 20;
        }
    }

    if (configurationHandler) {
        LKAlertTextFieldMaker *make = [[LKAlertTextFieldMaker alloc] initWithTextField:textField contentView:contentView mainView:self.textFieldStackView];
        configurationHandler(textField, contentView, make);
    }
}

- (void)addCustomView:(UIView *(^)(UIEdgeInsets *edges))handler
{
    if (!handler) { return;};
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    UIView *customView = handler(&edgeInsets);
    customView.translatesAutoresizingMaskIntoConstraints = NO;
    if (self.customViewStackView.superview != self.containerView) {
        [self.containerView addSubview:self.customViewStackView];
        self.customViewStackView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.customViewStackView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:0].active = YES;
        [self.customViewStackView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:0].active = YES;
        [self.customViewStackView.topAnchor constraintEqualToAnchor:self.contentStackView.bottomAnchor constant:0].active = YES;
        [self.customViewStackView.bottomAnchor constraintEqualToAnchor:self.horizontalLine.topAnchor constant:0].active = YES;
        
        self.contentStackViewConstraintBottom.active = NO;
        self.contentStackViewConstraintHeight.active = NO;
    }
    
    UIView *contentView = UIView.new;
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:customView];
    
    [customView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:edgeInsets.left].active = YES;
    [customView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-edgeInsets.right].active = YES;
    [customView.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:edgeInsets.top].active = YES;
    [customView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-edgeInsets.bottom].active = YES;
    
    [self.customViewStackView addArrangedSubview:contentView];
}

- (void)show
{
    NSAssert(self.alertActions.count, @"请添加`action`事件");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.alpha = 0;
        self.frame = UIScreen.mainScreen.bounds;
        [[LKAlertView contentView] addSubview:self];
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 1;
        }];
        
        if (self.preferredStyle == LKAlertViewStyleActionSheet || self.preferredStyle == LKAlertViewStyleChooseSheet) {
            self.containerView.alpha = 0;
            self.containerView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.frame));
            [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.containerView.alpha = 1;
                self.containerView.transform = CGAffineTransformMakeTranslation(0, 0);
            } completion:^(BOOL finished) {
            }];
        } else {
            self.containerView.alpha = 0;
            self.containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4);
            [UIView animateWithDuration:0.2 animations:^{
                self.containerView.alpha = 1;
                self.containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    self.containerView.alpha = 1;
                    self.containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                } completion:^(BOOL finished2) {
                }];
            }];
        }
    });
}

- (void)hide
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0;
        }];
        
        if (self.preferredStyle == LKAlertViewStyleActionSheet || self.preferredStyle == LKAlertViewStyleChooseSheet) {
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.containerView.alpha = 0;
                self.containerView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.containerView.frame));
            } completion:^(BOOL finished2){
                [self removeFromSuperview];
            }];
        } else {
            [UIView animateWithDuration:0.1 animations:^{
                self.containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            } completion:^(BOOL finished){
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    self.containerView.alpha = 0;
                    self.containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4);
                } completion:^(BOOL finished2){
                    [self removeFromSuperview];
                }];
            }];
        }
    });
}

//Setters方法
#pragma mark - setters

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    self.titleLabel.font = titleFont;
}

- (void)setMessage:(NSString *)message
{
    _message = message;
    
    if (!self.customMessage) {
        [self updateAttributedContents];
        [self updateContentStackView];
    }
}

- (void)setMessageColor:(UIColor *)messageColor
{
    _messageColor = messageColor;
    
    if (!self.customMessage) {
        [self updateAttributedContents];
        [self updateContentStackView];
    }
}

- (void)setMessageFont:(UIFont *)messageFont
{
    _messageFont = messageFont;
    
    if (!self.customMessage) {
        [self updateAttributedContents];
        [self updateContentStackView];
    }
}

- (void)setMessageAlignment:(NSTextAlignment)messageAlignment
{
    _messageAlignment = messageAlignment;
    
    for (UILabel *label in self.contentStackView.arrangedSubviews) {
        if ([label isKindOfClass:UILabel.class]) {
            label.textAlignment = messageAlignment;
        }
    }
}

//Getters方法
#pragma mark - getters

- (UIView *)containerView
{
    if (_containerView == nil) {
        _containerView = UIView.alloc.init;
        _containerView.layer.cornerRadius = 14;
        _containerView.layer.masksToBounds = YES;
        _containerView.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.95];
    }
    return _containerView;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = UILabel.alloc.init;
        _titleLabel.textColor = UIColor.blackColor;
        _titleLabel.text = @"温馨提示";
        _titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightRegular];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIView *)titleContentView
{
    if (_titleContentView == nil) {
        _titleContentView = UIView.new;
    }
    return _titleContentView;
}

- (UIView *)horizontalLine
{
    if (_horizontalLine == nil) {
        _horizontalLine = UIView.alloc.init;
        _horizontalLine.backgroundColor = [UIColor colorWithRed:222/255.0 green:223/255.0 blue:224/255.0 alpha:1.0];
    }
    return _horizontalLine;
}

- (LKAlertStackView *)contentStackView
{
    if (_contentStackView == nil) {
        _contentStackView = LKAlertStackView.alloc.init;
        _contentStackView.axis = UILayoutConstraintAxisVertical;
        _contentStackView.spacing = 14;
        _contentStackView.alignment = UIStackViewAlignmentCenter;
        _contentStackView.distribution = UIStackViewDistributionFill;
    }
    return _contentStackView;
}

- (LKAlertStackView *)actionsStackView
{
    if (_actionsStackView == nil) {
        _actionsStackView = LKAlertStackView.alloc.init;
        _actionsStackView.axis = UILayoutConstraintAxisHorizontal;
        _actionsStackView.spacing = 2 / [UIScreen mainScreen].scale;
        _actionsStackView.distribution = UIStackViewDistributionFillEqually;
        _actionsStackView.separatorColor = [UIColor colorWithRed:222/255.0 green:223/255.0 blue:224/255.0 alpha:1.0];
    }
    return _actionsStackView;
}

- (LKAlertStackView *)bottomActionsStackView
{
    if (_bottomActionsStackView == nil) {
        _bottomActionsStackView = LKAlertStackView.alloc.init;
        _bottomActionsStackView.axis = UILayoutConstraintAxisVertical;
        _bottomActionsStackView.spacing = 2 / [UIScreen mainScreen].scale;
        _bottomActionsStackView.distribution = UIStackViewDistributionFill;
        _bottomActionsStackView.separatorColor = [UIColor colorWithRed:222/255.0 green:223/255.0 blue:224/255.0 alpha:1.0];
    }
    return _bottomActionsStackView;
}

- (LKAlertStackView *)textFieldStackView
{
    if (_textFieldStackView == nil) {
        _textFieldStackView = LKAlertStackView.alloc.init;
        _textFieldStackView.axis = UILayoutConstraintAxisVertical;
        _textFieldStackView.distribution = UIStackViewDistributionFill;
        _textFieldStackView.alignment = UIStackViewAlignmentFill;
    }
    return _textFieldStackView;
}

- (LKAlertStackView *)customViewStackView
{
    if (_customViewStackView == nil) {
        _customViewStackView = LKAlertStackView.alloc.init;
        _customViewStackView.axis = UILayoutConstraintAxisVertical;
        _customViewStackView.distribution = UIStackViewDistributionFill;
        _customViewStackView.alignment = UIStackViewAlignmentFill;
    }
    return _customViewStackView;
}

+ (UIView *)contentView
{
    UIView *view;
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
        
        if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
            view = window;
            break;
        }
    }
    return view;
}

@end


@interface LKAlertTextFieldMaker ()
@property (nonatomic, strong) UIView *textField;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) LKAlertStackView *mainView;
@property (nonatomic, strong) NSLayoutConstraint *textFieldConstraintLeading;
@property (nonatomic, strong) NSLayoutConstraint *textFieldConstraintTrailing;
@property (nonatomic, strong) NSLayoutConstraint *textFieldConstraintTop;
@property (nonatomic, strong) NSLayoutConstraint *textFieldConstraintBottom;
@property (nonatomic, strong) NSLayoutConstraint *textFieldConstraintHeight;

@property (nonatomic, strong) NSLayoutConstraint *contentViewConstraintLeading;
@property (nonatomic, strong) NSLayoutConstraint *contentViewConstraintTrailing;
@property (nonatomic, strong) NSLayoutConstraint *contentViewConstraintTop;
@property (nonatomic, strong) NSLayoutConstraint *contentViewConstraintBottom;
@end

@implementation LKAlertTextFieldMaker

- (id)initWithTextField:(UITextField *)textField
            contentView:(UIView *)contentView
               mainView:(UIStackView *)mainView
{
    if (self = [super init]) {
        self.textField = textField;
        self.contentView = contentView;
        self.mainView = (LKAlertStackView *)mainView;
        self.textField.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.contentViewConstraintLeading = [self.contentView.leadingAnchor constraintEqualToAnchor:self.contentView.superview.leadingAnchor constant:10];
        self.contentViewConstraintTrailing = [self.contentView.trailingAnchor constraintEqualToAnchor:self.contentView.superview.trailingAnchor constant:-10];
        self.contentViewConstraintTop = [self.contentView.topAnchor constraintEqualToAnchor:self.contentView.superview.topAnchor constant:0];
        self.contentViewConstraintBottom = [self.contentView.bottomAnchor constraintEqualToAnchor:self.contentView.superview.bottomAnchor constant:0];
        
        self.contentViewConstraintLeading.active = YES;
        self.contentViewConstraintTrailing.active = YES;
        self.contentViewConstraintTop.active = YES;
        self.contentViewConstraintBottom.active = YES;
        
        self.textFieldConstraintLeading = [self.textField.leadingAnchor constraintEqualToAnchor:self.textField.superview.leadingAnchor constant:0];
        self.textFieldConstraintTrailing = [self.textField.trailingAnchor constraintEqualToAnchor:self.textField.superview.trailingAnchor constant:0];
        self.textFieldConstraintTop = [self.textField.topAnchor constraintEqualToAnchor:self.textField.superview.topAnchor constant:6];
        self.textFieldConstraintBottom = [self.textField.bottomAnchor constraintEqualToAnchor:self.textField.superview.bottomAnchor constant:-6];
        self.textFieldConstraintHeight = [self.textField.heightAnchor constraintEqualToConstant:21];
        
        self.textFieldConstraintLeading.active = YES;
        self.textFieldConstraintTrailing.active = YES;
        self.textFieldConstraintTop.active = YES;
        self.textFieldConstraintBottom.active = YES;
        self.textFieldConstraintHeight.active = YES;
        
        self.paddingInsets = UIEdgeInsetsMake(6, 10, 6, 10);
        self.marginInsets = UIEdgeInsetsMake(10, 10, 20, 10);
        self.textFieldHeight = 21;
    }
    return self;
}

- (void)setMarginInsets:(UIEdgeInsets)marginInsets
{
    _marginInsets = marginInsets;
    self.contentViewConstraintLeading.constant = marginInsets.left;
    self.contentViewConstraintTrailing.constant = - marginInsets.right;
    self.contentViewConstraintTop.constant = marginInsets.top;
    self.contentViewConstraintBottom.constant = - marginInsets.bottom;
}

- (void)setPaddingInsets:(UIEdgeInsets)paddingInsets
{
    _paddingInsets = paddingInsets;
    self.textFieldConstraintLeading.constant = paddingInsets.left;
    self.textFieldConstraintTrailing.constant = - paddingInsets.right;
    self.textFieldConstraintTop.constant = paddingInsets.top;
    self.textFieldConstraintBottom.constant = -paddingInsets.bottom;
}

- (void)setTextFieldHeight:(CGFloat)textFieldHeight
{
    _textFieldHeight = textFieldHeight;
    self.textFieldConstraintHeight.constant = textFieldHeight;
}

@end
