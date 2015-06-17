//
//  VersionIntrospection.m
//  Pods
//
//  Created by Claus Weymann on 21/04/15.
//
//

#import "VersionIntrospection.h"
#import "DependencyInformation.h"

@interface VersionIntrospection()

@property (nonatomic,strong) NSString* podfileLockContent;

@end

@implementation VersionIntrospection

@synthesize versionsForDependency = _versionsForDependency;
@synthesize checksumForDependency = _checksumForDependency;
@synthesize versionInformation = _versionInformation;

#pragma mark - Public

-(NSMutableDictionary *)versionsForDependency
{
    if (!_versionsForDependency) {
        [self fillDependencyInformation];
    }
    return _versionsForDependency;
}

-(NSMutableDictionary *)checksumForDependency
{
    if (!_checksumForDependency) {
        [self fillDependencyInformation];
    }
    return _checksumForDependency;
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

-(BOOL)fillDependencyInformation
{
    _checksumForDependency = [NSMutableDictionary dictionary];
    _versionsForDependency = [NSMutableDictionary dictionary];
    
    NSString* content = self.podfileLockContent;
    if (!content || [content length] == 0) {
        NSLog(@"ERROR: no content to parse");
        return NO;
    }
    //NSLog(@"Podfile.lock:\n\t%@",content);
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:content];
    //[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@","]];
    NSString* podsSection;
    NSString* checksumSection;
    
    //ignore anything Before PODS:
    BOOL success = [scanner scanUpToString:@"PODS:" intoString:nil];
    //read anything Before DEPENDENCIES:
    success = [scanner scanUpToString:@"DEPENDENCIES:" intoString:&podsSection];
    [scanner scanUpToString:@"SPEC CHECKSUMS" intoString:nil];//ingore evryting before checksum
    success = success && [scanner scanUpToString:@"COCOAPODS" intoString:&checksumSection];
    
    if (success)
    {
        //NSLog(@"\n\nPodsSection:\n\t%@",podsSection);
        success = [self parsePodsSection:podsSection] & [self parseChecksumSection:checksumSection];
    }
    else
    {
        NSLog(@"WARNING: could not find PODS and/or CHECKSUM sections in Podfile.lock");
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
    if ([podsEntryComponents count] > 1) {
        BOOL foundName = NO;
        NSString* dependency;
        NSString* version;
        for (NSString* component in podsEntryComponents) {
            if ([component length] == 0) continue;
            if ([component isEqualToString:@"-"]) continue;
            if ([component isEqualToString:@":"]) continue;
            if (!foundName) {
                dependency = component;
                foundName = YES;
            }
            else
            {
                version = component;
            }
        }

        if ([version length] > 0 && [dependency length] > 0) {
            self.versionsForDependency[dependency] = version;
            return YES;
        }
    }
    if ([podsEntryComponents count] == 1) {
        return [podsEntryComponents.firstObject isEqualToString:@"PODS:"] || [podsEntryComponents.firstObject length] == 0;
    }
    return NO;
}

-(BOOL)parseChecksumSection:(NSString*)checksumSection
{
    BOOL success = YES;
    NSArray* podsSectionLines = [checksumSection componentsSeparatedByString:@"\n"];
    for (NSString* entry in podsSectionLines) {
        success = success & [self parseChecksumEntry:entry];
    }
    return success;
}
-(BOOL)parseChecksumEntry:(NSString*)checksumEntry
{
    NSArray* podsEntryComponents = [checksumEntry componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    //NSLog(@"podsEntryComponents: %@", podsEntryComponents);
    if ([podsEntryComponents count] == 2) {
        NSString* dependency = [podsEntryComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* checksum = [podsEntryComponents[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([checksum length] > 0 && [dependency length] > 0) {
            self.checksumForDependency[dependency] = checksum;
            return YES;
        }
        else
        {
            return [podsEntryComponents.firstObject isEqualToString:@"SPEC CHECKSUMS"];
        }
    }
    return NO;
}

-(NSMutableDictionary *)versionInformation
{
    if (!_versionInformation) {
        _versionInformation = [NSMutableDictionary dictionary];
        
        for (NSString* dependency in [self.versionsForDependency allKeys]) {
            DependencyInformation* dependencyInfo = _versionInformation[dependency];
            if (!dependencyInfo) {
                dependencyInfo = [[DependencyInformation alloc] init];
                dependencyInfo.name = dependency;
                _versionInformation[dependency] = dependencyInfo;
            }
            dependencyInfo.version = self.versionsForDependency[dependency];
        }
        
        for (NSString* dependency in [self.checksumForDependency allKeys]) {
            DependencyInformation* dependencyInfo = _versionInformation[dependency];
            if (!dependencyInfo) {
                dependencyInfo = [[DependencyInformation alloc] init];
                dependencyInfo.name = dependency;
                _versionInformation[dependency] = dependencyInfo;
            }
            dependencyInfo.gitHash = self.checksumForDependency[dependency];
        }
        
        for (NSString* dependency in [self.explicitDependencyOrder allKeys]) {
            DependencyInformation* dependencyInfo = _versionInformation[dependency];
            if (dependencyInfo) {
                dependencyInfo.order = [self.explicitDependencyOrder[dependency] unsignedIntegerValue];
            }
        }
        
        DependencyInformation* appInfo = [DependencyInformation new];
        appInfo.name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
        appInfo.version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        appInfo.order = 0;
        appInfo.gitHash = @"AppVersion";
        _versionInformation[[NSString stringWithFormat:@"%@ ",appInfo.name]] = appInfo;//store Under name + SPACE to avoid overriding dependecy with same name (frequently the case with pod sample projects )
    }
    return _versionInformation;
}

@end
