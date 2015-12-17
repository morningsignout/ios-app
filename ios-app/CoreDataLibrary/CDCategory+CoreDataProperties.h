//
//  CDCategory+CoreDataProperties.h
//  ios-app
//
//  Created by Qingwei Lan on 11/8/15.
//  Copyright © 2015 Morning Sign Out Incorporated. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDCategory.h"

@class CDPost;

NS_ASSUME_NONNULL_BEGIN

@interface CDCategory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<CDPost *> *posts;

@end

@interface CDCategory (CoreDataGeneratedAccessors)

- (void)addPostsObject:(CDPost *)value;
- (void)removePostsObject:(CDPost *)value;
- (void)addPosts:(NSSet<CDPost *> *)values;
- (void)removePosts:(NSSet<CDPost *> *)values;

@end

NS_ASSUME_NONNULL_END
