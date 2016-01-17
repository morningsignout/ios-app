//
//  FeatureCollectionViewController.m
//  ios-app
//
//  Created by Shannon Phu on 9/8/15.
//  Copyright (c) 2015 Morning Sign Out Incorporated. All rights reserved.
//

#import "FeatureCollectionViewController.h"
#import "FeaturedTileCollectionViewCell.h"
#import "DataParser.h"
#import <UIImageView+AFNetworking.h>
#import "FullPostViewController.h"
#import "DropdownNavigationController.h"

#define HEADER_IDENTIFIER @"TopFeatured"
static NSString * const SEGUE_IDENTIFIER = @"viewPost";

@interface FeatureCollectionViewController ()
@property (strong, nonatomic) Post *topFeatured;
@property (nonatomic) bool end;
@end

@implementation FeatureCollectionViewController


#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Featured";
    self.end = false;
    
    self.topFeatured = [super getPostFromPosts:0];
    NSLog(@"bookmarked %d", self.topFeatured.isBookmarked);
    contentType = FEATURED;
    
    // Initialize Refresh Control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    // Configure Refresh Control
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    // Configure View Controller
    [self.collectionView addSubview:refreshControl];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    DropdownNavigationController *navVC = (DropdownNavigationController *)self.parentViewController.parentViewController;
    navVC.titleLabel.text = @"Featured";
    navVC.titleLabel.textColor = [UIColor kNavTextColor];
    navVC.navigationItem.title = @"Featured";
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - Accessors

- (BOOL)isFeaturedPage {
    return YES;
}

- (NSArray *)getDataForTypeOfView {
    NSMutableArray *data = [NSMutableArray arrayWithArray:[DataParser DataForFeaturedPostsWithPageNumber:self.page]];
    if (self.page == 1) {
        self.topFeatured = data.firstObject;
        //if([data count])
            [data removeObjectAtIndex:0];
        [data addObject:self.topFeatured];
    }
    return data;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:CHTCollectionElementKindSectionHeader]) {
        __weak FeaturedTileCollectionViewCell *reusableView =
        [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HEADER_IDENTIFIER forIndexPath:indexPath];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(showTopFeatured:)];
        
        [reusableView addGestureRecognizer:tap];
        
        reusableView.title.text = self.topFeatured.title;
        reusableView.excerpt.text = self.topFeatured.excerpt;
        
        NSURLRequest *requestLeft = [NSURLRequest requestWithURL:[NSURL URLWithString:self.topFeatured.fullCoverImageURL]];
        [reusableView.imageView setImageWithURLRequest:requestLeft placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            reusableView.imageView.image = image;
        } failure:nil];
        
        return reusableView;
    }
    
    return nil;
}

- (void)refresh:(id)sender {
    NSLog(@"Refreshing");
    
    dispatch_queue_t q = dispatch_queue_create("refresh latest", NULL);
    dispatch_async(q, ^{
        
        NSArray * refreshPosts = [self getDataForTypeOfView];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [(UIRefreshControl *)sender endRefreshing];
            
            [self refreshPosts:refreshPosts];
        });
    });
    
    
}

- (void) setEndOfPosts:(bool)set{
    self.end = set;
}

- (BOOL) getEndOfPosts{
    return self.end;
}

#pragma mark - Navigation

- (void)showTopFeatured:(UITapGestureRecognizer *)recognizer {
    self.topFeatured.isBookmarked = [CDPost isBookmarkedPost:[NSString stringWithFormat:@"%d", self.topFeatured.ID] inManagedObjectContext:self.delegate.managedObjectContext];
    NSLog(@"top featured bookmarked %d id %d", self.topFeatured.isBookmarked, self.topFeatured.ID);
    [self performSegueWithIdentifier:SEGUE_IDENTIFIER sender:self.topFeatured];
}


//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    if ([segue.identifier isEqualToString:SEGUE_IDENTIFIER] && [segue.destinationViewController isKindOfClass:[FullPostViewController class]]) {
//        FullPostViewController *postVC = segue.destinationViewController;
//        if ([sender isKindOfClass:[Post class]])
//            postVC.post = sender;
//        else
//            postVC.post = nil;
//    }
//}

- (void)didUpdateData:(CDPost *)object
{
    [super didUpdateData:object];
    NSLog(@"Called in FeatureCollectionViewController");
    self.topFeatured.isBookmarked = object.bookmarked;
}

- (BOOL)isFeatured
{
    return YES;
}

@end
