//
//  TBPictureViewController.h
//  TheBackgrounder
//
//  Created by lizhijie on 7/1/15.
//  Copyright (c) 2015 Gustavo Ambrozio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface TBPictureViewController : UIViewController<NSStreamDelegate,UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,MWPhotoBrowserDelegate>


- (IBAction)didTapConnect:(id)sender;


@end
