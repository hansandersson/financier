// 
//  Portfolio.m
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/03/14.
//  Copyright 2009 Hans Anderson. All rights reserved.
//

#import "Portfolio_Manager_AppDelegate.h"
#import "Logger.h"
#import "Portfolio.h"
#import "Position.h"
#import "Security.h"
#import "Transaction.h"

#import "Math.h"

@implementation Portfolio 

//@dynamic cutoffRank;
@dynamic name;
@dynamic recommendationThresholdAllocation;
@dynamic recommendationThresholdQuantity;
@dynamic recommendationThresholdWeight;
//@dynamic shortPositionsAllowed;
//@dynamic positions;

@synthesize varianceOnCurrentAllocation;
@synthesize varianceOnTargetAllocation;
@synthesize expectedReturnOnCurrentAllocation;
@synthesize expectedReturnOnTargetAllocation;

- (NSDecimalNumber *)cash
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"portfolio->cash"]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	
	if( cash == nil ) {
		cash = [NSDecimalNumber zero];
		NSArray *transactions = [[self mutableSetValueForKey:@"transactions"] allObjects];
		for( Transaction *transaction_i in transactions ) {
			cash = [cash decimalNumberByAdding:[transaction_i proceeds]];
		}
	}
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"done with portfolio->cash %@",cash]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	return cash;
}

- (NSDecimalNumber *)investments 
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"portfolio->investments"]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	
	if( investments == nil ) {
		investments = [NSDecimalNumber zero];
		
		/*positions = [self positions];
		for( Position *position_i in positions ) {
			if( [position_i security] != nil ) {
				investments = [investments
							   decimalNumberByAdding:
							   [
								[position_i currentQuantity]
								decimalNumberByMultiplyingBy:
								[[position_i security] valueForKey:@"mostRecentPrice"]
								]
							   ];
			}
		}*/
		
		NSArray *transactions = [[self mutableSetValueForKey:@"transactions"] allObjects];
		for( Transaction *transaction_i in transactions ) {
			investments = [investments decimalNumberByAdding:[transaction_i presentValue]];
		}
	}

	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"done with portfolio->investments: %@",investments]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	
    return investments;
}

- (NSDecimalNumber *)totalValue 
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"portfolio->totalValue"]];
    return [[self investments] decimalNumberByAdding:[self cash]];
}

/*- (NSSet *)suggestions
{
	NSMutableArray *suggestions = [NSMutableArray arrayWithCapacity:[[self positions] count]];
	
	for( Position* currentPosition in [self positions] ) {
		Suggestion* currentPositionSuggestion = [Suggestion suggestionForPosition:currentPosition];
		if( [[currentPositionSuggestion roundQuantity] intValue] > 0 && [[currentPositionSuggestion roundQuantity] decimalValue]*[[[currentPosition valueForKey:@"security"] valueForKey:@"mostRecentPrice"] decimalValue]/[[self totalValue] decimalValue] > [[self recommendationThresholdWeight] decimalValue] ) {
			[suggestions addObject:currentPositionSuggestion];
		}
	}
	
	return [NSSet setWithArray:suggestions];
}*/

- (NSArray *)positions
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"portfolio->positions"]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	
	//if( positions == nil ) {
		NSMutableSet *securities = [NSMutableSet set];
		
		for( Transaction *transaction_i in [self mutableSetValueForKey:@"transactions"] ) {
			if( [transaction_i valueForKey:@"security"] != nil && ![securities containsObject:[transaction_i valueForKey:@"security"]] ) {
				[securities addObject:[transaction_i valueForKey:@"security"]];
			}
		}
		
		for( NSManagedObject *target_i in [self mutableSetValueForKeyPath:@"model.targets"] ) {
			if( ![securities containsObject:[target_i valueForKey:@"security"]] ) {
				[securities addObject:[target_i valueForKey:@"security"]];
			}
		}
		
		NSMutableArray *positions_mutable = [NSMutableArray array];
		
		for( Security *security_i in securities ) {
			Position *newPosition = [Position positionFromSecurity:security_i forPortfolio:self];
			
			/*NSDictionary *newPositionDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
												   [newPosition security] != nil ? [newPosition security] : [NSNull null], @"security",
												   [newPosition currentQuantity] != nil ? [newPosition currentQuantity] : [NSNull null], @"currentQuantity",
												   [newPosition currentAllocation] != nil ? [newPosition currentAllocation] : [NSNull null], @"currentAllocation",
												   [newPosition currentWeightPercentage] != nil ? [newPosition currentWeightPercentage] : [NSNull null], @"currentWeightPercentage",
												   [newPosition targetWeightPercentage] != nil ? [newPosition targetWeightPercentage] : [NSNull null], @"targetWeightPercentage",
												   [newPosition targetAllocation] != nil ? [newPosition targetAllocation] : [NSNull null], @"targetAllocation",
												   [newPosition targetQuantity] != nil ? [newPosition targetQuantity] : [NSNull null], @"targetQuantity",
												   [newPosition deviationWeightPercentage] != nil ? [newPosition deviationWeightPercentage] : [NSNull null], @"deviationWeightPercentage",
												   [newPosition deviationAllocation] != nil ? [newPosition deviationAllocation] : [NSNull null], @"deviationAllocation",
												   [newPosition deviationQuantity] != nil ? [newPosition deviationQuantity] : [NSNull null], @"deviationQuantity",
												   nil];
			
			[positions_mutable addObject:newPositionDictionary];*/
			if( [[newPosition currentWeightPercentage] compare:[NSDecimalNumber zero]] != NSOrderedSame || [[newPosition targetWeightPercentage] compare:[NSDecimalNumber zero]] != NSOrderedSame ) {
				[positions_mutable addObject:newPosition];
			}
		}
		
		positions = [NSArray arrayWithArray:positions_mutable];

	[self willChangeValueForKey:@"cash"];
	[self willChangeValueForKey:@"investments"];
	cash = nil;
	investments = nil;
	[self didChangeValueForKey:@"investments"];
	[self didChangeValueForKey:@"cash"];
	//}
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"done with portfolio->positions"]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	
	return positions;
}

