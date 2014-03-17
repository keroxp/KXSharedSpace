//
//  KXNav1ViewController.m
//  KXSharedSpace
//
//  Created by 桜井雄介 on 2014/03/12.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import "KXNav1ViewController.h"

@interface KXNav1ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation KXNav1ViewController

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
}

- (void)dealloc
{
    NSLog(@"Nav1 dealloc");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.label.text = [self kx_readDataFromSpaceForKey:@"Nav" valueKey:@"text"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
