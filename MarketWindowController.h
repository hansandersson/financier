//
//  Market.h
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/03/10.
//  Copyright 2009 Hans Anderson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MarketWindowController : NSObject {
	IBOutlet NSTextField *marketMeanMonthlyTotalReturnTextField;
	IBOutlet NSTextField *marketVarianceMonthlyTotalReturnTextField;
	IBOutlet NSTextField *riskFreeAssetReturnTextField;
	IBOutlet NSTextField *marketIndexSymbolTextField;
	IBOutlet NSTextField *dateFetchedTextField;
	
	IBOutlet NSArrayController *marketMonthlyTotalReturnsArrayController;
	
	NSMutableArray *marketMonthlyTotalReturns;
}

- (IBAction)updateMarketWindow:(id)sender;

@property (assign,readwrite) __strong NSMutableArray *marketMonthlyTotalReturns;

- (double)marketMeanMonthlyTotalReturn;
- (double)marketVarianceMonthlyTotalReturn;
- (double)riskFreeAssetReturn;
- (NSString*)downloadURLparametersString;

@end
