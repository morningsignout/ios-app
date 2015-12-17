//
//  BookmarkTableViewController.m
//  ios-app
//
//  Created by Shannon Phu on 9/15/15.
//  Copyright (c) 2015 Morning Sign Out Incorporated. All rights reserved.
//

#import "BookmarkTableViewController.h"
#import "BookmarkTableViewCell.h"
#import <UIImageView+AFNetworking.h>
#import "DropdownNavigationController.h"
#import "FullPostViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "CDPost.h"
#import "CDAuthor.h"
#import "CDTag.h"
#import "CDCategory.h"
#import "DataParser.h"

#define CELL_IDENTIFIER @"bookmarkCell"
static NSString * const SEGUE_IDENTIFIER = @"viewPost";

@interface BookmarkTableViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
{
    NSDictionary *attributes;
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) AppDelegate *delegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation BookmarkTableViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    // Set up style and attributes
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.firstLineHeadIndent = 10.0;
    style.headIndent = 10;
    style.tailIndent = 0;
    attributes = @{NSParagraphStyleAttributeName : style};
    
    // Set ManagedObjectContext
    _delegate = [[UIApplication sharedApplication] delegate];
    if ([self.delegate performSelector:@selector(managedObjectContext)])
        _context = [self.delegate managedObjectContext];
    else
        _context = nil;
    
    // Perform fetch
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error])
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
}

- (void)viewWillAppear:(BOOL)animated
{
    DropdownNavigationController *navVC = (DropdownNavigationController *)self.parentViewController.parentViewController;
    navVC.titleLabel.text = @"Bookmarks";
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController)
        return _fetchedResultsController;
    
    /* Initialize the fetchedResultsController */
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDPost"];
    request.predicate = [NSPredicate predicateWithFormat:@"bookmarked == 1"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"identity" ascending:YES selector:@selector(localizedStandardCompare:)]];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                          managedObjectContext:self.context
                                                                            sectionNameKeyPath:nil
                                                                                     cacheName:nil];
    frc.delegate = self;
    self.fetchedResultsController = frc;
    
    return _fetchedResultsController;
}

#pragma mark - UITableViewDataSource

- (void)configureCell:(BookmarkTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (cell) {
        CDPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:post.title attributes:attributes];
        NSAttributedString *excerpt = [[NSAttributedString alloc] initWithString:post.excerpt attributes:attributes];
        cell.titleLabel.attributedText = title;
        cell.excerptLabel.attributedText = excerpt;
        cell.imageView.image = nil;
        
        NSURLRequest *requestLeft = [NSURLRequest requestWithURL:[NSURL URLWithString:post.fullCoverImageURL]];
        [cell.imageView setImageWithURLRequest:requestLeft placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            cell.imageView.image = image;
        } failure:nil];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookmarkTableViewCell *cell = (BookmarkTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Actions

- (IBAction)removeFromBookmarks:(id)sender
{    
    // Get index of cell
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    // Remove from core data and NSMutableArray
    CDPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [CDPost removeBookmarkPostWithID:post.identity fromManagedObjectContext:self.context];
    [self.delegate saveContext];
}

- (Author *)authorFromCDAuthor:(CDAuthor *)cAuthor
{
    Author *author = nil;
    
    if (cAuthor) {
        author = [[Author alloc] initWith:[cAuthor.identity intValue]
                                     Name:cAuthor.name
                                    About:cAuthor.about
                                 AndEmail:cAuthor.email];
    }
    
    return author;
}

- (Post *)postFromCDPost:(CDPost *)cPost
{
    Post *post = nil;
    
    if (cPost) {
        Author *author = [self authorFromCDAuthor:cPost.authoredBy];
        NSMutableArray *categories = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *tags = [[NSMutableArray alloc] initWithCapacity:0];
        for (CDCategory *category in cPost.categories)
            [categories addObject:category.name];
        for (CDTag *tag in cPost.tags)
            [tags addObject:tag.name];
        
        post = [[Post alloc] initWith:[cPost.identity intValue]
                                Title:cPost.title
                               Author:author
                                 Body:cPost.body
                                  URL:cPost.url
                              Excerpt:cPost.excerpt
                                 Date:cPost.date
                             Category:categories
                                 Tags:tags
                  ThumbnailCoverImage:cPost.thumbnailCoverImageURL
                       FullCoverImage:cPost.fullCoverImageURL];
    }
    
    return post;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:SEGUE_IDENTIFIER]
        && [segue.destinationViewController isKindOfClass:[FullPostViewController class]]) {
        FullPostViewController *postVC = segue.destinationViewController;
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        CDPost *cPost = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
        Post *post = [self postFromCDPost:cPost];
        postVC.post = post;
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(BookmarkTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default: break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications,
    // so tell the table view to process all updates.
    [self.tableView endUpdates];
}

@end
