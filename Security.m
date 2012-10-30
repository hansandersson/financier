//
//  Security.m
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/08/21.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Security.h"
#import "Portfolio_Manager_AppDelegate.h"
#import "Logger.h"

@implementation Security

@synthesize meanReturn;
@synthesize beta;
@synthesize alpha;
@synthesize unsystematicRisk;
@synthesize geometricMeanReturn;

- (void)recalculateStatistics
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"Recalculating statistics for %@...",[self valueForKey:@"symbol"]]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	
	//Mean return
	double previousAdjustedClose = 0.0;
	double meanReturn_local = 0.0;
	double geometricMeanReturn_local = 1.0;
	//double timeDiscountFactor = 0.99725;
	
	NSArray *ascendingDataPoints = [self dataPointsSortedAscending:YES];
	
	for( NSManagedObject *dataPoint_i in ascendingDataPoints ) {
		double adjustedClose = [[dataPoint_i valueForKey:@"adjustedClosePrice"] doubleValue];
		if( !previousAdjustedClose ) previousAdjustedClose = adjustedClose;
		
		double returnFromPrevious = 100*((adjustedClose - previousAdjustedClose)/previousAdjustedClose);
		
		[dataPoint_i setValue:[NSNumber numberWithDouble:returnFromPrevious] forKey:@"returnFromPrevious"];
		
		meanReturn_local += returnFromPrevious/[ascendingDataPoints count];
		
		geometricMeanReturn_local *= pow(100 + returnFromPrevious, 1/[ascendingDataPoints count]);
		
		previousAdjustedClose = adjustedClose;
	}
	
	[self willChangeValueForKey:@"meanReturn"];
	meanReturn = [NSNumber numberWithDouble:meanReturn_local];
	[self didChangeValueForKey:@"meanReturn"];
	
	[self willChangeValueForKey:@"geometricMeanReturn"];
	geometricMeanReturn = [NSNumber numberWithDouble:geometricMeanReturn_local - 100];
	[self didChangeValueForKey:@"geometricMeanReturn"];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"meanReturn = %@",meanReturn]];
	
	//Beta
	NSArray *descendingDataPoints = [self dataPointsSortedAscending:NO];
	
	double marketReturnMean = [[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] marketReturnMean] doubleValue];
	
	double beta_local = 0.0;
	
	NSInteger indexDiscrepancy = 0;
	NSManagedObject *firstDataPoint;
	NSDictionary *firstMarketDataPoint;
	for(
		firstDataPoint = [descendingDataPoints objectAtIndex:(indexDiscrepancy > 0 ? indexDiscrepancy : 0)],
		firstMarketDataPoint = [[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] marketDataArray] objectAtIndex:(indexDiscrepancy < 0 ? -indexDiscrepancy : 0)];
		
		![[firstMarketDataPoint valueForKey:@"dateString"] isEqualToString:[firstDataPoint valueForKey:@"dateString"]];
		
		firstDataPoint = [descendingDataPoints objectAtIndex:(indexDiscrepancy > 0 ? indexDiscrepancy : 0)],
		firstMarketDataPoint = [[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] marketDataArray] objectAtIndex:(indexDiscrepancy < 0 ? -indexDiscrepancy : 0)]
		)
	{
		indexDiscrepancy += [[firstDataPoint valueForKey:@"dateString"] caseInsensitiveCompare:[firstMarketDataPoint valueForKey:@"dateString"]] == NSOrderedDescending ? 1 : -1;
		[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"Adjusting index discrepancy for %@ to %li", [self valueForKey:@"symbol"], indexDiscrepancy ]];
	}
	
	for( NSUInteger i = 0; ((indexDiscrepancy > 0 ? i+indexDiscrepancy : i) < [descendingDataPoints count]) && ((indexDiscrepancy < 0 ? i-indexDiscrepancy : i) < [[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] marketDataArray] count]); i++ ) {
		NSManagedObject *dataPoint_i = [descendingDataPoints objectAtIndex:(indexDiscrepancy > 0 ? i+indexDiscrepancy : i)];
		NSDictionary *marketDataPoint_i = [[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] marketDataArray] objectAtIndex:(indexDiscrepancy < 0 ? i-indexDiscrepancy : i)];
		
		double return_i = [[dataPoint_i valueForKey:@"returnFromPrevious"] doubleValue];
		double marketReturn_i = [[marketDataPoint_i valueForKey:@"dailyReturn"] doubleValue];
		
		if( [[marketDataPoint_i valueForKey:@"dateString"] isEqualToString:[dataPoint_i valueForKey:@"dateString"]] ) {
			beta_local += (return_i - meanReturn_local)*(marketReturn_i - marketReturnMean);
		}
		else {
			[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"dateString \"%@\" for data point of \"%@\" doesn't match market dateString \"%@\" when i=%lu", [dataPoint_i valueForKey:@"dateString"], [self valueForKey:@"name"], [marketDataPoint_i valueForKey:@"dateString"], i ]];
			break;
			[NSException raise:@"HADataMismatch" format:@"dateString \"%@\" for data point of \"%@\" doesn't match market dateString \"%@\" when i=%lu", [dataPoint_i valueForKey:@"dateString"], [self valueForKey:@"name"], [marketDataPoint_i valueForKey:@"dateString"], i];
		}
	}
	
	beta_local /= [[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] marketReturnVariance] doubleValue];
	
	[self willChangeValueForKey:@"beta"];
	beta = [NSNumber numberWithDouble:beta_local];
	[self didChangeValueForKey:@"beta"];

	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"beta = %@",beta]];
	
	//Alpha
	double alpha_local = meanReturn_local - (beta_local * marketReturnMean);
	
	[self willChangeValueForKey:@"alpha"];
	alpha = [NSNumber numberWithDouble:alpha_local];
	[self didChangeValueForKey:@"alpha"];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"alpha = %@",alpha]];
	
	//Unsystemic risk
	double unsystematicRisk_local = 0.0;
	
	NSUInteger riskPoints = 0;
	
	for( NSUInteger i = 0; ((indexDiscrepancy > 0 ? i+indexDiscrepancy : i) < [descendingDataPoints count]) && ((indexDiscrepancy < 0 ? i-indexDiscrepancy : i) < [[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] marketDataArray] count]); i++ ) {
		NSManagedObject *dataPoint_i = [descendingDataPoints objectAtIndex:(indexDiscrepancy > 0 ? i+indexDiscrepancy : i)];
		NSDictionary *marketDataPoint_i = [[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] marketDataArray] objectAtIndex:(indexDiscrepancy < 0 ? i-indexDiscrepancy : i)];
		
		double return_i = [[dataPoint_i valueForKey:@"returnFromPrevious"] doubleValue];
		double marketReturn_i = [[marketDataPoint_i valueForKey:@"dailyReturn"] doubleValue];
		
		if( [[marketDataPoint_i valueForKey:@"dateString"] isEqualToString:[dataPoint_i valueForKey:@"dateString"]] ) {
			double predictedReturn_i = alpha_local + (beta_local*marketReturn_i);
			unsystematicRisk_local += (return_i - predictedReturn_i)*(return_i - predictedReturn_i);
			riskPoints++;
		}
		else {
			[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"dateString \"%@\" for data point of \"%@\" doesn't match market dateString \"%@\" when i=%lu", [dataPoint_i valueForKey:@"dateString"], [self valueForKey:@"name"], [marketDataPoint_i valueForKey:@"dateString"], i ]];
			break;
			[NSException raise:@"HADataMismatch" format:@"dateString \"%@\" for data point of \"%@\" doesn't match market dateString \"%@\" when i=%lu", [dataPoint_i valueForKey:@"dateString"], [self valueForKey:@"name"], [marketDataPoint_i valueForKey:@"dateString"], i];
		}
	}
	
	unsystematicRisk_local /= riskPoints;
	
	[self willChangeValueForKey:@"unsystematicRisk"];
	unsystematicRisk = [NSNumber numberWithDouble:unsystematicRisk_local];
	[self didChangeValueForKey:@"unsystematicRisk"];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"unsystematicRisk = %@",unsystematicRisk]];
	
	/*
	//Inclusion rank
	[self willChangeValueForKey:@"inclusionRank"];
	inclusionRank = (beta_local != 0 ? [NSNumber numberWithDouble:(meanReturn_local - [[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] riskFreeReturn] decimalValue])/beta_local] : nil);
	[self didChangeValueForKey:@"inclusionRank"];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"inclusionRank = %@",inclusionRank);
	 */
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
}

