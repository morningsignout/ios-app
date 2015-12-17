//
//  CDPost.h
//  ios-app
//
//  Created by Qingwei Lan on 11/8/15.
//  Copyright © 2015 Morning Sign Out Incorporated. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

NS_ASSUME_NONNULL_BEGIN

@interface CDPost : NSManagedObject

+ (CDPost *)postWithPost:(Post *)post
  inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)deletePostWithID:(NSString *)identity
fromManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)addBookmarkPost:(Post *)post
 toManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)removeBookmarkPostWithID:(NSString *)identity
        fromManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "CDPost+CoreDataProperties.h"
