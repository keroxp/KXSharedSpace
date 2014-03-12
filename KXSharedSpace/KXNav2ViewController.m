//
//  KXNav2ViewController.m
//  KXSharedSpace
//
//  Created by 桜井雄介 on 2014/03/12.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import "KXNav2ViewController.h"
#import "NSObject+KXSharedSpace.h"
@interface KXNav2ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation KXNav2ViewController

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
    NSLog(@"Nav2 dealloc");
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.textField.text = [self kx_readDataFromSpaceForKey:@"Nav" valueKey:@"text"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)close:(id)sender {
    [self.textField resignFirstResponder];
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
- (IBAction)editted:(UITextField*)sender {
    [self kx_writeData:sender.text toSpaceForKey:@"Nav" valueKey:@"text"];
}

@end
