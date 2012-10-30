//
//  SecurityController.m
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/03/11.
//  Copyright 2009 Hans Anderson. All rights reserved.
//

#import "SecurityController.h"
#import "Security.h"

@implementation SecurityController

- (IBAction)updateAllSecurities:(id)sender
{
	(void)sender;
	for( Security *security_i in [securityArrayController arrangedObjects] ) {
		[security_i updateDataPoints:sender];
	}
}

- (IBAction)openNewSecuritySheet:(id)sender
{
	(void)sender;
	//[newSecuritySheet setFrame:NSMakeRect([newSecuritySheet frame].origin.x, [newSecuritySheet frame].origin.y, [newSecuritySheet frame].size.width, 59) display:NO];
	[[NSApplication sharedApplication] beginSheet:newSecuritySheet modalForWindow:myWindow modalDelegate:nil didEndSelector:nil contextInfo:NULL]; 	
}

- (IBAction)addSecurityFromSheet:(id)sender
{
	[addButton setEnabled:NO];
	[securityVerificationProgressIndicator startAnimation:sender];
	
	BOOL shouldAddSymbol = YES;
	
	NSString *securitySymbolToAdd = [[securitySymbolToAddTextField stringValue] uppercaseString];
	
	NSArray *symbols = [[securityArrayController arrangedObjects] mutableArrayValueForKeyPath:@"symbol"];
	
	for( NSString *symbol_i in symbols ) {
		if( [symbol_i isEqualToString:securitySymbolToAdd] ) {
			shouldAddSymbol = NO;
			break;
		}
	}
	
	if( shouldAddSymbol ) {
		NSString *quoteReturnString = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://finance.yahoo.com/q?s=%@",securitySymbolToAdd]] encoding:NSUTF8StringEncoding error:NULL];
		NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:[[[[quoteReturnString componentsSeparatedByString:[NSString stringWithFormat:@"<span id=\"yfs_l10_%@\">",[securitySymbolToAdd lowercaseString]]] objectAtIndex:1] componentsSeparatedByString:@"</span>"] objectAtIndex:0]];
		
		if( price == 0 ) {
			[self resetNewSecuritySheet];
		}
		else {
			Security *securityToAdd = (Security *)[NSEntityDescription insertNewObjectForEntityForName:@"Security" inManagedObjectContext:[securityArrayController managedObjectContext]];
			
			[securityToAdd setValue:securitySymbolToAdd forKey:@"symbol"];
			[securityToAdd setValue:[[[[[quoteReturnString componentsSeparatedByString:@"<h1>"] objectAtIndex:1] componentsSeparatedByString:@"<span>"] objectAtIndex:0] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"] forKey:@"name"];
			[securityToAdd updateDataPoints:sender];
			
			[securityArrayController addObject:securityToAdd];
		}
	}
	
	[securityVerificationProgressIndicator stopAnimation:sender];
	
	[self closeNewSecuritySheet:sender];
	
	[verifyButton setEnabled:YES];
}

- (void)resetNewSecuritySheet
{
	[securitySymbolToAddTextField setStringValue:@""];
	[verifyButton setEnabled:YES];
	[addButton setEnabled:NO];
	
	[newSecuritySheet makeFirstResponder:securitySymbolToAddTextField];
}

- (IBAction)closeNewSecuritySheet:(id)sender
{ 
	(void)sender;
	[[NSApplication sharedApplication] endSheet:newSecuritySheet returnCode:NSCancelButton];
	
	[newSecuritySheet orderOut:self]; 
}

@end
