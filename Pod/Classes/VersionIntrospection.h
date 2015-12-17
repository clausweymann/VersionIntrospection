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
@property (nonatomic, strong, readonly) NSMutableDictionary* checksumForDependency;
@property (nonatomic, strong, readonly) NSMutableDictionary* licenseForDependency;
@property (nonatomic, strong, readonly) NSMutableDictionary* versionInformation;
@property (nonatomic, strong, readonly) NSMutableDictionary* gitHashForExternalDependency;

@property (nonatomic, strong) NSDictionary* explicitDependencyOrder;

+ (VersionIntrospection*) sharedIntrospection;

@end
