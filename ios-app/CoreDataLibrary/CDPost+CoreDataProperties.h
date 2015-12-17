//
//  CDPost+CoreDataProperties.h
//  ios-app
//
//  Created by Qingwei Lan on 12/16/15.
//  Copyright © 2015 Morning Sign Out Incorporated. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDPost.h"

@class CDAuthor;
@class CDTag;
@class CDCategory;

NS_ASSUME_NONNULL_BEGIN

@interface CDPost (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *body;
@property (nonatomic) BOOL bookmarked;
@property (nullable, nonatomic, retain) NSString *date;
@property (nullable, nonatomic, retain) NSString *excerpt;
@property (nullable, nonatomic, retain) NSString *fullCoverImageURL;
@property (nullable, nonatomic, retain) NSString *identity;
@property (nullable, nonatomic, retain) NSString *thumbnailCoverImageURL;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) CDAuthor *authoredBy;
@property (nullable, nonatomic, retain) NSSet<CDCategory *> *categories;
@property (nullable, nonatomic, retain) NSSet<CDTag *> *tags;

@end

@interface CDPost (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(CDCategory *)value;
- (void)removeCategoriesObject:(CDCategory *)value;
- (void)addCategories:(NSSet<CDCategory *> *)values;
- (void)removeCategories:(NSSet<CDCategory *> *)values;

- (void)addTagsObject:(CDTag *)value;
- (void)removeTagsObject:(CDTag *)value;
- (void)addTags:(NSSet<CDTag *> *)values;
- (void)removeTags:(NSSet<CDTag *> *)values;

@end

NS_ASSUME_NONNULL_END
