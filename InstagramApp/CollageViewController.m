//
//  CollageViewController.m
//  InstagramApp
//
//  Created by Виктория on 04.02.15.
//  Copyright (c) 2015 Виктория. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "CollageViewController.h"

@interface CollageViewController () <MFMailComposeViewControllerDelegate>
{
    NSArray *imageArray;
}
@property (weak, nonatomic) IBOutlet UIImageView *collageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@end

@implementation CollageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([imageArray count] > 0) {
        CGSize size = CGSizeMake(_collageView.frame.size.width, _collageView.frame.size.height);
        CGFloat width = _collageView.frame.size.width;
        CGFloat height = _collageView.frame.size.height;
        CGFloat x = 0;
        CGFloat y = 0;
        
        UIGraphicsBeginImageContextWithOptions(size, NO, 0);
        for (int i = 1; i <= imageArray.count; i++) {
            if (imageArray.count >= i+1) {
                if (width == height) {
                    width /= 2;
                    x = width;
                    y = 0;
                } else {
                    height /= 2;
                    x = 0;
                    y = height;
                }
            } else {
                x = 0;
                y = 0;
            }
            NSURL *imgURL=[NSURL URLWithString:imageArray[i-1]];
            NSData *imgData=[NSData dataWithContentsOfURL:imgURL];
            [[UIImage imageWithData:imgData] drawInRect:CGRectMake(x, y, width, height)];
        }
        UIImage *finalImage =  UIGraphicsGetImageFromCurrentImageContext();
        _collageView.image = finalImage;
        UIGraphicsEndImageContext();
    }
}

- (IBAction)emailButtonPushed:(id)sender {
    
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        [mailCont setSubject:@"Your email"];
        [mailCont setMessageBody:[@"Your body for this message is " stringByAppendingString:@" this is awesome"] isHTML:NO];
        NSData *imageData = UIImagePNGRepresentation(_collageView.image);
        [mailCont addAttachmentData:imageData mimeType:@"image/png" fileName:@"Collage"];
        [self presentViewController:mailCont animated:YES completion:nil];
    }

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    //handle any error
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)setArrayOfImage:(NSArray *)arrayOfImage {
    imageArray = arrayOfImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
