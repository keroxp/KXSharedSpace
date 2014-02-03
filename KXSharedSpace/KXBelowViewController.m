//
//  KXBelowViewController.m
//  KXSharedSpace
//
//  Created by 桜井雄介 on 2014/02/03.
//  Copyright (c) 2014年 Yusuke Sakurai. All rights reserved.
//

#import "KXBelowViewController.h"
#import "KXSharedSpace.h"

@interface KXBelowViewController ()
{
    NSArray *titles_;
}
@end

@implementation KXBelowViewController

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
    // observe all property of name space "App"
    
    titles_  = @[@"switch",@"stepper",@"slider",@"segment",@"textField"];
    [[KXSharedSpace spaceWithName:@"App"] addObserver:self forKeyPath:kKXSharedSpaceObserveAllKey options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSUInteger i = [titles_ indexOfObject:keyPath];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titles_.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    cell.textLabel.text = titles_[indexPath.row];
    id val = [self readDataFromSpaceForKey:@"App" valueKey:titles_[indexPath.row]];
    switch (indexPath.row) {
        case 0:
            cell.detailTextLabel.text = ([val boolValue]) ? @"on" : @"off";
            break;
        case 1:
        case 2:
        case 3:
            cell.detailTextLabel.text = [val stringValue];
            break;
        case 4:
            cell.detailTextLabel.text = [val isKindOfClass:[NSString class]] ? val : @"";
            break;
        default:
            break;
    }
    return cell;
}

@end
