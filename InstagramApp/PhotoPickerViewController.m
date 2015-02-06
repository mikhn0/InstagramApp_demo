//
//  PhotoPickerViewController.m
//  InstagramApp
//
//  Created by Виктория on 03.02.15.
//  Copyright (c) 2015 Виктория. All rights reserved.
//

#import "PhotoPickerViewController.h"
#import "PhotoCollectionViewCell.h"
#import "AppDelegate.h"
#import "CollageViewController.h"

@interface PhotoPickerViewController ()
{
    NSMutableArray *selectedPhotos;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
- (IBAction)shareButtonTouched:(id)sender;
- (IBAction)logoutButtonTouched:(id)sender;

@end

@implementation PhotoPickerViewController

@synthesize data = _data;

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedPhotos = [NSMutableArray new];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"My photos";
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *separateAccessToken = [appDelegate.instagram.accessToken componentsSeparatedByString:@"."];
    NSUInteger userID = (separateAccessToken.count > 0) ? [separateAccessToken[0] integerValue] : 0;
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"users/%lu/media/recent",(unsigned long)userID], @"method", nil];
    [appDelegate.instagram requestWithParams:params
                                    delegate:self];
    self.collectionView.allowsMultipleSelection = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *photoCellIdentifier = @"CellPhoto";
    PhotoCollectionViewCell *photoCollectionCell = (PhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:photoCellIdentifier forIndexPath:indexPath];
    
    NSURL *imgURL=[NSURL URLWithString:[[self getImageData:indexPath] objectForKey:@"url"]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imgData=[NSData dataWithContentsOfURL:imgURL];
        UIImage *thumbImage = [UIImage imageWithData:imgData];
        dispatch_sync(dispatch_get_main_queue(), ^{
            photoCollectionCell.backgroundColor = [UIColor colorWithPatternImage:thumbImage];
            photoCollectionCell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected_photo"]];
        });
    });
    return photoCollectionCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *datasetCell = [collectionView cellForItemAtIndexPath:indexPath];
    datasetCell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected_photo"]];
    NSString *selectedPhoto = [[self getImageData:indexPath] objectForKey:@"url"];
    [selectedPhotos addObject:selectedPhoto];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *deSelectedPhoto = [[self getImageData:indexPath] objectForKey:@"url"];
    [selectedPhotos removeObject:deSelectedPhoto];
}

- (NSDictionary *)getImageData:(NSIndexPath *)indexPath {
    return (NSDictionary *)[[[self.data objectAtIndex:indexPath.row] objectForKey:@"images"] objectForKey:@"thumbnail"];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue: %@", segue.identifier);
    
    if ([segue.identifier isEqualToString:@"showCollage"]) {
        [segue.destinationViewController setArrayOfImage:selectedPhotos];
    }
}

- (IBAction)shareButtonTouched:(id)sender {
        for(NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
            [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        }
    
        [selectedPhotos removeAllObjects];

        self.collectionView.allowsMultipleSelection = NO;
        [self.shareButton setStyle:UIBarButtonItemStylePlain];
}

- (IBAction)logoutButtonTouched:(id)sender {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.instagram logout];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - IGRequestDelegate

- (void)request:(IGRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Instagram did fail: %@", error);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)request:(IGRequest *)request didLoad:(id)result {
    NSLog(@"Instagram did load: %@", result);
    self.data = (NSArray*)[result objectForKey:@"data"];
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
}

@end
