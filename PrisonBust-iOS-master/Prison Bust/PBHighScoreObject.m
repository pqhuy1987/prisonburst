//
//  PBHighScoreObject.m
//  Prison Bust
//
//  Created by Mac Admin on 5/20/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBHighScoreObject.h"

@implementation PBHighScoreObject

- (instancetype)scoreWithDate:(NSString *)date andScore:(int)score {
    PBHighScoreObject *obj = [PBHighScoreObject new];
    obj.score = score;
    obj.scoreDate = date;
    return obj;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self scoreWithDate:self.scoreDate andScore:self.score];
    if(self ) {
        _score = [aDecoder decodeIntForKey:@"score"];
        _scoreDate = [aDecoder decodeObjectForKey:@"scoreDate"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.score forKey:@"score"];
    [aCoder encodeObject:self.scoreDate forKey:@"scoreDate"];
}

- (NSString *)scoreDate {
    if(!_scoreDate) {
        _scoreDate = [self dateToString:[NSDate date]];
    }
    return _scoreDate;
}

- (NSString *)description {
    NSString *description = @"";
    if(_score < 100) {
        description = [NSString stringWithFormat:@"%1.0f                 %@" , _score , _scoreDate];
    } else if(_score > 99 && _score < 1000) {
        description = [NSString stringWithFormat:@"%1.0f                %@" , _score , _scoreDate];
    } else {
        description = [NSString stringWithFormat:@"%1.0f               %@" , _score , _scoreDate];
    }
    return description;
}

- (NSString *)dateToString:(NSDate *)date {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
    });
    
    return  [dateFormatter stringFromDate:date];
}

+ (NSArray *)compareHighScores:(NSArray *)unorderedArray {
    if(unorderedArray.count < 2) {
        return [NSMutableArray arrayWithArray:unorderedArray];
    }
    
    NSSortDescriptor *scoreSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"score" ascending:NO];
    NSArray *sortDescriptor = [NSArray arrayWithObject:scoreSortDescriptor];
    NSMutableArray *orderedArray = [[unorderedArray sortedArrayUsingDescriptors:sortDescriptor] mutableCopy];

    if(orderedArray.count > 5) {
        [orderedArray removeObjectAtIndex:orderedArray.count - 1];
    }
    
    return orderedArray;
}
@end
