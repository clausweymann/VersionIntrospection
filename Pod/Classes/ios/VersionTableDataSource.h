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

@interface VersionTableDataSource : NSObject<UITableViewDataSource>
@property (nonatomic, strong) NSAttributedString* licenseMarkdown;
@property (nonatomic, strong) NSDictionary* explicitDependencyOrder;

-(id)dataItemAtIndexPath:(NSIndexPath*)indexPath;

@end
