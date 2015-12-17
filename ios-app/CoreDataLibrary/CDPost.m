//
//  CDPost.m
//  ios-app
//
//  Created by Qingwei Lan on 11/8/15.
//  Copyright © 2015 Morning Sign Out Incorporated. All rights reserved.
//

#import "CDPost.h"
#import "CDAuthor.h"
#import "CDTag.h"
#import "CDCategory.h"
#import "Post.h"

@implementation CDPost

+ (CDPost *)postWithPost:(Post *)post
  inManagedObjectContext:(NSManagedObjectContext *)context
{
    CDPost *nPost = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDPost"];
    request.predicate = [NSPredicate predicateWithFormat:@"identity ==[c] %d", post.ID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || matches.count > 1) {
        NSLog(@"Error when fetching CDPost");
    } else if (matches.count == 1) {
        NSLog(@"Core Data found Post: %d", post.ID);
        nPost = [matches firstObject];
    } else {
        NSLog(@"Core Data didn't find Post, inserting Post: %d", post.ID);
        nPost = [NSEntityDescription insertNewObjectForEntityForName:@"CDPost" inManagedObjectContext:context];
        nPost.identity = [NSString stringWithFormat:@"%d", post.ID];
        nPost.bookmarked = NO;
        nPost.body = post.body;
        nPost.date = post.date;
        nPost.excerpt = post.excerpt;
        nPost.fullCoverImageURL = post.fullCoverImageURL;
        nPost.thumbnailCoverImageURL = post.thumbnailCoverImageURL;
        nPost.title = post.title;
        nPost.url = post.url;
        nPost.authoredBy = [CDAuthor authorWithAuthor:post.author inManagedObjectContext:context];
        for (NSString *tag in post.tags) {
            [nPost addTagsObject:[CDTag tagWithName:tag inManagedObjectContext:context]];
        }
        for (NSString *category in post.category) {
            [nPost addCategoriesObject:[CDCategory categoryWithName:category inManagedObjectContext:context]];
        }
    }
    
    return nPost;
}

+ (void)deletePostWithID:(NSString *)identity
fromManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDPost"];
    request.predicate = [NSPredicate predicateWithFormat:@"identity ==[c] %@", identity];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || matches.count > 1) {
        NSLog(@"Error when fetching CDPost");
    } else if (matches.count == 1) {
        NSLog(@"Core Data found Post to delete: %@", identity);
        NSManagedObject *object = [matches firstObject];
        [context deleteObject:object];
    } else {
        NSLog(@"Core Data didn't find Post: %@", identity);
    }
}

+ (void)addBookmarkPost:(Post *)post
 toManagedObjectContext:(NSManagedObjectContext *)context
{
    CDPost *nPost = [CDPost postWithPost:post inManagedObjectContext:context];
    if (nPost) {
        nPost.bookmarked = YES;
    }
}

+ (void)removeBookmarkPostWithID:(NSString *)identity
        fromManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDPost"];
    request.predicate = [NSPredicate predicateWithFormat:@"identity ==[c] %@", identity];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || matches.count > 1) {
        NSLog(@"Error when fetching CDPost");
    } else if (matches.count == 1) {
        NSLog(@"Core Data found Bookmarked Post to delete: %@", identity);
        CDPost *object = [matches firstObject];
        object.bookmarked = NO;
    } else {
        NSLog(@"Core Data didn't find Post: %@", identity);
    }
}

@end
