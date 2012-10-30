//
//  PortfolioManager.m
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/03/10.
//  Copyright 2009 Hans Anderson. All rights reserved.
//

#import "PortfolioManager.h"
#import "Portfolio_Manager_AppDelegate.h"
#import "Logger.h"
#import "Portfolio.h"
#import "Position.h"
#import "Suggestion.h"
#import "Security.h"

@implementation PortfolioManager

- (IBAction)populate:(id)sender
{
	(void)sender;
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"not yet ready"]];
	return;
	/*
	if( [[portfolioArrayController selectedObjects] count] != 1 ) {
		return;
	}
	
	Portfolio *portfolioToPopulate = [[portfolioArrayController selectedObjects] objectAtIndex:0];
	
	NSMutableArray *rankedSecurities = [NSMutableArray arrayWithArray:[securityArrayController arrangedObjects]];
	[rankedSecurities sortUsingDescriptors:
	 [NSArray arrayWithObject:
	  [[NSSortDescriptor alloc] initWithKey:@"inclusionRank" ascending:NO]
	 ]
	];
	
	NSDecimalNumber *riskFreeReturn_decimal = [[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] riskFreeReturn] decimalValue];
	
	for( NSUInteger i = 0; i < [rankedSecurities count]; i++ ) {
		NSDecimalNumber *cutoffRankNumerator = [NSDecimalNumber zero];
		NSDecimalNumber *cutoffRonkDenominator = [NSDecimalNumber zero];
		
		for( NSUInteger j = 0; j <= i; j++ ) {
			Security *currentSecurity = [rankedSecurities objectAtIndex:j];
			[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"\t%@: %@ %@ %@",[currentSecurity valueForKey:@"symbol"],[currentSecurity meanReturn],[currentSecurity beta],[currentSecurity unsystematicRisk]]];
			
			cutoffRankNumerator += (([[currentSecurity meanReturn] decimalValue] - riskFreeReturn_decimal)*[[currentSecurity beta] decimalValue]/[[currentSecurity unsystematicRisk] decimalValue]);
			cutoffRonkDenominator += [[currentSecurity beta] decimalValue]*[[currentSecurity beta] decimalValue]/[[currentSecurity unsystematicRisk] decimalValue];
			[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"\t\t%f / %f", cutoffRankNumerator, cutoffRonkDenominator]];
		}
		
		cutoffRankNumerator = cutoffRankNumerator*[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] marketReturnVariance] decimalValue];
		cutoffRonkDenominator = cutoffRonkDenominator*[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] marketReturnVariance] decimalValue];
		cutoffRonkDenominator += 1;
		
		NSDecimalNumber *cutoffRank = cutoffRankNumerator / cutoffRonkDenominator;
		[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"\t\t%f", cutoffRank]];
		
		if( [rankedSecurities objectAtIndex:i] == [rankedSecurities lastObject] || ( [[[rankedSecurities objectAtIndex:i] inclusionRank] decimalValue] >= cutoffRank && [[[rankedSecurities objectAtIndex:(i+1)] inclusionRank] decimalValue] < cutoffRank ) ) {
			[[portfolioToPopulate mutableSetValueForKey:@"positions"] removeAllObjects];
			for( NSUInteger k = 0; k <= i; k++ ) {
				NSManagedObject *newPosition; 
				newPosition = (NSManagedObject *)[NSEntityDescription insertNewObjectForEntityForName:@"Position" inManagedObjectContext:[positionArrayController managedObjectContext]];
				
				[newPosition setValue:[rankedSecurities objectAtIndex:k] forKey:@"Security"];
				[positionArrayController addObject:newPosition];
			}
			[portfolioToPopulate setCutoffRank:[NSNumber numberWithDouble:cutoffRank]];
			return;
		}
	}
	 */
}

