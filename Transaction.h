//
//  Transaction.h
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/08/19.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Transaction : NSManagedObject {}

- (NSDecimalNumber *)proceeds;
- (NSDecimalNumber *)presentValue;

- (NSString *)securitySymbolAndName;

@end
