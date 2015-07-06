//
//  DependencyInformation.m
//  Pods
//
//  Created by Claus Weymann on 16/06/15.
//
//

#import "DependencyInformation.h"

@implementation DependencyInformation
- (instancetype)init
{
    self = [super init];
    if (self) {
        _order = NSUIntegerMax;
    }
    return self;
}

-(NSComparisonResult)compare:(DependencyInformation *)dependencyInformation
{
    if([dependencyInformation isKindOfClass:[DependencyInformation class]])
    {
        if(self.order == dependencyInformation.order)
        {
            return [self.name compare:dependencyInformation.name];
        }
        return self.order < dependencyInformation.order ? NSOrderedAscending : NSOrderedDescending;
    }
    return NSOrderedAscending;
}
@end
