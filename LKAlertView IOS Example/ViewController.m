//
//  ViewController.m
//  LKAlertView IOS Example
//
//  Created by Fan Li Lin on 2021/4/16.
//

#import "ViewController.h"
#import <LKAlertView/LKAlertView.h>
#import <Masonry/Masonry.h>
#import "PayAffirmView.h"

@interface ViewController ()
/// <##>
@property (nonatomic, copy) NSString *scale;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)test01:(UIButton *)sender {
    
    LKAlertView *alertView = [LKAlertView alertViewWithTitle:@"无权限操作" message:@"请先进行司机认证" preferredStyle:LKAlertViewStyleAlert];
    LKAlertAction *action01 = [LKAlertAction actionWithTitle:@"取消" style:LKAlertActionStyleCancel handler:nil];
    LKAlertAction *action02 = [LKAlertAction actionWithTitle:@"确定" style:LKAlertActionStyleDefault handler:^(LKAlertAction *action) {
        
    }];
    [alertView addAction:action01];
    [alertView addAction:action02];
    [alertView show];
}

- (IBAction)test02:(UIButton *)sender {
    
    LKAlertView *alertView = [LKAlertView alertViewWithTitle:@"无权限操作" message:@"(1) 10:00点批次，受理T-1日 16:51至当日09：50进入平台的对公提现\n\r(2)11:00点批次（新增），受理当日09:51至10:50 进入平台的对公提现\n\r(3)13:00点批次（新增），受理当日10:51至12:50 进入平台的对公提现\n\r(4)14:00点批次，受理当日 12:51至13:50 进入平台的对公提现\n\r(4)14:00点批次，受理当日 12:51至13:50 进入平台的对公提现\n\r(5)15:00点批次（新增），受理当日13:51至14:50 进入平台的对公提现\n\r(6)16:00点批次，受理当日 14:51至15:50 进入平台的对公提现\n\r(7)17:00点批次（新增），受理当日15:51至16:50 进入平台的对公提现" preferredStyle:LKAlertViewStyleAlert];
    alertView.messageAlignment = NSTextAlignmentLeft;
    LKAlertAction *action01 = [LKAlertAction actionWithTitle:@"取消" style:LKAlertActionStyleCancel handler:nil];
    LKAlertAction *action02 = [LKAlertAction actionWithTitle:@"确定" style:LKAlertActionStyleDefault handler:^(LKAlertAction *action) {
        
    }];
    [alertView addAction:action01];
    [alertView addAction:action02];
    [alertView show];
    
}

- (IBAction)test03:(UIButton *)sender {
    LKAlertView *alertView = [LKAlertView alertViewWithTitle:@"温馨提示" message:@"您没有权限\n请认证或加入认证企业后再试" preferredStyle:LKAlertViewStyleAlert];
    LKAlertAction *action01 = [LKAlertAction actionWithTitle:@"去认证" style:LKAlertActionStyleDefault handler:^(LKAlertAction *action) {
        
    }];
    LKAlertAction *action02 = [LKAlertAction actionWithTitle:@"加入企业" style:LKAlertActionStyleDefault handler:^(LKAlertAction *action) {
        
    }];
    LKAlertAction *action03 = [LKAlertAction actionWithTitle:@"我知道了" style:LKAlertActionStyleCancel handler:^(LKAlertAction *action) {
        
    }];
    [alertView addAction:action01];
    [alertView addAction:action02];
    [alertView addAction:action03];
    [alertView show];
}

