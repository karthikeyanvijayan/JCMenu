//
//  ViewController.m
//  JCMenuSample
//
//  Created by Jean-Baptiste Castro on 17/09/2013.

#import "ViewController.h"

#import "JCMenu.h"
#import "JCMenuItem.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    JCMenuItem *facebook = [[JCMenuItem alloc] initWithImage:[UIImage imageNamed:@"facebook"] action:^(JCMenuItem *item){
        [self.textLabel setText:@"Facebook"];
    }];
    
    JCMenuItem *tumblr = [[JCMenuItem alloc] initWithImage:[UIImage imageNamed:@"tumblr"] action:^(JCMenuItem *item){
        [self.textLabel setText:@"Tumblr"];
    }];
    
    JCMenuItem *yahoo = [[JCMenuItem alloc] initWithImage:[UIImage imageNamed:@"yahoo"] action:^(JCMenuItem *item){
        [self.textLabel setText:@"Yahoo"];
    }];

    JCMenuItem *youtube = [[JCMenuItem alloc] initWithImage:[UIImage imageNamed:@"youtube"] action:^(JCMenuItem *item){
        [self.textLabel setText:@"Youtube"];
    }];
    
    JCMenu *menu = [[JCMenu alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 60, self.view.frame.size.width - 20, 50) items:@[facebook, tumblr, yahoo, youtube]];
    [menu setSelectedItem:facebook];
    [menu setMenuTintColor:[UIColor colorWithRed:189/255.0f green:22/255.0f blue:34/255.0f alpha:1.0f]];
    [menu setShowSeparatorView:YES];
    [menu setSeparatorColor:[UIColor whiteColor]];
    [menu setSeparatorViewHeight:20];
    [menu setSeparatorViewWidth:1];
    [self.view addSubview:menu];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
