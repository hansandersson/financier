//
//  Market.m
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/03/10.
//  Copyright 2009 Hans Anderson. All rights reserved.
//

#import "MarketWindowController.h"


@implementation MarketWindowController

@synthesize marketMonthlyTotalReturns;

- (IBAction)updateMarketWindow:(id)sender
{
	(void)sender;
	NSString *downloadURLstring = [NSString stringWithFormat:@"http://ichart.finance.yahoo.com/table.csv?s=%@%@",[marketIndexSymbolTextField stringValue],[self downloadURLparametersString]];
	
	NSString *baselineReturnString = [NSString stringWithContentsOfURL:[NSURL URLWithString:downloadURLstring] encoding:NSUTF8StringEncoding error:NULL];
	
	NSMutableArray *baselineReturnStringEntries = [NSMutableArray arrayWithArray:[baselineReturnString componentsSeparatedByString:@"\n"]];
	[baselineReturnStringEntries removeObject:[baselineReturnStringEntries objectAtIndex:0]];
	[baselineReturnStringEntries removeLastObject];
	
	NSMutableArray *adjustedMonthlyClosingPrices = [NSMutableArray arrayWithCapacity:[baselineReturnStringEntries count]];
	
	for( NSString *currentEntry in baselineReturnStringEntries ) {
		[adjustedMonthlyClosingPrices addObject:[NSDictionary dictionaryWithObjectsAndKeys:[[currentEntry componentsSeparatedByString:@","] objectAtIndex:0],@"month",[[currentEntry componentsSeparatedByString:@","] lastObject],@"adjustedClosingPrice",nil]];
	}
	
	[marketMonthlyTotalReturns removeAllObjects];
	
	for( NSUInteger i = 0; i < ([adjustedMonthlyClosingPrices count] - 1); i++ ) {
		NSString *currentMonth = [[adjustedMonthlyClosingPrices objectAtIndex:i] valueForKey:@"month"];
		double currentMonthClosingPrice = [[[adjustedMonthlyClosingPrices objectAtIndex:i] valueForKey:@"adjustedClosingPrice"] doubleValue];
		double previousMonthClosingPrice = [[[adjustedMonthlyClosingPrices objectAtIndex:(i+1)] valueForKey:@"adjustedClosingPrice"] doubleValue];
		
		[marketMonthlyTotalReturns addObject:[NSDictionary dictionaryWithObjectsAndKeys:
													   [NSNumber numberWithDouble:100*((currentMonthClosingPrice - previousMonthClosingPrice)/previousMonthClosingPrice)],
													   @"return",
													   currentMonth,
													   @"month",
													   nil]
		 ];
	}
	
	[marketMonthlyTotalReturnsArrayController didChangeValueForKey:@"arrangedObjects"];
	
	double marketMeanMonthlyTotalReturn = 0;
	
	for( NSDictionary *currentMonthEntry in marketMonthlyTotalReturns ) {
		double currentMarketMonthlyTotalReturn = [[currentMonthEntry valueForKey:@"return"] doubleValue];
		marketMeanMonthlyTotalReturn += currentMarketMonthlyTotalReturn / [marketMonthlyTotalReturns count];
	}
	
	[marketMeanMonthlyTotalReturnTextField setDoubleValue:marketMeanMonthlyTotalReturn];
	
	double marketVarianceMonthlyTotalReturn = 0;
	
	for( NSDictionary *currentMonthEntry in marketMonthlyTotalReturns ) {
		double currentMarketMonthlyTotalReturn = [[currentMonthEntry valueForKey:@"return"] doubleValue];
		marketVarianceMonthlyTotalReturn += (currentMarketMonthlyTotalReturn - marketMeanMonthlyTotalReturn)*(currentMarketMonthlyTotalReturn - marketMeanMonthlyTotalReturn);
	}
	
	[marketVarianceMonthlyTotalReturnTextField setDoubleValue:marketVarianceMonthlyTotalReturn];
	
	NSString *baselineRiskFreeString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.ustreas.gov/offices/domestic-finance/debt-management/interest-rate/daily_treas_bill_rates.xml"] encoding:NSUTF8StringEncoding error:NULL];
	
	double riskFreeRate = [[[[[[[baselineRiskFreeString componentsSeparatedByString:@"</G_CS_4WK_CLOSE_AVG>"] objectAtIndex:[[baselineRiskFreeString componentsSeparatedByString:@"</G_CS_4WK_CLOSE_AVG>"] count] - 2] componentsSeparatedByString:@"<CS_4WK_YIELD_AVG>"] objectAtIndex:1] componentsSeparatedByString:@"</CS_4WK_YIELD_AVG>"] objectAtIndex:0] doubleValue];
	
	[riskFreeAssetReturnTextField setDoubleValue:riskFreeRate];
	
	[dateFetchedTextField setStringValue:[[NSDate date] description]];
}

- (double)marketMeanMonthlyTotalReturn
{
	return [marketMeanMonthlyTotalReturnTextField doubleValue];
}

- (double)marketVarianceMonthlyTotalReturn
{
	return [marketVarianceMonthlyTotalReturnTextField doubleValue];
}

- (double)riskFreeAssetReturn
{
	return [riskFreeAssetReturnTextField doubleValue];
}

- (NSString*)downloadURLparametersString
{
	NSCalendarDate *currentDate = [NSCalendarDate calendarDate];
	
	NSNumber *endYear = [NSNumber numberWithInteger:[currentDate yearOfCommonEra]];
	NSNumber *month = [NSNumber numberWithInteger:([currentDate monthOfYear]-1)];
	NSNumber *date = [NSNumber numberWithInteger:1];
	
	NSNumber *startYear = [NSNumber numberWithInteger:([currentDate yearOfCommonEra]-10)];
	
	NSString *downloadURLparametersString = @"";
	downloadURLparametersString = [downloadURLparametersString stringByAppendingString:[NSString stringWithFormat:@"&a=%@",month]];
	downloadURLparametersString = [downloadURLparametersString stringByAppendingString:[NSString stringWithFormat:@"&b=%@",date]];
	downloadURLparametersString = [downloadURLparametersString stringByAppendingString:[NSString stringWithFormat:@"&c=%@",startYear]];
	
	downloadURLparametersString = [downloadURLparametersString stringByAppendingString:[NSString stringWithFormat:@"&d=%@",month]];
	downloadURLparametersString = [downloadURLparametersString stringByAppendingString:[NSString stringWithFormat:@"&e=%@",date]];
	downloadURLparametersString = [downloadURLparametersString stringByAppendingString:[NSString stringWithFormat:@"&f=%@",endYear]];
	
	downloadURLparametersString = [downloadURLparametersString stringByAppendingString:@"&g=m"];
	downloadURLparametersString = [downloadURLparametersString stringByAppendingString:@"&ignore=.csv"];
	
	return downloadURLparametersString;
}

@end
