//
//  VersionIntrospectionTests.m
//  VersionIntrospectionTests
//
//  Created by Claus Weymann on 04/21/2015.
//  Copyright (c) 2014 Claus Weymann. All rights reserved.
//
#import <VersionIntrospection/VersionIntrospection.h>

@interface VersionIntrospection(Testing)

@property (nonatomic,strong) NSString* podfileLockContent;

@end

SpecBegin(InitialSpecs)

describe(@"parser", ^{
    
    it(@"can't parse empty file", ^{
        [VersionIntrospection sharedIntrospection].podfileLockContent = @"";
        id versionForDependency = [VersionIntrospection sharedIntrospection].versionsForDependency;
        expect(versionForDependency).beAKindOf([NSDictionary class]);
        expect([versionForDependency count]).to.equal(0);
    });
    
});

SpecEnd
