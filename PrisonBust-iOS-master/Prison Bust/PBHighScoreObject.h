//
//  PBHighScoreObject.h
//  Prison Bust
//
//  Created by Mac Admin on 5/20/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBHighScoreObject : NSObject <NSCoding>
@property (nonatomic) double score;
@property (nonatomic, strong) NSString *scoreDate;

- (instancetype)scoreWithDate:(NSString *)date andScore:(int)score;
+ (NSMutableArray *)compareHighScores:(NSMutableArray *)unorderedArray; //returns sorted version of hso array

@end
