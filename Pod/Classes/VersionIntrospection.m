//
//  VersionIntrospection.m
//  Pods
//
//  Created by Claus Weymann on 21/04/15.
//
//

#import "VersionIntrospection.h"
@interface VersionIntrospection()

@property (nonatomic,strong) NSString* podfileLockContent;

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

-(NSString *)podfileLockContent
{
    if (!_podfileLockContent) {
        NSError* error;
        NSURL* podfileLockURL = [[NSBundle mainBundle] URLForResource:@"Podfile" withExtension:@"lock"];
        _podfileLockContent = [[NSString alloc] initWithContentsOfURL:podfileLockURL encoding:NSUTF8StringEncoding error:&error];
        if (!_podfileLockContent) {
            NSLog(@"ERROR: failed to read Podfile.lock, make sure you have added it to the target in your project (this needs to be done manually at the moment). %@", error);
            return nil;
        }

    }
    return _podfileLockContent;
}

#pragma mark Parsing

-(BOOL)parsePodfileLock
{
    NSString* content = self.podfileLockContent;
    if (!content || [content length] == 0) {
        NSLog(@"ERROR: no content to parse");
        return NO;
    }
    //NSLog(@"Podfile.lock:\n\t%@",content);
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:content];
    //[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@","]];
    NSString* podsSection;
    
    //ignore anything Before PODS:
    BOOL success = [scanner scanUpToString:@"PODS:" intoString:nil];
    //read anything Before DEPENDENCIES:
    success = [scanner scanUpToString:@"DEPENDENCIES:" intoString:&podsSection];
    
    if (success)
    {
        //NSLog(@"\n\nPodsSection:\n\t%@",podsSection);
        success = [self parsePodsSection:podsSection];
    }
    else
    {
        NSLog(@"WARNING: could not find PODS: section in Podfile.lock");
    }
    return success;
}


-(BOOL)parsePodsSection:(NSString*)podsSection
{
    BOOL success = YES;
    NSArray* podsSectionLines = [podsSection componentsSeparatedByString:@"\n"];
    for (NSString* entry in podsSectionLines) {
        success = success & [self parsePodsEntry:entry];
    }
    return success;
}

-(BOOL)parsePodsEntry:(NSString*)podsEntry
{
    NSArray* podsEntryComponents = [podsEntry componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ()"]];
    //NSLog(@"podsEntryComponents: %@", podsEntryComponents);
    if ([podsEntryComponents count] == 7) {
        NSString* dependency = podsEntryComponents[3];
        NSString* version = podsEntryComponents[5];
        if (version && dependency) {
            self.versionsForDependency[dependency] = version;
            return YES;
        }
    }
    if ([podsEntryComponents count] == 1) {
        return [podsEntryComponents.firstObject isEqualToString:@"PODS:"];
    }
    return NO;
}



@end
