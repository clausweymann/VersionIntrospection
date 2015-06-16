//
//  VersionTableDataSource.h
//  Pods
//
//  Created by Claus Weymann on 15/06/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VersionTableDataSource : NSObject<UITableViewDataSource>

@property (nonatomic, strong) NSDictionary* explicitDependencyOrder;

@end
