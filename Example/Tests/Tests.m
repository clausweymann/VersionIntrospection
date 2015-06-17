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
-(BOOL)fillDependencyInformation;
@end

SpecBegin(InitialSpecs)

describe(@"parser", ^{
    
    it(@"can't parse empty file", ^{
        [VersionIntrospection sharedIntrospection].podfileLockContent = @"";
        id versionForDependency = [VersionIntrospection sharedIntrospection].versionsForDependency;
        expect(versionForDependency).beAKindOf([NSDictionary class]);
        expect([versionForDependency count]).to.equal(0);
    });
    
    it(@"can parse sample file", ^{
        NSURL* sampleFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"Podfile_lock_parsing-sorting" withExtension:@"txt"];
        NSError* error;
        NSString* sampleFileContent = [NSString stringWithContentsOfURL:sampleFileURL encoding:NSUTF8StringEncoding error:&error];

        [VersionIntrospection sharedIntrospection].podfileLockContent = sampleFileContent;
        expect(sampleFileContent).notTo.beNil();
        [[VersionIntrospection sharedIntrospection] fillDependencyInformation];
        id versionForDependency = [VersionIntrospection sharedIntrospection].versionsForDependency;
        expect(versionForDependency).beAKindOf([NSDictionary class]);
        expect([versionForDependency count]).to.equal(3);
    });
});


SpecEnd
