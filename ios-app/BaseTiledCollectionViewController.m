//
//  BaseTiledCollectionViewController.m
//  ios-app
//
//  Created by Shannon Phu on 9/9/15.
//  Copyright (c) 2015 Morning Sign Out Incorporated. All rights reserved.
//

#import "BaseTiledCollectionViewController.h"
#import "TileCollectionViewCellA.h"
#import "TileCollectionViewCellB.h"
#import "DataParser.h"
#import <UIImageView+AFNetworking.h>
#import "FullPostViewController.h"
#import "BaseTileCollectionViewCell.h"
#import "TileCollectionViewCellC.h"
#import "FeaturedTileCollectionViewCell.h"

#define CELL_IDENTIFIER @"TileCell"
#define CELL_IDENTIFIER_B @"TileCell2"
#define CELL_IDENTIFIER_C @"TileCell3"
#define HEADER_IDENTIFIER @"TopFeatured"

static NSString * const SEGUE_IDENTIFIER = @"viewPost";
static CGFloat marginFromTop = 50.0f;

@interface BaseTiledCollectionViewController () {
    int page;
    Post *seguePost;
    CGSize tileHeight;
}
@property (nonatomic, strong) NSArray *cellSizes;
@property (strong, nonatomic) NSArray *posts;

@end

@implementation BaseTiledCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    
    // Start loading data from JSON page 1
    page = 1;
    
    
    self.posts = [self getDataForPage:page];
    
    tileHeight = CGSizeMake(1, 1.5);
}

- (void)viewWillAppear:(BOOL)animated {
    seguePost = nil;
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateLayoutForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateLayoutForOrientation:toInterfaceOrientation];
}

- (void)updateLayoutForOrientation:(UIInterfaceOrientation)orientation {
    CHTCollectionViewWaterfallLayout *layout =
    (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    layout.columnCount = UIInterfaceOrientationIsPortrait(orientation) ? 2 : 3;
}

- (void)dealloc {
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

- (NSArray *)getDataForPage:(int)pageNum {
    int p = pageNum;
    if (pageNum <= 0 || pageNum > self.posts.count) {
        p = 1;
    }
    return [DataParser DataForFeaturedPostsWithPageNumber:p];
}

#pragma mark - Accessors

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
        
        layout.sectionInset = UIEdgeInsetsMake(10,10,10,10);
        layout.minimumColumnSpacing = 10.0f;
        layout.minimumInteritemSpacing = 10.0f;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, marginFromTop, self.view.bounds.size.width, self.view.bounds.size.height - marginFromTop) collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.7];
        [_collectionView registerClass:[TileCollectionViewCellA class]
            forCellWithReuseIdentifier:CELL_IDENTIFIER];
        [_collectionView registerClass:[TileCollectionViewCellB class]
            forCellWithReuseIdentifier:CELL_IDENTIFIER_B];
        [_collectionView registerClass:[TileCollectionViewCellC class]
            forCellWithReuseIdentifier:CELL_IDENTIFIER_C];
        
        if ([self isFeaturedPage]) {
            layout.headerHeight = self.view.frame.size.height / 1.5;
            [_collectionView registerClass:[FeaturedTileCollectionViewCell class]
                forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader
                       withReuseIdentifier:HEADER_IDENTIFIER];
        }
    }
    return _collectionView;
}

- (BOOL)isFeaturedPage {
    return NO;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.posts.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item % 3 == 0) {
        TileCollectionViewCellA *cellA = (TileCollectionViewCellA *)[self setTileOfClass:@"TileCollectionViewCellA" WithIndexPath:indexPath];
        return cellA;
        
    } else if (indexPath.item % 3 == 1) {
        TileCollectionViewCellB *cellB = (TileCollectionViewCellB *)[self setTileOfClass:@"TileCollectionViewCellB" WithIndexPath:indexPath];
        return cellB;
    } else {
        TileCollectionViewCellC *cellC = (TileCollectionViewCellC *)[self setTileOfClass:@"TileCollectionViewCellC" WithIndexPath:indexPath];
        return cellC;
    }
    
}

- (BaseTileCollectionViewCell *)setTileOfClass:(NSString *)cellClass WithIndexPath:(NSIndexPath *)indexPath {
    
    __weak BaseTileCollectionViewCell *cell;
    
    
    if ([cellClass isEqualToString:@"TileCollectionViewCellA"]) {
        cell = (TileCollectionViewCellA *)[self.collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    } else if ([cellClass isEqualToString:@"TileCollectionViewCellB"]) {
        cell = (TileCollectionViewCellB *)[self.collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER_B forIndexPath:indexPath];
    } else if ([cellClass isEqualToString:@"TileCollectionViewCellC"]) {
        cell = (TileCollectionViewCellC *)[self.collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER_C forIndexPath:indexPath];
    }
    
    Post *post = [self.posts objectAtIndex:indexPath.item];
    
    NSURLRequest *requestLeft = [NSURLRequest requestWithURL:[NSURL URLWithString:post.thumbnailCoverImageURL]];
    
    cell.title.text = post.title;
    [cell.imageView setImageWithURLRequest:requestLeft placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        cell.imageView.image = image;
    } failure:nil];
    
    return cell;
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return tileHeight;
}

@end
