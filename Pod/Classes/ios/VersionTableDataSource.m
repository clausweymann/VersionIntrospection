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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* reuseIdentifier = @"versionIntrospectionCell";
    //static dispatch_once_t onceToken;
    //dispatch_once(&onceToken, ^{
        //[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
        [tableView registerNib:[UINib nibWithNibName:@"VersionTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reuseIdentifier];
    //});
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    NSArray* sectionArray = [self arrayForSection:[indexPath section]];
    DependencyInformation* dependencyInfo = sectionArray[[indexPath row]];
    ((UILabel*)[cell viewWithTag:10]).text = dependencyInfo.name;
    ((UILabel*)[cell viewWithTag:11]).text = dependencyInfo.version;
    ((UILabel*)[cell viewWithTag:12]).text = dependencyInfo.gitHash;
    
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

//-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    return [[VersionIntrospection sharedIntrospection].versionInformation allKeys];
//}
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
-(NSDictionary*)dataSource
{
    return @{@"Dependencies:":self.sortedDataSource};
    //return @{@"Dependencies:":[VersionIntrospection sharedIntrospection].versionInformation};
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
