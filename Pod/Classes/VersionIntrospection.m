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
@property (nonatomic,strong) NSString* devpodGitHashes;
@property (nonatomic,strong) NSMutableDictionary* externalSources;
@end

@implementation VersionIntrospection

@synthesize versionsForDependency = _versionsForDependency;
@synthesize checksumForDependency = _checksumForDependency;
@synthesize versionInformation = _versionInformation;
@synthesize gitHashForExternalDependency = _gitHashForExternalDependency;

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

-(NSString*)devpodGitHashes
{
    if(!_devpodGitHashes)
    {
        NSError* error;
        NSURL* gitHashURL = [[NSBundle mainBundle] URLForResource:@"gitHash" withExtension:@"txt"];
        _devpodGitHashes = [[NSString alloc] initWithContentsOfURL:gitHashURL encoding:NSUTF8StringEncoding error:&error];
        if (!_devpodGitHashes) {
            NSLog(@"ERROR: failed to read gitHash.txt, make sure you generated it in the build phase. %@", error);
            return nil;
        }
    }
    return _devpodGitHashes;
}

#pragma mark Parsing

-(BOOL)fillDependencyInformation
{
    _checksumForDependency = [NSMutableDictionary dictionary];
    _versionsForDependency = [NSMutableDictionary dictionary];
    _externalSources = [NSMutableDictionary dictionary];
    
    NSString* content = self.podfileLockContent;
    if (!content || [content length] == 0) {
        NSLog(@"ERROR: no content to parse");
        return NO;
    }
    //NSLog(@"Podfile.lock:\n\t%@",content);
    NSArray* sections = [content componentsSeparatedByString:@"\n\n"];
    
    NSString* podsSection = [self sectionWithPrefix:@"PODS:" fromSections:sections];
    NSString* checksumSection  = [self sectionWithPrefix:@"SPEC CHECKSUMS:" fromSections:sections];
    NSString* externalDepenencySection = [self sectionWithPrefix:@"EXTERNAL SOURCES:" fromSections:sections];
    
    if (podsSection && checksumSection && externalDepenencySection)
    {
        return [self parsePodsSection:podsSection] & [self parseChecksumSection:checksumSection] & [self parseExternalSourceSection:externalDepenencySection];
    }
    else
    {
        NSLog(@"WARNING: could not find PODS and/or CHECKSUM sections in Podfile.lock");
    }
    return NO;
}
-(NSString*)sectionWithPrefix:(NSString*)prefix fromSections:(NSArray*)sections
{
    for (NSString* section in sections) {
        if ([section hasPrefix:prefix]) {
            return section;
        }
    }
    return nil;
}

-(BOOL)parsePodsSection:(NSString*)podsSection
{
    BOOL success = YES;
    NSArray* podsSectionLines = [podsSection componentsSeparatedByString:@"\n"];
    for (NSString* entry in podsSectionLines) {
        success &= [self parsePodsEntry:entry];
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
    NSArray* sectionLines = [checksumSection componentsSeparatedByString:@"\n"];
    for (NSString* entry in sectionLines) {
        success &= [self parseChecksumEntry:entry];
    }
    return success;
}

-(BOOL)parseEachEntryInSection:(NSString*)section seperatedBy:(NSString*)seperator withParseBlock:(BOOL(^)(NSString*))parseBlock
{
    BOOL success = YES;
    NSArray* sectionLines = [section componentsSeparatedByString:seperator];
    for (NSString* entry in sectionLines) {
        success &= parseBlock(entry);
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

-(BOOL)parseExternalSourceSection:(NSString*)externalSourceSection
{
    NSScanner *scanner = [[NSScanner alloc] initWithString:externalSourceSection];
    BOOL success = [scanner scanString:@"EXTERNAL SOURCES:\n" intoString:nil];
    NSString* dependencyName;
    NSString* dependencyPath;
    BOOL canParseExternalDepenency = YES;
    while (success && canParseExternalDepenency) {
        canParseExternalDepenency &= [scanner scanUpToString:@":path:" intoString:&dependencyName];
        [scanner scanString:@":path:" intoString:nil];
        canParseExternalDepenency &= [scanner scanUpToString:@"\n" intoString:&dependencyPath];
        if([dependencyName length] > 0 && [dependencyPath length] > 0)
        {
            dependencyName = [dependencyName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([dependencyName hasSuffix:@":"]) {
                dependencyName = [dependencyName substringToIndex:[dependencyName length]-1];
            }
            self.externalSources[dependencyName] = [dependencyPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    return success;
}

-(BOOL)parseExternalSourceEntry:(NSString*)externalSourceEntry
{
    NSArray* entryComponents = [externalSourceEntry componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    NSLog(@"entryComponents: %@", entryComponents);
//    if ([podsEntryComponents count] == 2) {
//        NSString* dependency = [podsEntryComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        NSString* checksum = [podsEntryComponents[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        if ([checksum length] > 0 && [dependency length] > 0) {
//            self.checksumForDependency[dependency] = checksum;
//            return YES;
//        }
//        else
//        {
//            return [podsEntryComponents.firstObject isEqualToString:@"SPEC CHECKSUMS"];
//        }
//    }
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