- (IBAction)updateDataPoints:(id)sender
{
	(void)sender;
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"Fetching history for %@...",[self valueForKey:@"symbol"]]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	
	NSString *symbolToQuery = [self valueForKey:@"symbol"];
	
	//NSString *downloadURLstring = [NSString stringWithFormat:@"http://ichart.finance.yahoo.com/table.csv?s=%@%@",symbolToQuery,[myMarketWindowController downloadURLparametersString]];
	NSString *downloadURLstring = [NSString stringWithFormat:@"http://ichart.finance.yahoo.com/table.csv?s=%@",symbolToQuery];
	
	NSError *downloadError = nil;
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"Starting download..."]];
	NSString *downloadResultString = [NSString stringWithContentsOfURL:[NSURL URLWithString:downloadURLstring] encoding:NSUTF8StringEncoding error:&downloadError];
	
	if( downloadError == nil ) {
		[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"Parsing downloaded data..."]];
		NSMutableArray *downloadResultArray = [NSMutableArray arrayWithArray:[downloadResultString componentsSeparatedByString:@"\n"]];
		[downloadResultArray removeObject:[downloadResultArray objectAtIndex:0]];
		[downloadResultArray removeLastObject];
		
		NSArray *existingDataPointArray = [[[self mutableSetValueForKey:@"dataPoints"] allObjects] mutableCopy];
		
		if( [existingDataPointArray count] != [downloadResultArray count] ) {
			[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"download contains new data..."]];
			[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
			
			for( NSString *currentEntry in downloadResultArray ) {
				NSArray *dataPointEntries = [currentEntry componentsSeparatedByString:@","];
				
				NSString *newDataPointDateString = [[dataPointEntries objectAtIndex:0] stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
				
				NSManagedObject *correspondingDataPoint;
				
				NSArray *matchingDataPoints = [existingDataPointArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"dateString == %@",newDataPointDateString]];
				
				if( [matchingDataPoints count] == 0 ) {
					[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:newDataPointDateString];
					correspondingDataPoint = [NSEntityDescription insertNewObjectForEntityForName:@"DataPoint" inManagedObjectContext:[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] managedObjectContext]];
					
					[correspondingDataPoint setValue:[[dataPointEntries objectAtIndex:0] stringByReplacingOccurrencesOfString:@"-" withString:@"/"] forKey:@"dateString"];
					[correspondingDataPoint setValue:[NSDecimalNumber decimalNumberWithString:[dataPointEntries objectAtIndex:1]] forKey:@"openPrice"];
					[correspondingDataPoint setValue:[NSDecimalNumber decimalNumberWithString:[dataPointEntries objectAtIndex:2]] forKey:@"highPrice"];
					[correspondingDataPoint setValue:[NSDecimalNumber decimalNumberWithString:[dataPointEntries objectAtIndex:3]] forKey:@"lowPrice"];
					[correspondingDataPoint setValue:[NSDecimalNumber decimalNumberWithString:[dataPointEntries objectAtIndex:4]] forKey:@"closePrice"];
					[correspondingDataPoint setValue:[NSDecimalNumber decimalNumberWithString:[dataPointEntries objectAtIndex:5]] forKey:@"tradeVolume"];
					
					[[self mutableSetValueForKey:@"dataPoints"] addObject:correspondingDataPoint];
				}
				else {
					correspondingDataPoint = [matchingDataPoints objectAtIndex:0];
				}
				[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
				
				[correspondingDataPoint setValue:[NSDecimalNumber decimalNumberWithString:[dataPointEntries objectAtIndex:6]] forKey:@"adjustedClosePrice"];
			}
			
			for( NSManagedObject *covariance_i in [self mutableSetValueForKey:@"covariances"] ) {
				[[self managedObjectContext] deleteObject:covariance_i];
			}
			
			[self recalculateStatistics];
		}
		else {
			[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"download contains NO new data"]];
		}
	}
	else {
		[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"error downloading"]];
	}
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
}