- (IBAction)rebalance:(id)sender
{
	(void)sender;
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"not ready yet"]];
	
	/*
	
	if( [[portfolioArrayController selectedObjects] count] != 1 ) {
		return;
	}
	
	Portfolio *portfolioToRebalance = [[portfolioArrayController selectedObjects] objectAtIndex:0];
	
	
	NSDecimalNumber *riskFreeReturn_decimal = [[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] riskFreeReturn] decimalValue];
	
	NSDecimalNumber *targetProportionScalar = [NSDecimalNumber zero];
	
	for( Position *currentPosition in [portfolioToRebalance mutableSetValueForKey:@"positions"] ) {
		NSDecimalNumber *beta = [[[currentPosition valueForKey:@"security"] valueForKey:@"beta"] decimalValue];
		//NSDecimalNumber *risk = [[[currentPosition valueForKey:@"security"] valueForKey:@"risk"] decimalValue];
		//NSDecimalNumber *rank = [[[currentPosition valueForKey:@"security"] inclusionRank] decimalValue];
		NSDecimalNumber *expectedReturn = [[[currentPosition valueForKey:@"security"] meanReturn] decimalValue];
		NSDecimalNumber *unsystematicRisk = [[[currentPosition valueForKey:@"security"] unsystematicRisk] decimalValue];
		
		//Procedure for an index in which we can invest:
		//NSDecimalNumber *currentPositionScalar = (expectedReturn - (riskFreeReturn_decimal+beta*(marketReturnMean_decimal-riskFreeReturn_decimal)))/unsystematicRisk;
		
		//Otherwise:
		NSDecimalNumber *currentPositionScalar = beta/unsystematicRisk * ((expectedReturn - riskFreeReturn_decimal)/beta - [[portfolioToRebalance cutoffRank] decimalValue]);
		
		currentPositionScalar = ((currentPositionScalar > 0 || [[portfolioToRebalance shortPositionsAllowed] boolValue] == YES) && [[currentPosition valueForKey:@"active"] decimalValue] == YES) ? currentPositionScalar : 0;
		
		targetProportionScalar += currentPositionScalar;
	}
	
	for( NSManagedObject *currentPosition in [portfolioToRebalance mutableSetValueForKey:@"positions"] ) {
		NSDecimalNumber *beta = [[[currentPosition valueForKey:@"security"] beta] decimalValue];
		//NSDecimalNumber *risk = [[[currentPosition valueForKey:@"security"] valueForKey:@"risk"] decimalValue];
		//NSDecimalNumber *rank = [[[currentPosition valueForKey:@"security"] inclusionRank] decimalValue];
		NSDecimalNumber *expectedReturn = [[[currentPosition valueForKey:@"security"] meanReturn] decimalValue];
		NSDecimalNumber *unsystematicRisk = [[[currentPosition valueForKey:@"security"] unsystematicRisk] decimalValue];
		
		NSDecimalNumber *currentPositionScalar = beta/unsystematicRisk * ((expectedReturn - riskFreeReturn_decimal)/beta - [[portfolioToRebalance cutoffRank] decimalValue]);
		
		NSDecimalNumber *targetWeight = currentPositionScalar/targetProportionScalar;
		
		if( [[currentPosition valueForKey:@"active"] decimalValue] == YES ) {
			[currentPosition setValue:[NSNumber numberWithDouble:([[portfolioToRebalance shortPositionsAllowed] boolValue] == YES ? targetWeight : (targetWeight > 0 ? targetWeight : 0 ))] forKey:@"targetWeight"];
		}
		else {
			[currentPosition setValue:[NSNumber numberWithDouble:0] forKey:@"targetWeight"];
		}
	}
	
	NSSet *suggestions = [portfolioToRebalance valueForKey:@"suggestions"];
	
	for( Suggestion *currentSuggestion in suggestions ) {
		[currentSuggestion roundQuantity];
		[currentSuggestion transactionType];
	}
	 */
}

