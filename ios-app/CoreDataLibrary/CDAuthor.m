//
//  CDAuthor.m
//  ios-app
//
//  Created by Qingwei Lan on 11/8/15.
//  Copyright © 2015 Morning Sign Out Incorporated. All rights reserved.
//

#import "CDAuthor.h"
#import "Author.h"

@implementation CDAuthor

+ (CDAuthor *)authorWithAuthor:(Author *)author
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    CDAuthor *nAuthor = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDAuthor"];
    request.predicate = [NSPredicate predicateWithFormat:@"identity == %d", author.ID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || matches.count > 1) {
        NSLog(@"Error when fetching CDAuthor");
    } else if (matches.count == 1) {
        nAuthor = [matches firstObject];
    } else {
        nAuthor = [NSEntityDescription insertNewObjectForEntityForName:@"CDAuthor" inManagedObjectContext:context];
        nAuthor.identity = author.ID;
        nAuthor.name = author.name;
        nAuthor.about = author.about;
        nAuthor.email = author.email;
    }
    
    return nAuthor;
}

@end
