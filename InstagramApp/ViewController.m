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
@property (weak, nonatomic) IBOutlet UITextField *nikName;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _addCollageButton.layer.cornerRadius = 5.0;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPhotoPicker"]) {
        if (self.nikName.text.length) {
            AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            
            appDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
            appDelegate.instagram.sessionDelegate = self;
            
            if (![appDelegate.instagram isSessionValid]) {
                [appDelegate.instagram authorize:[NSArray arrayWithObjects:@"basic", nil]];
            }
            [segue.destinationViewController setNikName:self.nikName.text];
        }
    }
}


#pragma - IGSessionDelegate

-(void)igDidLogin {
    NSLog(@"Instagram did login");
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.instagram.accessToken forKey:@"accessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)igSessionInvalidated {
    NSLog(@"Instagram session was invalidated");
}

@end;