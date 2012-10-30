//
//  Model.h
//  Portfolio Manager
//
//  Created by Hans Anderson on 10/01/02.
//  Copyright 2010 ultraMentem Tech Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Model : NSManagedObject {
	NSDecimalNumber *totalWeight;
}

@property (readonly) NSDecimalNumber *totalWeight;
@property (readonly) NSNumber *countOfSecurities;
@property (readonly) NSNumber *variance;
@property (readonly) NSNumber *meanReturn;

@end
