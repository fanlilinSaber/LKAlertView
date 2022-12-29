# LKAlertView
APP弹窗提示组件 类似系统的 AlertView

## 功能特点

- 支持OC和Swift
- 支持自定义外观
- 支持自定义内容
- 每一个部件都可以独立设置

## 预览

| 效果  | 预览图 |
| ---  | --- |
| **常规提示** | <img src = "https://github.com/fanlilinSaber/LKExampleImages/blob/main/LKAlertView/001.png" width = 375 /> |
| **自定义内容** | <img src = "https://github.com/fanlilinSaber/LKExampleImages/blob/main/LKAlertView/002.png" width = 375 /> |
| **文本多行提示** | <img src = "https://github.com/fanlilinSaber/LKExampleImages/blob/main/LKAlertView/003.png" width = 375 /> |
| **多按钮操作** | <img src = "https://github.com/fanlilinSaber/LKExampleImages/blob/main/LKAlertView/004.png" width = 375 /> |
| **底部弹窗样式** | <img src = "https://github.com/fanlilinSaber/LKExampleImages/blob/main/LKAlertView/005.png" width = 375 /> |
| **弹窗输入框** | <img src = "https://github.com/fanlilinSaber/LKExampleImages/blob/main/LKAlertView/006.png" width = 375 />|
| **底部弹窗图片+文字** | <img src = "https://github.com/fanlilinSaber/LKExampleImages/blob/main/LKAlertView/007.png" width = 375 /> |

## 安装

### CocoaPods 安装使用
- ①请在Podfile中指定→ pod 'LKAlertView'
- ②然后终端执行 `pod install`

## 更新日志

* 2022年12月29日 `v1.3.3`
  - 1.内容间距更新到UI4.2标准

* 2022年12月21日 `v1.3.2`
  - 1.默认字体颜色更新到UI4.2标准

* 2022年12月3日 `v1.3.1`
  - 1.新增支持添加自定义视图
```Objective-C
/// 添加自定义视图（需要自定义view内部满足自动布局约束条件）
/// @param handler edges：调整内边距；默认 = UIEdgeInsetsMake(0, 0, 0, 0)
- (void)addCustomView:(UIView *(^)(UIEdgeInsets *edges))handler;
```
  - 2.优化其他字段逻辑

* 2022年11月8日 `v1.3.0`
  - 1.优化

* 2022年4月12日 `v1.2.0`
  - 1. `AlertAction` 新增图片加文本样式
  - 2. 新增`actionHandler`属性
```Objective-C
/// 多个action的时候统一回调（注意：如果action本身实现了handler这里不会重复调用）
@property (nonatomic, copy) void (^actionHandler)(LKAlertAction *action);
```

* 2022年3月8日 `v1.1.3`
  - 1.`LKAlertAction`默认样式新增 LKAlertActionStyleDelete
  - 2.修复`LKAlertView` 不设置message高度显示错位

* 2021年10月22日 `v1.1.2`
  - 1.优化`LKAlertViewStyleActionSheet`样式下 取消按钮的默认颜色

* 2021年10月21日 `v1.1.1`
  - 1.适配刘海屏

* 2021年09月18日 `v1.1.0`
  - 1.支持添加输入控件UITextField；UITextField样式可以自定义
```Objective-C
[alertView addTextFieldWithConfigurationHandler:^(UITextField *textField, UIView *contentView, LKAlertTextFieldMaker *make) {
    textField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    NSDictionary *attributes = @{NSFontAttributeName: textField.font,
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:192/255.0 green:196/255.0 blue:204/255.0 alpha:1.0]};
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入支付比例" attributes:attributes];
    textField.keyboardType = UIKeyboardTypeDecimalPad;
    
    make.paddingInset = UIEdgeInsetsMake(6, 10, 6, 35);
    make.marginInset = UIEdgeInsetsMake(10, 10, 20, 10);
    contentView.layer.cornerRadius = 5;
    contentView.layer.borderWidth = 1;
    contentView.layer.borderColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0].CGColor;
    contentView.layer.masksToBounds = YES;
    
    UILabel *label = UILabel.new;
    label.text = @"%";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:192/255.0 green:196/255.0 blue:204/255.0 alpha:1.0];
    label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    label.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0];
    [contentView addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(35);
    }];
    
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}];
```
* 2021年07月14日 `v1.0.2`
  - 1.新增底部弹窗样式
