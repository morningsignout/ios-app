//
//  Post.m
//  ios-app
//
//  Created by Shannon Phu on 8/31/15.
//  Copyright (c) 2015 Morning Sign Out Incorporated. All rights reserved.
//

#import "Post.h"
#import "Author.h"
#import "CDCategory.h"
#import "CDTag.h"

@implementation Post

- (instancetype)initWith:(int)ID
                   Title:(NSString *)title
                  Author:(Author *)author
                    Body:(NSString *)content
                     URL:(NSString *)URL
                 Excerpt:(NSString *)excerpt
                    Date:(NSString *)date
                Category:(NSArray *)category
                    Tags:(NSArray *)tags
     ThumbnailCoverImage:(NSString *)thumbnailURL
          FullCoverImage:(NSString *)fullURL {
    
    if(self = [super init]) {
        _ID = ID;
        _title = title;
        _author = author;
        _body =  content;
        _url = URL;
        _excerpt = excerpt;
        _date = date;
        _category = category;
        _tags = tags;
        _thumbnailCoverImageURL = thumbnailURL;
        _fullCoverImageURL = fullURL;
    }
    return self;
}

- (void)printInfo {
    NSLog(@"Title: %@", self.title);
    NSLog(@"Author Info");
    [self.author printInfo];
    NSLog(@"Content: %@", self.body);
    NSLog(@"URL: %@", self.url);
    NSLog(@"Excerpt: %@", self.excerpt);
    NSLog(@"Date: %@", self.date);
    
    for (NSString *category in self.category) {
        NSLog(@"Category: %@", category);
    }
    
    for (NSString *tag in self.tags) {
        NSLog(@"Tag: %@", tag);
    }
    
    NSLog(@"Thumbnail Cover Image URL: %@", self.thumbnailCoverImageURL);
    NSLog(@"Full Cover Image URL: %@", self.fullCoverImageURL);
}

+ (Post *)postFromCDPost:(CDPost *)cPost
{
    Post *post = nil;
    
    if (cPost) {
        Author *author = [Author authorFromCDAuthor:cPost.authoredBy];
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


@end
