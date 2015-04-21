//
//  VersionIntrospection.m
//  Pods
//
//  Created by Claus Weymann on 21/04/15.
//
//

#import "VersionIntrospection.h"
@interface VersionIntrospection()

@end

@implementation VersionIntrospection

@synthesize versionsForDependency = _versionsForDependency;

#pragma mark - Public
-(NSMutableDictionary *)versionsForDependency
{
    if (!_versionsForDependency) {
        _versionsForDependency = [NSMutableDictionary dictionary];
        [self parsePodfileLock];
    }
    return _versionsForDependency;
}

+ (VersionIntrospection*) sharedIntrospection {
    static VersionIntrospection* sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Private
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}
#pragma mark Parsing

-(void)parsePodfileLock
{
    NSError* error;
    NSURL* podfileLockURL = [[NSBundle mainBundle] URLForResource:@"Podfile" withExtension:@"lock"];
    NSString* content = [[NSString alloc] initWithContentsOfURL:podfileLockURL encoding:NSUTF8StringEncoding error:&error];
    if (!content) {
        NSLog(@"ERROR: failed to read Podfile.lock, make sure you have added it to the target in your projekt (this needs to be done manually at the moment). %@", error);
        return;
    }
    //NSLog(@"Podfile.lock:\n\t%@",content);
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:content];
    //[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@","]];
    NSString* podsSecition;
    
    //ignore anything Before PODS:
    BOOL success = [scanner scanUpToString:@"PODS:" intoString:nil];
    //read anything Before DEPENDENCIES:
    success = [scanner scanUpToString:@"DEPENDENCIES:" intoString:&podsSecition];
    
    if (success)
    {
        //NSLog(@"\n\nPodsSection:\n\t%@",podsSecition);
        [self parsePodsSection:podsSecition];
    }
    else
    {
        NSLog(@"WARNING: could not find PODS: section in Podfile.lock");
    }

}


-(void)parsePodsSection:(NSString*)podsSection
{
    NSArray* podsSectionLines = [podsSection componentsSeparatedByString:@"\n"];
    for (NSString* entry in podsSectionLines) {
        [self parsePodsEntry:entry];
    }
    
}

-(void)parsePodsEntry:(NSString*)podsEntry
{
    NSArray* podsEntryComponents = [podsEntry componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ()"]];
    //NSLog(@"podsEntryComponents: %@", podsEntryComponents);
    if ([podsEntryComponents count] == 7) {
        NSString* dependency = podsEntryComponents[3];
        NSString* version = podsEntryComponents[5];
        if (version && dependency) {
            self.versionsForDependency[dependency] = version;
        }
    }
}



@end