- (IBAction)recalculateStatistics:(id)sender
{
	(void)sender;
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"portfolio->recalculateStatistics"]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"not yet ready"]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	return;
	
	/*NSMutableArray *relevantPositions = [[[self mutableSetValueForKey:@"positions"] allObjects] mutableCopy];
	//[relevantPositions filterUsingPredicate:[NSPredicate predicateWithFormat:@"currentWeight != 0 OR targetWeight != 0"]];
	
	//[relevantPositions sortUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"securitySymbol" ascending:YES]]];
 	
	NSDecimalNumber *expectedReturnOnCurrentAllocation_decimal = [NSDecimalNumber zero];
	NSDecimalNumber *expectedReturnOnTargetAllocation_decimal = [NSDecimalNumber zero];
	
	NSDecimalNumber *varianceOnCurrentAllocation_decimal = [NSDecimalNumber zero];
	NSDecimalNumber *variaceOnTargetAllocation_decimal = [NSDecimalNumber zero];
	
	for( NSUInteger r = 0; r < [relevantPositions count]; r++ ) {
		Position *position_r = [relevantPositions objectAtIndex:r];
		NSDecimalNumber *targetWeight_r = [[position_r targetWeight] decimalValue];
		NSDecimalNumber *currentWeight_r = [[position_r currentWeight] decimalValue];
		NSDecimalNumber *meanReturn_r = [position_r security] != nil ? [[[position_r security] meanReturn] decimalValue] : 0;
		
		expectedReturnOnCurrentAllocation_decimal += meanReturn_r * currentWeight_r;
		expectedReturnOnTargetAllocation_decimal += meanReturn_r * targetWeight_r;

		for( NSUInteger c = r; c < [relevantPositions count]; c++ ) {
			Position *position_c = [relevantPositions objectAtIndex:c];
			NSDecimalNumber *targetWeight_c = [[position_c targetWeight] decimalValue];
			NSDecimalNumber *currentWeight_c = [[position_c currentWeight] decimalValue];
			//NSDecimalNumber *meanReturn_c = [[[position_c security] meanReturn] decimalValue];
			//NSDecimalNumber *stdev_j = sqrt( [[[position_j security] unsystematicRisk] decimalValue] );
			
			/ *NSMutableArray *dataPointsForPosition_r = [[[position_r security] dataPointsSortedAscending:NO] mutableCopy];
			NSMutableArray *dataPointsForPosition_c = [[[position_c security] dataPointsSortedAscending:NO] mutableCopy];
			
			NSDecimalNumber *covarianceNumerator = [NSDecimalNumber zero];
			NSDecimalNumber *covarianceDenominator = [NSDecimalNumber zero];
			
			while( [dataPointsForPosition_r count] > 0 && [dataPointsForPosition_c count] > 0 ) {
				NSManagedObject *dataPoint_r = [dataPointsForPosition_r objectAtIndex:0];
				NSManagedObject *dataPoint_c = [dataPointsForPosition_c objectAtIndex:0];
				
				if( [[dataPoint_r valueForKey:@"dateString"] caseInsensitiveCompare:[dataPoint_c valueForKey:@"dateString"]] == NSOrderedAscending ) {
					[dataPointsForPosition_c removeObjectAtIndex:0];
				}
				else if( [[dataPoint_r valueForKey:@"dateString"] caseInsensitiveCompare:[dataPoint_c valueForKey:@"dateString"]] == NSOrderedDescending ) {
					[dataPointsForPosition_r removeObjectAtIndex:0];
				}
				else {
					covarianceNumerator += ([[dataPoint_r valueForKey:@"returnFromPrevious"] decimalValue] - meanReturn_r)*([[dataPoint_c valueForKey:@"returnFromPrevious"] decimalValue] - meanReturn_c);
					covarianceDenominator++;
					[dataPointsForPosition_c removeObjectAtIndex:0];
					[dataPointsForPosition_r removeObjectAtIndex:0];
				}
			}
			
			NSDecimalNumber *covariance = covarianceNumerator/covarianceDenominator;* /
			
			//NSDecimalNumber *correlation = covariance / (stdev_i*stdev_j);
			
	/ *		NSDecimalNumber *covariance = ([position_r security] != nil && [position_c security] != nil) ? [[[position_r security] covarianceWithSecurity:[position_c security]] decimalValue] : 0;
			
			varianceOnCurrentAllocation_decimal += currentWeight_r*currentWeight_c * covariance;
			variaceOnTargetAllocation_decimal += targetWeight_r*targetWeight_c * covariance;
		}
	}
	
	expectedReturnOnCurrentAllocation =  [NSNumber numberWithDouble:expectedReturnOnCurrentAllocation_decimal];
	expectedReturnOnTargetAllocation = [NSNumber numberWithDouble:expectedReturnOnTargetAllocation_decimal];
	
	varianceOnCurrentAllocation = [NSNumber numberWithDouble:varianceOnCurrentAllocation_decimal];
	varianceOnTargetAllocation = [NSNumber numberWithDouble:variaceOnTargetAllocation_decimal];*/
}

@end