- (NSNumber *)countOfDataPoints
{
	return [NSNumber numberWithUnsignedInteger:[[self mutableSetValueForKey:@"dataPoints"] count]];
}

- (NSArray *)dataPointsSortedAscending:(BOOL)ascending
{
	return [[[[[self mutableSetValueForKey:@"dataPoints"] allObjects] mutableCopy] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"dateString" ascending:ascending]]] copy];
}

- (IBAction)updateMostRecentPrice:(id)sender
{
	(void)sender;
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"Updating price for %@...",[self valueForKey:@"symbol"]]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	
	NSError *downloadError = nil;
	NSArray *parsedData = [NSArray array];
	
	for( NSUInteger i = 0; i < 3 && [parsedData count] <= 1; i++ ) {
		NSString *quoteReturnString = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://finance.yahoo.com/q?s=%@",[self valueForKey:@"symbol"]]] encoding:NSUTF8StringEncoding error:&downloadError];
		parsedData = [quoteReturnString componentsSeparatedByString:[NSString stringWithFormat:@"<span id=\"yfs_l10_%@\">",[[self valueForKey:@"symbol"] lowercaseString]]];
	}
		
	if( downloadError == nil && [parsedData count] > 1) {
		NSString *priceString = [[[parsedData objectAtIndex:1] componentsSeparatedByString:@"</span>"] objectAtIndex:0];
		if( [[NSDecimalNumber decimalNumberWithString:priceString] compare:[NSDecimalNumber zero]] != NSOrderedSame ) {
			[self setValue:[NSDecimalNumber decimalNumberWithString:priceString] forKey:@"mostRecentPrice"];
			[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"mostRecentPrice = %@",[self valueForKey:@"mostRecentPrice"]]];
		}
	}
	else {
		[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"error downloading"]];
	}
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
}

