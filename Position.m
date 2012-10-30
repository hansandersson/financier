// 
//  Position.m
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/03/14.
//  Copyright 2009 Hans Anderson. All rights reserved.
//

#import "Portfolio_Manager_AppDelegate.h"
#import "Logger.h"
#import "Position.h"
#import "Portfolio.h"
#import "Transaction.h"
#import "Model.h"

@implementation Position

@synthesize security;
@synthesize portfolio;
@synthesize targetPosition;

+ (Position *)positionFromSecurity:(Security *)aSecurity forPortfolio:(Portfolio*)aPortfolio
{
	(void)aPortfolio;
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"position->positionFromSecurity (%@)",[aSecurity valueForKey:@"symbol"]]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	
    id newPosition = [[[self alloc] init] autorelease];
    [newPosition setSecurity:aSecurity];
    [newPosition setPortfolio:aPortfolio];
	
	if( [aPortfolio valueForKey:@"model"] != nil ) {
		NSSet *targets = [aPortfolio mutableSetValueForKeyPath:@"model.targets"];
		for( NSManagedObject *target_i in targets ) {
			if( [target_i valueForKey:@"security"] == aSecurity ) {
				[newPosition setTargetPosition:target_i];
				break;
			}
		}
		[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"*** NO TARGET FOR %@", [aSecurity valueForKey:@"symbol"]]];
	}
    
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"done with position->positionFromSecurity"]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
    return newPosition;
}

- (NSDecimalNumber *)currentQuantity
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"position->currentQuantity (%@)",[[self security] valueForKey:@"symbol"]]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	
	//if( currentQuantity == nil ) {
		currentQuantity = [NSDecimalNumber zero];
		NSArray *transactions = [[portfolio mutableSetValueForKey:@"transactions"] allObjects];
		for( NSManagedObject *transaction_i in transactions ) {
			if( [transaction_i valueForKey:@"security"] == security && [transaction_i valueForKey:@"quantity"] != nil ) {
				currentQuantity = [currentQuantity decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[[transaction_i valueForKey:@"quantity"] decimalValue]]];
			}
		}
	//currentQuantity = [currentQuantity_decimal compare:[NSDecimalNumber zero]] != NSOrderedSame ? currentQuantity_decimal : nil;
	//}

	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"done with position->currentQuantity %@",currentQuantity]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	
	return currentQuantity;
}

- (NSString *)securitySymbol
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"position->securitySymbol & done (%@)",[[self security] valueForKey:@"symbol"]]];
	
	return [security valueForKey:@"symbol"];
}

- (NSString *)securitySymbolAndName
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"position->securitySymbolAndName & done (%@)",[[self security] valueForKey:@"symbol"]]];
	return [NSString stringWithFormat:@"%@—%@",[security valueForKey:@"symbol"],[security valueForKey:@"name"]];
}

- (NSDecimalNumber *)targetWeight
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"position->targetWeight (%@)",[[self security] valueForKey:@"symbol"]]];
	if( targetPosition == nil )
		return [NSDecimalNumber zero];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"done with position->targetWeight %@",[targetPosition valueForKey:@"weight"]]];
	return [targetPosition valueForKey:@"weight"];
}

- (NSDecimalNumber *)targetAllocation
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"position->targetAllocation (%@)",[[self security] valueForKey:@"symbol"]]];
	if( targetPosition == nil )
		return [NSDecimalNumber zero];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	targetAllocation = [[[[self valueForKey:@"portfolio"] totalValue]
						 decimalNumberByMultiplyingBy:
						 [self targetWeightPercentage]]
						decimalNumberByDividingBy:
						[NSDecimalNumber decimalNumberWithMantissa:1 exponent:2 isNegative:NO]
						];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"done with position->targetAllocation %@",targetAllocation]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	return targetAllocation;
}

- (NSDecimalNumber *)targetQuantity
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"position->targetQuantity (%@)",[[self security] valueForKey:@"symbol"]]];
	if( targetPosition == nil || [security valueForKey:@"mostRecentPrice"] == nil || [(NSDecimalNumber *)[security valueForKey:@"mostRecentPrice"] compare:[NSDecimalNumber zero]] == NSOrderedSame )
		return [NSDecimalNumber zero];

	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	
	targetQuantity = [
					  [self targetAllocation]
					  decimalNumberByDividingBy:
					  [security valueForKey:@"mostRecentPrice"]
					  ];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"done with position->targetQuantity %@",targetQuantity]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	return targetQuantity;
}

- (NSDecimalNumber *)targetWeightPercentage
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"position->targetWeightPercentage (%@)",[[self security] valueForKey:@"symbol"]]];
	if( targetPosition == nil )
		return [NSDecimalNumber zero];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	targetWeightPercentage = [
							  [NSDecimalNumber decimalNumberWithMantissa:1 exponent:2 isNegative:NO]
							  decimalNumberByMultiplyingBy:
							  [
							   [self targetWeight]
							   decimalNumberByDividingBy:
							   [[portfolio valueForKey:@"model"] totalWeight]
							   ]
							  ];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"done with position->targetWeightPercentage %@",targetWeightPercentage]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	return targetWeightPercentage;
}

- (NSDecimalNumber *)currentAllocation
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"position->currentAllocation (%@)",[[self security] valueForKey:@"symbol"]]];
	
	if( [self currentQuantity] == nil || [[self currentQuantity] compare:[NSDecimalNumber zero]] == NSOrderedSame )
		return [NSDecimalNumber zero];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	
	currentAllocation = [[self currentQuantity] decimalNumberByMultiplyingBy:[security valueForKey:@"mostRecentPrice"]];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"done with position->currentAllocation %@",currentAllocation]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	return currentAllocation;
}

