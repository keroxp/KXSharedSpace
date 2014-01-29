//
//  KXDetailViewController.h
//  KXSharedSpace
//
//  Created by Yusuke Sakurai on 2014/01/29.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KXDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
