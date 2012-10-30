//
//  Suggestion.m
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/04/13.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Suggestion.h"
#import "Position.h"


@implementation Suggestion

@synthesize relatedPosition;

+ (Suggestion*)suggestionForPosition:(Position*)aPosition
{
    id newSuggestion = [[[self alloc] init] autorelease];
    [newSuggestion setRelatedPosition:aPosition];
    
    return newSuggestion;
}

- (NSString *) securitySymbol
{
	return [[[self relatedPosition] security] valueForKey:@"symbol"];
}

- (NSString *) securityName
{
	return [[[self relatedPosition] security] valueForKey:@"name"];
}

- (NSNumber *) roundQuantity
{
	double quantity = [[self quantity] doubleValue];
	return [NSNumber numberWithInteger:(NSInteger) (quantity + 0.5)];
}

- (NSNumber *) quantity
{
	double quantity = [[[self relatedPosition] targetQuantity] doubleValue] - [[[self relatedPosition] currentQuantity] doubleValue];
	return [NSNumber numberWithDouble:(quantity > 0 ? quantity : 0 - quantity)];
}

- (Portfolio *) portfolio
{
	return [[self relatedPosition] portfolio];
}

- (NSString *) transactionType
{
	double quantity = [[[self relatedPosition] targetQuantity] doubleValue] - [[[self relatedPosition] currentQuantity] doubleValue];
	return quantity > 0 ? @"Buy" : @"Sell";
}

@end
