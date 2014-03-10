//
//  KXAboveViewController.m
//  KXSharedSpace
//
//  Created by 桜井雄介 on 2014/02/03.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import "KXAboveViewController.h"

@interface KXAboveViewController ()

@end

@implementation KXAboveViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)switchDidChange:(UISwitch*)sender {
    [self kx_writeData:@([sender isOn])toSpaceForKey:@"App" valueKey:@"switch"];
}
- (IBAction)stepperDidChange:(UIStepper *)sender {
    [self kx_writeData:@(sender.value) toSpaceForKey:@"App" valueKey:@"stepper"];
}
- (IBAction)slider:(UISlider *)sender {
    [self kx_writeData:@([sender value]) toSpaceForKey:@"App" valueKey:@"slider"];
}
- (IBAction)segment:(UISegmentedControl *)sender {
    [self kx_writeData:@([sender selectedSegmentIndex]) toSpaceForKey:@"App" valueKey:@"segment"];
}

- (IBAction)textField:(UITextField *)sender {
    [self kx_writeData:sender.text toSpaceForKey:@"App" valueKey:@"textField"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}


@end
