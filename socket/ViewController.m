//
//  ViewController.m
//  socket
//
//  Created by 林love耀 on 16/4/11.
//  Copyright © 2016年 林love耀. All rights reserved.
//

#import "ViewController.h"
#import "MyServer.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *inputTF;
@property (nonatomic, strong) MyServer *server;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        MyServer *server=[[MyServer alloc]init];
        [server start];
        _server = server;
    });
    
}
- (IBAction)sendBtnClick:(id)sender {
    [_server senMessageToAllClient:_inputTF.text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
