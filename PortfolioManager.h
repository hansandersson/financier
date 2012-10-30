//
//  PortfolioManager.h
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/03/10.
//  Copyright 2009 Hans Anderson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MarketWindowController;

@interface PortfolioManager : NSObject {
	IBOutlet NSArrayController *securityArrayController;
	IBOutlet NSArrayController *portfolioArrayController;
	IBOutlet NSArrayController *positionArrayController;
	IBOutlet NSArrayController *frontierArrayController;
	
	IBOutlet NSTabView *mainTabView;
	IBOutlet NSTabViewItem *modelsTabViewItem;
	
	IBOutlet MarketWindowController *myMarketWindowController;
	
	IBOutlet NSWindow *myWindow;
	IBOutlet NSPanel *newHoldingSheet;
	IBOutlet NSPopUpButton *newHoldingPopUpButton;
}

- (IBAction)populate:(id)sender;
- (IBAction)rebalance:(id)sender;

- (IBAction)traceEfficientFrontier:(id)sender;
- (IBAction)modelFrontierSelection:(id)sender;

- (IBAction)openNewHoldingSheet:(id)sender;
- (IBAction)closeNewHoldingSheet:(id)sender;
- (IBAction)addHoldingFromNewHoldingSheetToSelectedPortfolio:(id)sender;

@end
