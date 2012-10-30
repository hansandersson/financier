//
//  Transaction.m
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/08/19.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Portfolio_Manager_AppDelegate.h"
#import "Logger.h"
#import "Transaction.h"
#import "Security.h"

@implementation Transaction

- (NSDecimalNumber *)proceeds
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"transaction->proceeds (%@ on %@)",[(Security *)[self valueForKey:@"security"] valueForKey:@"symbol"],[[self valueForKey:@"executionDate"] description]]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	NSDecimalNumber *price;
	NSDecimalNumber *quantity;

	if( [self valueForKey:@"quantity"] != nil && [(NSDecimalNumber *)[self valueForKey:@"quantity"] compare:[NSDecimalNumber zero]] == NSOrderedSame)
		[self setValue:nil forKey:@"quantity"];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"actualPrice = %@, actualQuantity = %@",[self valueForKey:@"price"],[self valueForKey:@"quantity"]]];
	
	price = [self valueForKey:@"price"];
	quantity = ([self valueForKey:@"quantity"] != nil && [(NSDecimalNumber *)[self valueForKey:@"quantity"] compare:[NSDecimalNumber zero]] != NSOrderedSame) ? [self valueForKey:@"quantity"] : [NSDecimalNumber one];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"price = %@, quantity = %@",price,quantity]];
	NSDecimalNumber *result = [[NSDecimalNumber zero] decimalNumberBySubtracting:[price decimalNumberByMultiplyingBy:quantity]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"result before fee = %@",result]];
	if( [self valueForKey:@"fee"] != nil
	   &&
	   [(NSDecimalNumber *)[self valueForKey:@"fee"] compare:[NSDecimalNumber zero]] != NSOrderedSame ) {
		[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"fee = %@",[self valueForKey:@"fee"]]];
		result = [result decimalNumberBySubtracting:[self valueForKey:@"fee"]];
	}
	else {
		[self setValue:nil forKey:@"fee"];
	}
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"done with result = %@",result]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	return result;
}

- (NSDecimalNumber *)presentValue
{
	if( [self valueForKey:@"security"] == nil || [self valueForKey:@"quantity"] == nil ) return [NSDecimalNumber zero];
	
	return [(NSDecimalNumber *)[self valueForKeyPath:@"security.mostRecentPrice"] decimalNumberByMultiplyingBy:[self valueForKey:@"quantity"]];
}

- (NSString *) securitySymbolAndName
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"transaction->securitySymbolAndName"]];
	return [self valueForKey:@"security"] != nil ? [(Security *)[self valueForKey:@"security"] symbolAndName] : @"Cash Balance";
}

@end