- (IBAction)traceEfficientFrontier:(id)sender
{
	(void)sender;
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"traceEfficientFrontier"]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];

	[frontierArrayController removeObjects:[frontierArrayController arrangedObjects]];
	
	NSMutableArray *relevantSecurities = [[securityArrayController arrangedObjects] mutableCopy];
	
	[relevantSecurities sortUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"symbol" ascending:YES]]];
	[relevantSecurities filterUsingPredicate:[NSPredicate predicateWithFormat:@"countOfDataPoints > 50"]];
 	
	double constraints[[relevantSecurities count]][[relevantSecurities count] + 1];
	
	double minimumTargetWeight = 0;
	
	for( NSUInteger r = 0; r < [relevantSecurities count]; r++ ) {
		Security *security_r = [relevantSecurities objectAtIndex:r];
		
		//NSDecimalNumber *meanReturn_r = [[security_r meanReturn] decimalValue];
		
		[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"Computing covariances for %@", [security_r valueForKey:@"symbol"]]];
		
		for( NSUInteger c = r; c < [relevantSecurities count]; c++ ) {
			Security *security_c = [relevantSecurities objectAtIndex:c];
			
			/*NSDecimalNumber *meanReturn_c = [[security_c meanReturn] decimalValue];
			
			NSMutableArray *dataPointsForSecurity_r = [[security_r dataPointsSortedAscending:NO] mutableCopy];
			NSMutableArray *dataPointsForSecurity_c = [[security_c dataPointsSortedAscending:NO] mutableCopy];
			
			NSDecimalNumber *covarianceNumerator = [NSDecimalNumber zero];
			NSDecimalNumber *covarianceDenominator = [NSDecimalNumber zero];
			
			while( [dataPointsForSecurity_r count] > 0 && [dataPointsForSecurity_c count] > 0 ) {
				NSManagedObject *dataPoint_r = [dataPointsForSecurity_r objectAtIndex:0];
				NSManagedObject *dataPoint_c = [dataPointsForSecurity_c objectAtIndex:0];
				
				if( [[dataPoint_r valueForKey:@"dateString"] caseInsensitiveCompare:[dataPoint_c valueForKey:@"dateString"]] == NSOrderedAscending ) {
					[dataPointsForSecurity_c removeObjectAtIndex:0];
				}
				else if( [[dataPoint_r valueForKey:@"dateString"] caseInsensitiveCompare:[dataPoint_c valueForKey:@"dateString"]] == NSOrderedDescending ) {
					[dataPointsForSecurity_r removeObjectAtIndex:0];
				}
				else {
					covarianceNumerator += ([[dataPoint_r valueForKey:@"returnFromPrevious"] decimalValue] - meanReturn_r)*([[dataPoint_c valueForKey:@"returnFromPrevious"] decimalValue] - meanReturn_c);
					covarianceDenominator++;
					[dataPointsForSecurity_c removeObjectAtIndex:0];
					[dataPointsForSecurity_r removeObjectAtIndex:0];
				}
			}*/
			
			//NSDecimalNumber *covariance = covarianceNumerator/covarianceDenominator;
			
			double covariance = [[security_r covarianceWithSecurity:security_c] doubleValue];
			
			//NSDecimalNumber *correlation = covariance / (stdev_i*stdev_j);
			
			constraints[r][c] = 2 * covariance;
			constraints[c][r] = 2 * covariance;
		}
	}
	
	NSMutableArray *efficientFrontier = [NSMutableArray array];
	
	for( double returnMultiplier = 0.5; returnMultiplier < 500; returnMultiplier *= 1.01 ) {
		[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"returnMultiplier = %f", returnMultiplier]];
		[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
		
		for( NSUInteger r = 0; r < [relevantSecurities count]; r++ ) {
			Security *security_r = [relevantSecurities objectAtIndex:r];
			
			double meanReturn_r = [[security_r meanReturn] doubleValue];
			
			constraints[r][[relevantSecurities count]] = returnMultiplier * meanReturn_r;
		}
		
		double solutionMatrix[[relevantSecurities count]][[relevantSecurities count] + 1];
		
		for( NSUInteger r = 0; r < [relevantSecurities count]; r++ ) {
			for( NSUInteger c = 0; c < ([relevantSecurities count] + 1); c++ ) {
				solutionMatrix[r][c] = constraints[r][c];
			}
		}
		
		for( NSUInteger i = 0; i < [relevantSecurities count]; i++ ) {
			double normalizationFactor = solutionMatrix[i][i];
			for( NSUInteger c = 0; c < ([relevantSecurities count] + 1); c++ ) {
				solutionMatrix[i][c] = solutionMatrix[i][c] / normalizationFactor;
			}
			
			for( NSUInteger r = 0; r < [relevantSecurities count]; r++ ) {
				if( r != i ) {
					double cancelationFactor = solutionMatrix[r][i] / solutionMatrix[i][i];
					for( NSUInteger c = 0; c < ([relevantSecurities count] + 1); c++ ) {
						solutionMatrix[r][c] = solutionMatrix[r][c] - (solutionMatrix[i][c] * cancelationFactor);
					}
				}
			}
		}
		
		double solutionVector[[relevantSecurities count]];
		for( NSUInteger i = 0; i < [relevantSecurities count]; i++ ) {
			solutionVector[i] = solutionMatrix[i][[relevantSecurities count]];
		}
		
		//NSMutableString *solutionDump = [NSMutableString stringWithFormat:@"Solution when %@ is cut:",[[relevantPositions objectAtIndex:rowToReplace] valueForKey:@"symbol"]];
		/*NSMutableString *solutionDump_initial = [NSMutableString stringWithFormat:@"Unconstrained solution (starting vector):"];
		 for( NSUInteger i = 0; i < [relevantPositions count]; i++ ) {
		 [solutionDump_initial appendFormat:@"\r%@\t%f",[[relevantPositions objectAtIndex:i] valueForKey:@"symbol"],solutionVector[i]];
		 }
		 [[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"%@\r\r\r",solutionDump_initial);*/
		
		double totalPositive = 0.0;
		for( NSUInteger i = 0; i < [relevantSecurities count]; i++ ) {
			totalPositive += (solutionVector[i] > 0.0) ? solutionVector[i] : 0.0;
		}
		
		double solutionScale = 0.0;
		for( NSUInteger i = 0; i < [relevantSecurities count]; i++ ) {
			if(solutionVector[i] / totalPositive > minimumTargetWeight) {
				solutionScale += solutionVector[i];
			}
			else {
				solutionVector[i] = 0;
			}
		}
		
		double solutionReturnMean_proposed = 0.0;
		double solutionReturnVariance_proposed = 0.0;
		
		//NSMutableString *solutionSummaryDump = [NSMutableString stringWithFormat:@"Solution summary when %@ is cut:",[[relevantPositions objectAtIndex:rowToReplace] valueForKey:@"symbol"]];
		//NSMutableString *solutionDump_normal = [NSMutableString stringWithFormat:@"Normalized solution:"];
		for( NSUInteger i = 0; i < [relevantSecurities count]; i++ ) {
			solutionVector[i] /= solutionScale;
			
			if( solutionVector[i] != 0 ) {
				solutionReturnMean_proposed += solutionVector[i] * [[[relevantSecurities objectAtIndex:i] meanReturn] doubleValue];
				
				for( NSUInteger j = 0; j < [relevantSecurities count]; j++ ) {
					solutionReturnVariance_proposed += solutionVector[i]*solutionVector[j]*constraints[i][j]; //(solutionVector[i]*solutionVector[j]*constraints[i][j] > 0 ? solutionVector[i]*solutionVector[j]*constraints[i][j] : -solutionVector[i]*solutionVector[j]*constraints[i][j]);
				}
				
				//[solutionDump_normal appendFormat:@"\r%@\t%f", [[relevantSecurities objectAtIndex:i] valueForKey:@"symbol"], solutionVector[i]];
			}
			/*else {
				[solutionDump_normal appendFormat:@"\r%@", [[relevantSecurities objectAtIndex:i] valueForKey:@"symbol"]];
			}*/
		}
		double solutionStrength_current = (returnMultiplier*solutionReturnMean_proposed)-solutionReturnVariance_proposed;
		//[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"%@\r\treturn = %f\r\tvariance = %f\r\r\r",solutionDump_normal,solutionReturnMean_proposed,solutionReturnVariance_proposed,solutionStrength_current);
		//[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"\tNext solution: return = %f, variance = %f", solutionReturnMean_proposed, solutionReturnVariance_proposed, solutionStrength_current);
		
		NSUInteger optimizationIterations;
		BOOL foundBetterSolution = YES;
		
		for( optimizationIterations = 0; foundBetterSolution; optimizationIterations++ ) {
			if( optimizationIterations % 1000 == 0 && optimizationIterations != 0 ) [[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"optimizationIterations = %u", optimizationIterations]];
			
			[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
			double nextSolutionVector[[relevantSecurities count]];
			
			foundBetterSolution = NO;
			
			for( double solutionGradientMagnitude_target = 0.05; (solutionGradientMagnitude_target <= 5000); solutionGradientMagnitude_target *= 1.5 ) {
				//[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"solutionGradientMagnitude_target = %f", solutionGradientMagnitude_target]];
				//Calculate the gradient
				double solutionGradient[[relevantSecurities count]];
				double solutionGradientMagnitude_actual_squared = 0.0;
				for( NSUInteger i = 0; i < [relevantSecurities count]; i++ ) {
					solutionGradient[i] = 0;
					for( NSUInteger c = 0; c < [relevantSecurities count]; c++ ) {
						solutionGradient[i] -= solutionVector[c]*constraints[i][c];
					}
					solutionGradient[i] += constraints[i][[relevantSecurities count]];
					solutionGradientMagnitude_actual_squared += solutionGradient[i]*solutionGradient[i];
				}
				
				//Scale the gradient
				for( NSUInteger i = 0; i < [relevantSecurities count]; i++ ) {
					solutionGradient[i] /= solutionGradientMagnitude_actual_squared;
					solutionGradient[i] *= sqrt(solutionGradientMagnitude_target);
				}
				
				//Propose new unconstrained solution
				double nextSolutionTotalPositive = 0.0;
				for( NSUInteger i = 0; i < [relevantSecurities count]; i++ ) {
					nextSolutionVector[i] = solutionVector[i] + solutionGradient[i];
					nextSolutionTotalPositive += (nextSolutionVector[i] > 0) ? nextSolutionVector[i] : 0;
				}
				
				//Normalize proposed solution
				double nextSolutionScale = 0.0;
				for( NSUInteger i = 0; i < [relevantSecurities count]; i++ ) {
					if(nextSolutionVector[i] / nextSolutionTotalPositive > minimumTargetWeight) {
						nextSolutionScale += nextSolutionVector[i];
					}
					else {
						nextSolutionVector[i] = 0;
					}
				}
				
				solutionReturnMean_proposed = 0.0;
				solutionReturnVariance_proposed = 0.0;
				//Calculate proposed mean, variance, and strength
				for( NSUInteger i = 0; i < [relevantSecurities count]; i++ ) {
					nextSolutionVector[i] /= nextSolutionScale;
					if( nextSolutionVector[i] != 0 ) {
						solutionReturnMean_proposed += nextSolutionVector[i] * [[[relevantSecurities objectAtIndex:i] meanReturn] doubleValue];
						
						for( NSUInteger j = 0; j < [relevantSecurities count]; j++ ) {
							solutionReturnVariance_proposed += nextSolutionVector[i]*nextSolutionVector[j]*constraints[i][j]; //(nextSolutionVector[i]*nextSolutionVector[j]*constraints[i][j] > 0 ? nextSolutionVector[i]*nextSolutionVector[j]*constraints[i][j] : -(nextSolutionVector[i]*nextSolutionVector[j]*constraints[i][j]) );
						}
					}
				}
				
				//Check whether proposed solution is better
				if( (returnMultiplier*solutionReturnMean_proposed)-solutionReturnVariance_proposed > ((solutionStrength_current > 0 ? 1.01 : 1/1.01) * solutionStrength_current)) {
					for( NSUInteger i = 0; i < [relevantSecurities count]; i++ ) {
						solutionVector[i] = nextSolutionVector[i];
					}
					solutionStrength_current = (returnMultiplier*solutionReturnMean_proposed)-solutionReturnVariance_proposed;
					foundBetterSolution = YES;
					
					//[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"\tNext solution: return = %f, variance = %f", solutionReturnMean_proposed, solutionReturnVariance_proposed, solutionStrength_current);
					break;
				}
			}
			
			/*if( ! foundBetterSolution ) {
				break;
			 }*/
			[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
		}
		
		if( optimizationIterations % 1000 != 0 ) [[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"optimizationIterations = %u", optimizationIterations]];
		
		//NSMutableString *solutionDump_final = [NSMutableString stringWithFormat:@"Solution for returnMultiplier = %f after %u iterations has return = %f, variance = %f", returnMultiplier, optimizationIterations, solutionReturnMean_proposed, solutionReturnVariance_proposed];
		
		NSMutableArray *solutionAllocations = [NSMutableArray arrayWithCapacity:[relevantSecurities count]];
		
		for( NSUInteger i = 0; i < [relevantSecurities count]; i++ ) {
			if( solutionVector[i] != 0 ) {
				[solutionAllocations addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:100 * solutionVector[i]], @"targetWeight", [relevantSecurities objectAtIndex:i], @"security", nil]];
				
				//[solutionDump_final appendFormat:@"\r%@\t%f",[[relevantSecurities objectAtIndex:i] valueForKey:@"symbol"],solutionVector[i]];
			}
		}
		[efficientFrontier addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:solutionReturnMean_proposed], @"return", [NSNumber numberWithDouble:solutionReturnVariance_proposed], @"variance", solutionAllocations, @"allocations", [NSNumber numberWithDouble:returnMultiplier], @"returnMultiplier", [NSNumber numberWithUnsignedInteger:optimizationIterations], @"optimizationIterations", nil]];
		
		[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	}
	
	[efficientFrontier sortUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"return" ascending:YES]]];
						/*sortUsingComparator: ^(id entry1, id entry2) {
		return (NSComparisonResult)[(NSNumber *)[(NSDictionary *)entry1 valueForKey:@"return"] compare:[(NSDictionary *)entry2 valueForKey:@"return"]];
	}];*/
	
	for( NSUInteger i = 0; i < [efficientFrontier count]; i++ ) {
		[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"return = %@, variance = %@ (found at returnMultiplier = %@ after %@ iterations)", [[efficientFrontier objectAtIndex:i] valueForKey:@"return"], [[efficientFrontier objectAtIndex:i] valueForKey:@"variance"], [[efficientFrontier objectAtIndex:i] valueForKey:@"returnMultiplier"], [[efficientFrontier objectAtIndex:i] valueForKey:@"optimizationIterations"]]];
	}
	
	for( NSUInteger i = [efficientFrontier count] - 1; i > 0; i-- ) {
		if( [(NSNumber *)[[efficientFrontier objectAtIndex:i-1] valueForKey:@"variance"] compare:(NSNumber *)[[efficientFrontier objectAtIndex:i] valueForKey:@"variance"]] != NSOrderedAscending ) {
			[efficientFrontier removeObjectAtIndex:i-1];
			i += i < [efficientFrontier count] ? 1 : 0;
		}
	}
	
	[frontierArrayController addObjects:efficientFrontier];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
}

