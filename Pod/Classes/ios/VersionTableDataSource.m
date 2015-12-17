//
//  VersionTableDataSource.m
//  Pods
//
//  Created by Claus Weymann on 15/06/15.
//
//

#import "VersionTableDataSource.h"
#import "VersionIntrospection.h"
#import "DependencyInformation.h"

#import <TSMarkdownParser/TSMarkdownParser.h>

@interface VersionTableDataSource()

@property (nonatomic,strong) NSMutableArray* sortedDataSource;

@end

@implementation VersionTableDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self arrayForSection:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    static NSString* reuseIdentifierDepenencyInfo = @"versionIntrospectionDependencyInfoCell";
    [tableView registerNib:[UINib nibWithNibName:@"VersionTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reuseIdentifierDepenencyInfo];
    
    static NSString* reuseIdentifierLicenseMarkdown = @"versionIntrospectionLicenseMarkdownCell";
     [tableView registerNib:[UINib nibWithNibName:@"LicenseTableViewCell" bundle:[NSBundle mainBundle]]forCellReuseIdentifier:reuseIdentifierLicenseMarkdown];
    
    NSArray* sectionArray = [self arrayForSection:[indexPath section]];
    id dataItem = sectionArray[[indexPath row]];
    
    if ([dataItem isKindOfClass: [DependencyInformation class]]) {
        DependencyInformation* dependencyInfo = (DependencyInformation*)dataItem;
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierDepenencyInfo forIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifierDepenencyInfo];
        }
        ((UILabel*)[cell viewWithTag:10]).text = dependencyInfo.name;
        ((UILabel*)[cell viewWithTag:11]).text = dependencyInfo.version;
        ((UILabel*)[cell viewWithTag:12]).text = dependencyInfo.gitHash;
    }
    else
    {
        if ([dataItem isKindOfClass:[NSAttributedString class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierLicenseMarkdown forIndexPath:indexPath];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifierLicenseMarkdown];
            }
            ((UITextView*)[cell viewWithTag:20]).attributedText = dataItem;
        }
    }
    
    
    return cell;
}

-(NSArray*)arrayForSection:(NSInteger)section
{
    NSObject* sectionDictKey = [self.dataSource allKeys][section];
    return self.dataSource[sectionDictKey];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.dataSource allKeys][section];
}

-(NSMutableArray *)sortedDataSource
{
    if(!_sortedDataSource)
    {
        _sortedDataSource = [NSMutableArray array];
        NSArray* sortedValues;
       
        sortedValues = [[[VersionIntrospection sharedIntrospection].versionInformation allValues] sortedArrayUsingSelector:@selector(compare:)];
        
        for (DependencyInformation* info in sortedValues) {
            [_sortedDataSource addObject:info];
        }
    }
    return _sortedDataSource;
}
-(NSAttributedString*)licenseMarkdown
{
    if(!_licenseMarkdown)
    {
        NSString* markdownPath = [[NSBundle mainBundle] pathForResource:@"Acknowledgements" ofType:@"markdown"];
        NSError* error;
        NSString* markdownString = [NSString stringWithContentsOfFile:markdownPath encoding:NSUTF8StringEncoding error:&error];
        if(error)
        {
            NSLog(@"error reading Acknowledgements.markdown, make sure you copied it during post install phase in your podfile");
            return nil;
        }
        NSAttributedString *string = [[TSMarkdownParser standardParser] attributedStringFromMarkdown:markdownString];
        _licenseMarkdown = string ?: [[NSAttributedString alloc] initWithString:@""];
    }
    return _licenseMarkdown;
}

-(NSDictionary*)dataSource
{
    if(self.licenseMarkdown.length > 0)
    {
        return @{@"Dependencies:":self.sortedDataSource, @"Licenses:":@[self.licenseMarkdown]};
    }
    return @{@"Dependencies:":self.sortedDataSource};
}

-(void)setExplicitDependencyOrder:(NSDictionary *)explicitDependencyOrder
{
    [VersionIntrospection sharedIntrospection].explicitDependencyOrder = explicitDependencyOrder;
}

-(NSDictionary *)explicitDependencyOrder
{
    return [VersionIntrospection sharedIntrospection].explicitDependencyOrder;
}
@end
