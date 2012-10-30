//
//  TransactionSheetController.m
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/08/19.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TransactionSheetController.h"
#import "Portfolio_Manager_AppDelegate.h"
#import "Logger.h"
#import "Transaction.h"
#import "Security.h"
#import "Portfolio.h"

@implementation TransactionSheetController

- (IBAction)openTransactionsSheet:(id)sender
{
	(void)sender;
	
	
	[securityPopup removeAllItems];
	[securityPopup addItemWithTitle:@"Cash Balance"];
	
	for( Security *security_i in [securityArrayController arrangedObjects] ) {
		[securityPopup addItemWithTitle:[security_i symbolAndName]];
	}
	
	[self clearTransactionSheet];
	[self updateTransactionInterface:sender];
	
	[[NSApplication sharedApplication] beginSheet:transactionSheet modalForWindow:[[NSApplication sharedApplication] mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:NULL];
}

- (IBAction)closeTransactionsSheet:(id)sender
{
	(void)sender;
	
	[[NSApplication sharedApplication] endSheet:transactionSheet returnCode:NSCancelButton];
	[transactionSheet orderOut:sender];
}

- (IBAction)addTransactionFromSheet:(id)sender
{
	(void)sender;
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"addTransactionFromSheet"]];
	
	Transaction *newTransaction = (Transaction *)[NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] managedObjectContext]];
	[newTransaction setValue:[executionDatePicker dateValue] forKey:@"executionDate"];
	
	NSDecimalNumber *priceMultiplier = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:0 isNegative:([securityPopup indexOfSelectedItem] == 0 && [actionPopup indexOfSelectedItem] != 0)];
	NSDecimalNumber *quantityMultiplier = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:0 isNegative:([actionPopup indexOfSelectedItem] == 1)];
	
	NSString *quantityString = [quantityField stringValue];
	NSString *priceString = [priceField stringValue];
	NSString *feeString = [feeField stringValue];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"\tspecifics... (price = %@*%@, quantity = %@*%@, fee = %@)",priceMultiplier,priceString,quantityMultiplier,quantityString,feeString]];
	
	if( [securityPopup indexOfSelectedItem] != 0 )
		[newTransaction setValue:[[securityArrayController arrangedObjects] objectAtIndex:([securityPopup indexOfSelectedItem] - 1)] forKey:@"security"];
	
	if( [quantityField isEnabled] && [quantityField doubleValue] != 0 )
		[newTransaction setValue:[[NSDecimalNumber decimalNumberWithString:[quantityField stringValue]] decimalNumberByMultiplyingBy:quantityMultiplier] forKey:@"quantity"];
	if( [priceField isEnabled] && [priceField doubleValue] != 0 )
		[newTransaction setValue:[[NSDecimalNumber decimalNumberWithString:[priceField stringValue]] decimalNumberByMultiplyingBy:priceMultiplier] forKey:@"price"];
	if( [feeField doubleValue] != 0 )
		[newTransaction setValue:[NSDecimalNumber decimalNumberWithString:[feeField stringValue]] forKey:@"fee"];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"\tadd to portfolio..."]];
	//[[(Portfolio *)[[portfolioArrayController selectedObjects] objectAtIndex:0] mutableSetValueForKey:@"transactions"] addObject:newTransaction];
	
	[[transactionArrayController managedObjectContext] insertObject:newTransaction];
	[transactionArrayController addObject:newTransaction];
	
	[[[portfolioArrayController selectedObjects] objectAtIndex:0] willChangeValueForKey:@"positions"];
	[[[portfolioArrayController selectedObjects] objectAtIndex:0] didChangeValueForKey:@"positions"];
	[[[portfolioArrayController selectedObjects] objectAtIndex:0] positions];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"\tclear sheet..."]];
	[self clearTransactionSheet];
}

- (void)clearTransactionSheet
{
	[quantityField setDoubleValue:0];
	[priceField setDoubleValue:0];
	[transactionSheet makeFirstResponder:securityPopup];
}

- (IBAction)updateTransactionInterface:(id)sender
{
	(void)sender;
	if( [securityPopup indexOfSelectedItem] == 0 ) {
		[quantityField setEnabled:NO];
		NSArray *cashActionTitles = [NSArray arrayWithObjects:@"Withdraw",@"Deposit",@"Interest",nil];
		if( ![[actionPopup itemTitles] isEqualToArray:cashActionTitles] ) {
			[actionPopup removeAllItems];
			[actionPopup addItemsWithTitles:cashActionTitles];
			[actionPopup selectItemAtIndex:0];
		}
	}
	else {
		NSArray *securityActionTitles = [NSArray arrayWithObjects:@"Buy",@"Sell",@"Dividend",@"Split",nil];
		if( ![[actionPopup itemTitles] isEqualToArray:securityActionTitles] ) {
			[actionPopup removeAllItems];
			[actionPopup addItemsWithTitles:securityActionTitles];
			[actionPopup selectItemAtIndex:0];
		}
		
		if( [actionPopup indexOfSelectedItem] == 2 ) {
			[quantityField setEnabled:NO];
		}
		else {
			[quantityField setEnabled:YES];
		}
	}
	[priceField setEnabled:([actionPopup indexOfSelectedItem] != 3)];
	[quantityField setEnabled:([securityPopup indexOfSelectedItem] != 0 && [actionPopup indexOfSelectedItem] != 2)];
}

@end
