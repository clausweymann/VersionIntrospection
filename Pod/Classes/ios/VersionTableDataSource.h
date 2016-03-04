//
//  VersionTableDataSource.h
//  Pods
//
//  Created by Claus Weymann on 15/06/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *kSectionKey_title;
extern NSString *kSectionKey_data;
extern NSString *kSectionTitle_version;
extern NSString *kSectionTitle_license;
extern NSString *kVersionIntrospection_VersionCell;
extern NSString *kVersionIntrospection_LicenseCell;

@interface VersionTableDataSource : NSObject<UITableViewDataSource>
@property (nonatomic, strong) NSAttributedString* licenseMarkdown;
@property (nonatomic, strong) NSDictionary* explicitDependencyOrder;
@property (nonatomic, strong) NSSet* licenseIgnoreList;

-(id)dataItemAtIndexPath:(NSIndexPath*)indexPath;

@end
