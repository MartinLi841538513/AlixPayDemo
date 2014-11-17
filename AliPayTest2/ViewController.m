//
//  ViewController.m
//  AliPayTest
//
//  Created by Gao Huang on 14-11-17.
//  Copyright (c) 2014年 GL. All rights reserved.
//

#import "ViewController.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "AlixPayOrder.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)payAction:(id)sender {
    
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = @"2088801770744581";
    NSString *seller = @"hubeijiaxingyue@sina.com";
    NSString *privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAKcfzYN+td5aBCYUngMZu/i8WUazan7p+yPmiyO8aNZA2HSvbIfeTdx5g+PVqrQ3J9TypxVTtG4ukFn7OwimP+AYN4/5ZUsdYug0DalDhIrUeh6xX6uiS73Vw+m3a5GX5q/YdoIGDJFAY8eJjkqb7cYHnrNUo/9PKkQq+LJzjsCtAgMBAAECgYBbyEN9q+EFtDoDD9+XpFJvUEFXasFZ4fZiyQIxJhANWp+FtbHNDHGGW9XrEjUltATUFk9cjxPQTxJH2ImbPnJlJBXWVCdsxScf8cEYXeAvcQzYT8yPUzXmkdgcs+aZXF9v7XDNbGLL6iYjHqx9mZBivyj1IIr0+wPKLfM9q9BVoQJBAN7HUmgj0qU+sZkRRElr6S4SrvNLuM6D/d6wM7U3sp6sGp6aUk/c1VGSrcaU+fbxxovHBLnzM2IGPiS+O7vlsWsCQQDAC9lZghqpu11KzeQLnjLMCtkXUmAxkuAsWKEKUOkGI8qtw2nxIofjw2gjQQmWmkRzn1GsYup/M5PeEwFWFqRHAkEA1B8yJhrF/bW+YSMBxG9NriL4Fo0pQOqJFjrsYUbReyggiJgkfAqny25ArO85O5tnE7zCkVQyvsl27oF8WyMQVQJAbotjhR5a8rCjNtflGLrrSoBEDiSgsmh1GZG6wRFp0NrxY6xEY0UZK4Xjf8eEGWibVmKyxKP7j1TFHOObtU47KQJAbRxr5A+6bKU8eujxMwEvsZn0t3+sss6K6Vs6rH6EOkDN3vPBqL1sXlp6eZekrt5YDiXFDAsLjju3CKsoRHclBg==";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 || [seller length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    AlixPayOrder *order = [[AlixPayOrder alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
    //    order.productName = product.subject; //商品标题
    //    order.productDescription = product.body; //商品描述
    order.amount = [NSString stringWithFormat:@"%.2f",0.1]; //商品价格
    order.notifyURL =  @"http://www.xxx.com"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"AliPayTest2";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
        
    }
    
}

#pragma mark -
#pragma mark   ==============产生随机订单号==============


- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand(time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}
@end
