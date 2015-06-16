//
//  DependencyInformation.h
//  Pods
//
//  Created by Claus Weymann on 16/06/15.
//
//

#import <Foundation/Foundation.h>

@interface DependencyInformation : NSObject

@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) NSString* version;
@property (nonatomic,strong) NSString* gitHash;
@property (nonatomic,assign) NSUInteger order;

- (NSComparisonResult)compare:(DependencyInformation *)dependencyInformation;

@end
