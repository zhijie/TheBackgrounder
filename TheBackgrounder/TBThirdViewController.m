//
//  TBThirdViewController.m
//  TheBackgrounder
//
//  Created by lizhijie on 7/1/15.
//  Copyright (c) 2015 Gustavo Ambrozio. All rights reserved.
//

#import "TBThirdViewController.h"

@interface TBThirdViewController ()

@end

@implementation TBThirdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"设置";
        self.tabBarItem.image = [UIImage imageNamed:@"ic_general_bottombar_settings"];
    }
    return self;
}
-(void)viewDidLoad
{
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