- (IBAction)test04:(UIButton *)sender {
    
    LKAlertView *alertView = [LKAlertView alertViewWithTitle:@"请选择支付方式" message:nil preferredStyle:LKAlertViewStyleActionSheet];
    LKAlertAction *actionCancel = [LKAlertAction actionWithTitle:@"取消" style:LKAlertActionStyleCancel handler:^(LKAlertAction *action) {

    }];
//    actionCancel.titleColor = UIColor.redColor;
    LKAlertAction *action02 = [LKAlertAction actionWithTitle:@"余额支付" style:LKAlertActionStyleCustom handler:^(LKAlertAction *action) {

    }];
    LKAlertAction *action03 = [LKAlertAction actionWithTitle:@"快捷支付" style:LKAlertActionStyleDefault handler:^(LKAlertAction *action) {

    }];
    [alertView addAction:actionCancel];
    [alertView addAction:action02];
    [alertView addAction:action03];
    [alertView show];
}

- (IBAction)test005:(UIButton *)sender {
    
    //显示弹出框列表选择
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Title"
                                                                   message:@"This is an Sheet."
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
//    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        
//    }];
//    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//
//    }];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
        //响应事件
        NSLog(@"action = %@", action);
    }];
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * action) {
        //响应事件
        NSLog(@"action = %@", action);
    }];
    UIAlertAction* saveAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
        //响应事件
        NSLog(@"action = %@", action);
    }];
    [alert addAction:saveAction];
    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    [self presentViewController:alert animated:YES completion:nil];

}

- (IBAction)test006:(UIButton *)sender {
    
    LKAlertView *alertView = [LKAlertView alertViewWithTitle:@"温馨提示" message:@"请输入自定义支付比例" preferredStyle:LKAlertViewStyleAlert];
    LKAlertAction *action01 = [LKAlertAction actionWithTitle:@"取消" style:LKAlertActionStyleCancel handler:nil];
    LKAlertAction *action02 = [LKAlertAction actionWithTitle:@"确定" style:LKAlertActionStyleDefault handler:^(LKAlertAction *action) {
        
    } canClose:^BOOL(LKAlertAction *action) {
        if (self.scale == nil || self.scale.length == 0) {
            NSLog(@"请输入支付比例");
            return NO;
        } else if (self.scale.floatValue > 100 || self.scale.floatValue <= 0) {
            NSLog(@"请输入大于0，小于等于100的数字");
            return NO;
        }
        return YES;
    }];
    [alertView addAction:action01];
    [alertView addAction:action02];
    
    [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField, UIView *contentView, LKAlertTextFieldMaker *make) {
        textField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        NSDictionary *attributes = @{NSFontAttributeName: textField.font,
                                     NSForegroundColorAttributeName: [UIColor colorWithRed:192/255.0 green:196/255.0 blue:204/255.0 alpha:1.0]};
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入支付比例1" attributes:attributes];
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        
        make.paddingInsets = UIEdgeInsetsMake(6, 10, 6, 35);
        make.marginInsets = UIEdgeInsetsMake(10, 10, 10, 10);
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
    
    [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField, UIView *contentView, LKAlertTextFieldMaker *make) {
        make.paddingInsets = UIEdgeInsetsMake(6, 10, 6, 35);
        make.marginInsets = UIEdgeInsetsMake(0, 10, 10, 10);
        textField.placeholder = @"请输入支付比例2";
        contentView.layer.cornerRadius = 5;
        contentView.layer.borderWidth = 1;
        contentView.layer.borderColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0].CGColor;

        UILabel *label = UILabel.new;
        label.text = @"%";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:192/255.0 green:196/255.0 blue:204/255.0 alpha:1.0];
        label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        label.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
        [contentView addSubview:label];

        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(35);
        }];
    }];

    [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField, UIView *contentView, LKAlertTextFieldMaker *make) {
        make.paddingInsets = UIEdgeInsetsMake(6, 10, 6, 35);
        make.marginInsets = UIEdgeInsetsMake(0, 20, 10, 20);
        textField.placeholder = @"请输入支付比例3";
        contentView.layer.cornerRadius = 5;
        contentView.layer.borderWidth = 1;
        contentView.layer.borderColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0].CGColor;

        UILabel *label = UILabel.new;
        label.text = @"%";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:192/255.0 green:196/255.0 blue:204/255.0 alpha:1.0];
        label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        label.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
        [contentView addSubview:label];

        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.centerY.mas_equalTo(textField);
            make.width.mas_equalTo(35);
        }];
    }];
    
    [alertView show];
}

