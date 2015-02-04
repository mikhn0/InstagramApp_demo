//
//  ViewController.m
//  InstagramApp
//
//  Created by Виктория on 03.02.15.
//  Copyright (c) 2015 Виктория. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "PhotoPickerViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *addCollageButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _addCollageButton.layer.cornerRadius = 5.0;
    [_addCollageButton addTarget:self
                    action:@selector(login)
          forControlEvents:UIControlEventTouchUpInside];
    

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue: %@", segue.identifier);
        
    if ([segue.identifier isEqualToString:@"showPhotoPicker"]) {
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        
        appDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
        appDelegate.instagram.sessionDelegate = self;
        if (![appDelegate.instagram isSessionValid]) {
            [appDelegate.instagram authorize:[NSArray arrayWithObjects:@"basic", nil]];
        }
        //[segue.destinationViewController setHappiness:100];
    }
}


- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)login {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.instagram authorize:[NSArray arrayWithObjects:@"basic", nil]];
}

#pragma - IGSessionDelegate

-(void)igDidLogin {
    NSLog(@"Instagram did login");
    // here i can store accessToken
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.instagram.accessToken forKey:@"accessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //PhotoPickerViewController* viewController = [[PhotoPickerViewController alloc] init];
    //[self.navigationController pushViewController:viewController animated:YES];
}

-(void)igDidNotLogin:(BOOL)cancelled {
    NSLog(@"Instagram did not login");
    NSString* message = nil;
    if (cancelled) {
        message = @"Access cancelled!";
    } else {
        message = @"Access denied!";
    }
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

-(void)igDidLogout {
    NSLog(@"Instagram did logout");
    // remove the accessToken
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)igSessionInvalidated {
    NSLog(@"Instagram session was invalidated");
}

@end;