- (IBAction)modelFrontierSelection:(id)sender
{
	(void)sender;
	if( [[frontierArrayController selectedObjects] count] == 1 ) {
		NSDictionary *frontierSelection = [[frontierArrayController selectedObjects] objectAtIndex:0];
		
		NSManagedObjectContext *managedObjectContext = [(Portfolio_Manager_AppDelegate *)[(NSApplication *)[NSApplication sharedApplication] delegate] managedObjectContext];
		
		NSManagedObject *newModel = [NSEntityDescription insertNewObjectForEntityForName:@"Model" inManagedObjectContext:managedObjectContext];
		[newModel setValue:@"Unnamed" forKey:@"name"];
		
		for( NSDictionary *currentAllocation in [frontierSelection valueForKey:@"allocations"] ) {
			NSManagedObject *newTarget = [NSEntityDescription insertNewObjectForEntityForName:@"Target" inManagedObjectContext:managedObjectContext];
			
			[newTarget setValue:[currentAllocation valueForKey:@"security"] forKey:@"security"];
			[newTarget setValue:[currentAllocation valueForKey:@"targetWeight"] forKey:@"weight"];
			
			[[newModel mutableSetValueForKey:@"targets"] addObject:newTarget];
		}
		[mainTabView selectTabViewItem:modelsTabViewItem];
	}
}

- (IBAction)openNewHoldingSheet:(id)sender
{
	(void)sender;
	[[NSApplication sharedApplication] beginSheet:newHoldingSheet modalForWindow:myWindow modalDelegate:nil didEndSelector:nil contextInfo:NULL]; 	
}

- (IBAction)closeNewHoldingSheet:(id)sender
{ 
	[[NSApplication sharedApplication] endSheet:newHoldingSheet returnCode:NSCancelButton];
	
	[newHoldingSheet orderOut:sender];
}

- (IBAction)addHoldingFromNewHoldingSheetToSelectedPortfolio:(id)sender
{
	NSManagedObject *securityToAdd = [[securityArrayController arrangedObjects] objectAtIndex:[newHoldingPopUpButton indexOfSelectedItem]];
	
	Position *newPosition; 
	newPosition = (Position *)[NSEntityDescription insertNewObjectForEntityForName:@"Position" inManagedObjectContext:[portfolioArrayController managedObjectContext]];
	
	[newPosition setValue:securityToAdd forKey:@"security"];
	[positionArrayController addObject:newPosition];
	
	[self closeNewHoldingSheet:sender];
}

@end