- (NSDecimalNumber *)currentWeight
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"position->currentWeight (%@)",[[self security] valueForKey:@"symbol"]]];
	
	if( [self currentQuantity] == nil || [[self currentQuantity] compare:[NSDecimalNumber zero]] == NSOrderedSame || [[[self valueForKey:@"portfolio"] totalValue] compare:[NSDecimalNumber zero]] == NSOrderedSame )
		return [NSDecimalNumber zero];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	
	currentWeight = [[self currentAllocation] decimalNumberByDividingBy:[[self valueForKey:@"portfolio"] totalValue]];

	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"done with position->currentWeight %@",currentWeight]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	return currentWeight;
}

- (NSDecimalNumber *)currentWeightPercentage
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"position->currentWeightPercentage (%@)",[[self security] valueForKey:@"symbol"]]];
	
	if( [self currentQuantity] == nil || [[self currentQuantity] compare:[NSDecimalNumber zero]] == NSOrderedSame || [[[self valueForKey:@"portfolio"] totalValue] compare:[NSDecimalNumber zero]] == NSOrderedSame )
		return [NSDecimalNumber zero];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	
	currentWeightPercentage = [[NSDecimalNumber decimalNumberWithString:@"100"] decimalNumberByMultiplyingBy:[self currentWeight]];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"done with position->currentWeightPercentage %@",currentWeightPercentage]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	
	return currentWeightPercentage;
}

- (NSDecimalNumber *)deviationWeight
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"position->deviationWeight (%@)",[[self security] valueForKey:@"symbol"]]];
	if( [self targetWeight] == nil && [self currentWeight] == nil )
		return [NSDecimalNumber zero];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	
	//if( deviationWeight == nil ) {
		deviationWeight = [[[self currentWeightPercentage] decimalNumberBySubtracting:[self targetWeightPercentage]] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"deviationWeight = (%@)",deviationWeight]];
		deviationWeight = [deviationWeight compare:[NSDecimalNumber zero]] == NSOrderedDescending ? deviationWeight : [[NSDecimalNumber zero] decimalNumberBySubtracting:deviationWeight];
	//}
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"done with position->deviationWeight %@",deviationWeight]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	return deviationWeight;
}

- (NSDecimalNumber *)deviationWeightPercentage
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"position->deviationWeightPercentage (%@)",[[self security] valueForKey:@"symbol"]]];
	if( [self targetWeight] == nil && [self currentWeight] == nil )
		return [NSDecimalNumber zero];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	//if( deviationWeightPercentage == nil )
	deviationWeightPercentage = [[self deviationWeight] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"done with position->deviationWeightPercentage %@",deviationWeightPercentage]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	return deviationWeightPercentage;
}

- (NSDecimalNumber *)deviationAllocation
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"position->deviationAllocation (%@)",[[self security] valueForKey:@"symbol"]]];
	if( [self targetWeight] == nil && [self currentWeight] == nil )
		return [NSDecimalNumber zero];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	//if( deviationAllocation == nil ) {
	deviationAllocation = [[self currentAllocation] decimalNumberBySubtracting:[self targetAllocation]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"deviationAllocation = (%@)",deviationAllocation]];
		deviationAllocation = [deviationAllocation compare:[NSDecimalNumber zero]] == NSOrderedDescending ? deviationAllocation : [[NSDecimalNumber zero] decimalNumberBySubtracting:deviationAllocation];
	//}
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"done with position->deviationAllocation %@",deviationAllocation]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	return deviationAllocation;
}

- (NSDecimalNumber *)deviationQuantity
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"position->deviationQuantity (%@)",[[self security] valueForKey:@"symbol"]]];
	if( [self targetWeight] == nil && [self currentWeight] == nil )
		return [NSDecimalNumber zero];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	//if( deviationAllocation == nil ) {
	deviationQuantity = [[self currentQuantity] decimalNumberBySubtracting:[self targetQuantity]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"deviationQuantity = (%@)",deviationQuantity]];
		deviationQuantity = [deviationQuantity compare:[NSDecimalNumber zero]] == NSOrderedDescending ? deviationQuantity : [[NSDecimalNumber zero] decimalNumberBySubtracting:deviationQuantity];
	//}
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"done with position->deviationQuantity %@",deviationQuantity]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	return deviationQuantity;
}

- (NSString *)suggestion
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"position->suggestion (%@)",[[self security] valueForKey:@"symbol"]]];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	if([[self deviationWeightPercentage] doubleValue] >= 100*[[[self valueForKey:@"portfolio"] recommendationThresholdWeight] doubleValue] &&
	   [[self deviationAllocation] doubleValue] >= [[[self valueForKey:@"portfolio"] recommendationThresholdAllocation] doubleValue] &&
	   (double) (NSInteger) ([[self deviationQuantity] doubleValue] + 0.5) >= [[[self valueForKey:@"portfolio"] recommendationThresholdQuantity] doubleValue]) {
		
		double quantity = [[self currentQuantity] doubleValue] - [[self targetQuantity] doubleValue];
		
		[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
		return [NSString stringWithFormat:@"%@ %@",(quantity > 0 ? @"Sell" : @"Buy"),[NSNumber numberWithInteger:(NSInteger) ( (quantity > 0 ? quantity : 0 - quantity) + 0.5)]];
	}
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	return @"Hold";
}

@end
