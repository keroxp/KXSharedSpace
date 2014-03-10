//
//  KXContainerViewController.m
//  KXSharedSpace
//
//  Created by 桜井雄介 on 2014/02/03.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import "KXContainerViewController.h"
#import "KXSharedSpace.h"

@interface KXContainerViewController ()

@end

@implementation KXContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[KXSharedSpace sharedSpace] registerSpaceWithName:@"App" owner:self];
    [[[KXSharedSpace sharedSpace] spaceWithName:@"App"] addObserver:self forKeyPath:kKXSharedSpaceObserveAllKey options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%@ was changed",keyPath);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