- (NSNumber *)covarianceWithSecurity:(Security *)otherSecurity
{
	NSMutableArray *covariances = [[[self mutableSetValueForKey:@"covariances"] allObjects] mutableCopy];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	
	//[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"%@: checking my %u covariances for %@...", [self valueForKey:@"symbol"], [[self mutableSetValueForKey:@"covariances"] count], [otherSecurity valueForKey:@"symbol"] );
	
	for( NSManagedObject *covariance_i in covariances ) {
		BOOL foundCovariance = YES;
		
		NSSet *relevantSecurities = [covariance_i mutableSetValueForKey:@"securities"];
		for( NSManagedObject *security_i in relevantSecurities ) {
			if( security_i != self && security_i != otherSecurity ) {
				foundCovariance = NO;
				break;
			}
		}
		if( foundCovariance ) {
			[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
			return [covariance_i valueForKey:@"computedValue"];
		}
	}
	
	//[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"recomputing COV(%@,%@)...",[self valueForKey:@"symbol"],[otherSecurity valueForKey:@"symbol"]]];
	
	double meanReturn_r = [[self meanReturn] doubleValue];
	double meanReturn_c = [[otherSecurity meanReturn] doubleValue];
	
	NSMutableArray *dataPointsForPosition_r = [[self dataPointsSortedAscending:NO] mutableCopy];
	NSMutableArray *dataPointsForPosition_c = [[otherSecurity dataPointsSortedAscending:NO] mutableCopy];
	
	double covarianceNumerator = 0.0;
	double covarianceDenominator = 0.0;
	
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
			covarianceNumerator += ([[dataPoint_r valueForKey:@"returnFromPrevious"] doubleValue] - meanReturn_r)*([[dataPoint_c valueForKey:@"returnFromPrevious"] doubleValue] - meanReturn_c);
			covarianceDenominator++;
			[dataPointsForPosition_c removeObjectAtIndex:0];
			[dataPointsForPosition_r removeObjectAtIndex:0];
		}
	}
	
	double covariance = covarianceNumerator/covarianceDenominator;
	
	NSManagedObject *newCovariance = [NSEntityDescription insertNewObjectForEntityForName:@"Covariance" inManagedObjectContext:[self managedObjectContext]];
	
	[newCovariance setValue:[NSNumber numberWithDouble:covariance] forKey:@"computedValue"];
	
	[newCovariance setValue:[NSMutableSet setWithArray:[NSArray arrayWithObjects:self, otherSecurity, nil]] forKey:@"securities"];
	
	[[self mutableSetValueForKey:@"covariances"] addObject:newCovariance];
	[[otherSecurity mutableSetValueForKey:@"covariances"] addObject:newCovariance];
	
	//[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"%@", [newCovariance valueForKey:@"computedValue"]]];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	return [newCovariance valueForKey:@"computedValue"];
}

- (NSNumber *)variance
{
	return [self covarianceWithSecurity:self];
}

- (NSString *)symbolAndName
{
	return [NSString stringWithFormat:@"%@—%@",[self valueForKey:@"symbol"],[self valueForKey:@"name"]];
}

@end
