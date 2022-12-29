//
//  LKAlertView.h
//  LKAlertView
//
//  Created by Fan Li Lin on 2021/4/16.
//

#import <UIKit/UIKit.h>

@class LKAlertTextFieldMaker;

/// 按钮默认样式
typedef NS_ENUM(NSInteger, LKAlertActionStyle) {
    LKAlertActionStyleDefault = 0,
    /// 在`LKAlertViewStyleActionSheet`样式下只能添加一个，用于底部的取消按钮
    LKAlertActionStyleCancel,
    LKAlertActionStyleDelete,
    LKAlertActionStyleCustom,
    /// 内容居左-图左文右
    LKAlertActionStyleCenterImageLeft,
    /// 内容居左-图右文左
    LKAlertActionStyleCenterImageRight,
};

/// 弹窗样式
typedef NS_ENUM(NSInteger, LKAlertViewStyle) {
    /// 底部弹窗
    LKAlertViewStyleActionSheet = 0,
    /// 中间弹窗
    LKAlertViewStyleAlert,
    /// 挑选表单 底部弹窗样式（暂不支持 交互未开发完成，请不要使用）
    LKAlertViewStyleChooseSheet
};

@interface LKAlertAction : NSObject

/// init 一个操作按钮
/// @param title 文本
/// @param style 样式
/// @param handler handler
+ (instancetype)actionWithTitle:(NSString *)title
                          style:(LKAlertActionStyle)style
                        handler:(void (^)(LKAlertAction *action))handler;

/// init 一个操作按钮
/// @param title 文本
/// @param image 图片
/// @param style 样式
+ (instancetype)actionWithTitle:(NSString *)title
                          image:(UIImage *)image
                          style:(LKAlertActionStyle)style;

/// init 一个操作按钮
/// @param title 文本
/// @param image 图片
/// @param style 样式
/// @param handler handler
+ (instancetype)actionWithTitle:(NSString *)title
                          image:(UIImage *)image
                          style:(LKAlertActionStyle)style
                        handler:(void (^)(LKAlertAction *action))handler;

/// init 一个操作按钮
/// @param title title
/// @param style style
/// @param handler handler
/// @param canClose 是否自动关闭弹窗
+ (instancetype)actionWithTitle:(NSString *)title
                          style:(LKAlertActionStyle)style
                        handler:(void (^)(LKAlertAction *action))handler
                       canClose:(BOOL (^)(LKAlertAction *action))canClose;

/// init 一个操作按钮
/// @param title title
/// @param image 图片
/// @param style style
/// @param handler handler
/// @param canClose 是否自动关闭弹窗
+ (instancetype)actionWithTitle:(NSString *)title
                          image:(UIImage *)image
                          style:(LKAlertActionStyle)style
                        handler:(void (^)(LKAlertAction *action))handler
                       canClose:(BOOL (^)(LKAlertAction *action))canClose;

/// title
@property (nonatomic, copy) NSString *title;
/// titleColor
@property (nonatomic, strong) UIColor *titleColor;
/// 字体
@property (nonatomic, strong) UIFont *font;
/// 按钮默认样式（如需自定义，请在调用次方法后重新设置 属性 `titleColor` `font`）
@property (nonatomic, assign) LKAlertActionStyle style;
/// 附加的图片
@property (nonatomic, strong) UIImage *image;
/// 图片文字间距；默认 = 10
@property (nonatomic, assign) CGFloat imagePadding;
/// 点击后的返回数据
@property (nonatomic, strong) id result;
@end

@interface LKAlertView : UIView

/// 显示一个类似系统的Alert弹窗
/// @param title 显示标题
/// @param message 显示内容
/// @param preferredStyle 弹窗样式
+ (instancetype)alertViewWithTitle:(NSString *)title
                           message:(NSString *)message
                    preferredStyle:(LKAlertViewStyle)preferredStyle;

/// 显示一个类似系统的Alert弹窗
/// @param title 显示标题
/// @param messages 富文本内容
/// @param preferredStyle 弹窗样式
+ (instancetype)alertViewWithTitle:(NSString *)title
                attributedMessages:(NSArray <NSAttributedString *>*)messages
                    preferredStyle:(LKAlertViewStyle)preferredStyle;


/// 直接一句话弹窗
/// @param title 显示标题
/// @param message 显示内容
/// @param preferredStyle 弹窗样式
/// @param actions 点击的action
+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
            preferredStyle:(LKAlertViewStyle)preferredStyle
                   actions:(NSArray <LKAlertAction *>*)actions;

/// title
@property (nonatomic, copy) NSString *title;
/// titleColor
@property (nonatomic, strong) UIColor *titleColor;
/// titleFont
@property (nonatomic, strong) UIFont *titleFont;
/// message （如果是自定义 attributedMessages：此属性则无效）
@property (nonatomic, copy) NSString *message;
/// messageColor（如果是自定义 attributedMessages：此属性则无效）
@property (nonatomic, strong) UIColor *messageColor;
/// messageFont（如果是自定义 attributedMessages：此属性则无效）
@property (nonatomic, strong) UIFont *messageFont;
/// 文本内容对齐模式 默认  NSTextAlignmentCenter
@property (nonatomic, assign) NSTextAlignment messageAlignment;
/// preferredStyle
@property (nonatomic, assign, readonly) LKAlertViewStyle preferredStyle;
/// 多个action的时候统一回调（注意：如果action本身实现了handler这里不会重复调用）
@property (nonatomic, copy) void (^actionHandler)(LKAlertAction *action);

/// 添加action
/// @param action action
- (void)addAction:(LKAlertAction *)action;

/// 添加action
/// @param actions 多个action
- (void)addActions:(NSArray <LKAlertAction *>*)actions;

/// 添加底部自定义底部action
/// @param action 自定义action
- (void)addBottomAction:(LKAlertAction *)action;

/// 添加一个输入控件
/// @param configurationHandler 可对UITextField进行相关配置
- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField, UIView *contentView, LKAlertTextFieldMaker *make))configurationHandler;

/// 添加自定义视图（需要自定义view内部满足自动布局约束条件）
/// @param handler edges：调整内边距；默认 = UIEdgeInsetsMake(0, 0, 0, 0)
- (void)addCustomView:(UIView *(^)(UIEdgeInsets *edges))handler;

/// show
- (void)show;

///  hide
- (void)hide;

@end


@interface LKAlertTextFieldMaker : NSObject
/// contentView内边距
@property (nonatomic, assign) UIEdgeInsets marginInsets;
/// textField内边距
@property (nonatomic, assign) UIEdgeInsets paddingInsets;
/// textField的高度；默认 = 21
@property (nonatomic, assign) CGFloat textFieldHeight;
@end
