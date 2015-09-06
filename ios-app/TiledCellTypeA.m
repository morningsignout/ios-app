//
//  TiledCellTypeA.m
//  ios-app
//
//  Created by Shannon Phu on 9/4/15.
//  Copyright (c) 2015 Morning Sign Out Incorporated. All rights reserved.
//

#import "TiledCellTypeA.h"
#import "Tile.h"

static const CGFloat margin = 10.0f;

@implementation TiledCellTypeA

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor blueColor];
    _tileLeft = [[Tile alloc] initWithFrame:CGRectMake(margin, margin, 2 * (self.frame.size.width / 3 - margin), self.frame.size.height - 2 * margin)];
    _tileLeft.title.text = @"hi";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
