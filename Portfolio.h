//
//  Portfolio.h
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/03/14.
//  Copyright 2009 Hans Anderson. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Portfolio : NSManagedObject {
	NSNumber *expectedReturnOnCurrentAllocation;
	NSNumber *expectedReturnOnTargetAllocation;
	
	NSNumber *varianceOnCurrentAllocation;
	NSNumber *varianceOnTargetAllocation;
	
	NSArray *positions;
	
	NSDecimalNumber *cash;
	NSDecimalNumber *investments;
}

@property (readwrite,retain) NSString *name;
@property (readonly) NSArray *positions;

@property (readonly) NSDecimalNumber *cash;
@property (readonly) NSDecimalNumber *investments;
@property (readonly) NSDecimalNumber *totalValue;

@property (readonly) NSNumber *recommendationThresholdAllocation;
@property (readonly) NSNumber *recommendationThresholdQuantity;
@property (readonly) NSNumber *recommendationThresholdWeight;

@property (readonly) NSNumber *expectedReturnOnCurrentAllocation;
@property (readonly) NSNumber *expectedReturnOnTargetAllocation;

@property (readonly) NSNumber *varianceOnCurrentAllocation;
@property (readonly) NSNumber *varianceOnTargetAllocation;

- (IBAction)recalculateStatistics:(id)sender;

@end

