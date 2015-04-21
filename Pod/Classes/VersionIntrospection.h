//
//  VersionIntrospection.h
//  Pods
//
//  Created by Claus Weymann on 21/04/15.
//
//

#import <Foundation/Foundation.h>

@interface VersionIntrospection : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary* versionsForDependency;

+ (VersionIntrospection*) sharedIntrospection;

@end
