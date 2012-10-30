//
//  TransactionSheetController.h
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/08/19.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TransactionSheetController : NSObject {
	IBOutlet NSArrayController *transactionArrayController;
	IBOutlet NSArrayController *securityArrayController;
	IBOutlet NSArrayController *portfolioArrayController;
	
	IBOutlet NSPanel *transactionSheet;
	
	IBOutlet NSDatePicker *executionDatePicker;
	IBOutlet NSPopUpButton *securityPopup;
	IBOutlet NSPopUpButton *actionPopup;
	IBOutlet NSTextField *quantityField;
	IBOutlet NSTextField *priceField;
	IBOutlet NSTextField *feeField;
}

- (void)clearTransactionSheet;

- (IBAction)openTransactionsSheet:(id)sender;
- (IBAction)closeTransactionsSheet:(id)sender;

- (IBAction)addTransactionFromSheet:(id)sender;

- (IBAction)updateTransactionInterface:(id)sender;

@end
