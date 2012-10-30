//
//  Security.h
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/08/21.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Security : NSManagedObject {
	NSNumber *meanReturn;
	NSNumber *beta;
	NSNumber *alpha;
	NSNumber *unsystematicRisk;
	NSNumber *geometricMeanReturn;
	//NSNumber *inclusionRank;
}

@property (readonly) NSNumber *meanReturn;
@property (readonly) NSNumber *geometricMeanReturn;
@property (readonly) NSNumber *alpha;
@property (readonly) NSNumber *beta;
@property (readonly) NSNumber *unsystematicRisk;
@property (readonly) NSNumber *variance;

@property (readonly) NSNumber *countOfDataPoints;

- (NSArray *)dataPointsSortedAscending:(BOOL)ascending;

- (NSNumber *)covarianceWithSecurity:(Security *)otherSecurity;

- (IBAction)updateDataPoints:(id)sender;
- (void)recalculateStatistics;
- (IBAction)updateMostRecentPrice:(id)sender;

@property (readonly) NSString *symbolAndName;

@end