- (IBAction)test07:(UIButton *)sender {
    LKAlertView *alertView = [LKAlertView alertViewWithTitle:nil message:nil preferredStyle:LKAlertViewStyleActionSheet];
    alertView.actionHandler = ^(LKAlertAction *action) {
        NSLog(@"action.result = %@", action.result);
    };
    
    LKAlertAction *actionCancel = [LKAlertAction actionWithTitle:@"取消" style:LKAlertActionStyleCancel handler:^(LKAlertAction *action) {

    }];
    
    NSMutableArray *array = NSMutableArray.new;
    for (int i = 0; i < 8; i ++) {
        LKAlertAction *action = [LKAlertAction actionWithTitle:@"钢材业务客服1-小丽" image:[UIImage imageNamed:@"jiaoliu"] style:LKAlertActionStyleCenterImageLeft];
        action.result = [NSString stringWithFormat:@"%d", i];
        [array addObject:action];
    }
    LKAlertAction *action02 = [LKAlertAction actionWithTitle:@"钢材业务客服1-小丽" image:[UIImage imageNamed:@"jiaoliu"] style:LKAlertActionStyleCenterImageRight handler:^(LKAlertAction *action) {

    }];
    
    [alertView addAction:actionCancel];
    [alertView addAction:action02];
    [alertView addActions:array.copy];
    [alertView show];
}

- (IBAction)test08:(UIButton *)sender {
    LKAlertView *alertView = [LKAlertView alertViewWithTitle:@"请选择商品类型" message:nil preferredStyle:LKAlertViewStyleChooseSheet];

    LKAlertAction *action02 = [LKAlertAction actionWithTitle:@"固定资产" style:LKAlertActionStyleCustom handler:^(LKAlertAction *action) {

    }];
    LKAlertAction *action03 = [LKAlertAction actionWithTitle:@"生成原料" style:LKAlertActionStyleDefault handler:^(LKAlertAction *action) {

    }];
    LKAlertAction *action04 = [LKAlertAction actionWithTitle:@"贸易销售" style:LKAlertActionStyleDefault handler:^(LKAlertAction *action) {

    }];
    
    LKAlertAction *addAction = [LKAlertAction actionWithTitle:@"添加类型" image:[UIImage imageNamed:@"tianjia"] style:LKAlertActionStyleCenterImageLeft];
    addAction.titleColor = [UIColor colorWithRed:183/255.0 green:146/255.0 blue:85/255.0 alpha:1.0];
    
    [alertView addAction:action02];
    [alertView addAction:action03];
    [alertView addAction:action04];
    
    [alertView addBottomAction:addAction];
    [alertView addBottomAction:addAction];
    
    [alertView show];
}

- (IBAction)test09:(UIButton *)sender {
    
    LKAlertView *alertView = [LKAlertView alertViewWithTitle:@"第三方账户支付" message:nil preferredStyle:LKAlertViewStyleAlert];
    
    [alertView addCustomView:^UIView *(UIEdgeInsets *edges) {
        *edges = UIEdgeInsetsMake(0, 0, 0, 0);
        PayAffirmView *contentView = PayAffirmView.new;
        return contentView;
    }];
    
    LKAlertAction *action01 = [LKAlertAction actionWithTitle:@"取消" style:LKAlertActionStyleCancel handler:nil];
    LKAlertAction *action02 = [LKAlertAction actionWithTitle:@"确定支付" style:LKAlertActionStyleDefault handler:^(LKAlertAction *action) {
        
    }];
    [alertView addAction:action01];
    [alertView addAction:action02];
    [alertView show];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if ([textField.text isEqualToString:@"."]) {
        textField.text = @"";
    }
    self.scale = textField.text;
}

@end
