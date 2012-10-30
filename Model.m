//
//  Model.m
//  Portfolio Manager
//
//  Created by Hans Anderson on 10/01/02.
//  Copyright 2010 ultraMentem Tech Studios. All rights reserved.
//

#import "Portfolio_Manager_AppDelegate.h"
#import "Logger.h"
#import "Model.h"
#import "Position.h"
#import "Security.h"

@implementation Model

- (NSDecimalNumber *)totalWeight
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"model->totalWeight"]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	if( totalWeight == nil ) {
		totalWeight = [NSDecimalNumber zero];
		for( NSManagedObject *target_i in [self mutableSetValueForKey:@"targets"] ) {
			totalWeight = [totalWeight decimalNumberByAdding:[target_i valueForKey:@"weight"]];
		}
	}
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	return totalWeight;
}

- (NSNumber *)countOfSecurities
{
	return [NSNumber numberWithUnsignedInteger:[[self mutableSetValueForKey:@"targets"] count]];
}

- (NSNumber *)variance
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"model->variance"]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	NSSet *targets = [self mutableSetValueForKey:@"targets"];
	double variance = 0.0;
	for( NSManagedObject *target_i in targets ) {
		for( NSManagedObject *target_j in targets ) {
			double covariance_i_j = ([[target_i valueForKey:@"weight"] doubleValue]/[[self totalWeight] doubleValue])
			* ([[target_j valueForKey:@"weight"] doubleValue]/[[self totalWeight] doubleValue])
			* [[[target_i valueForKey:@"security"] covarianceWithSecurity:[target_j valueForKey:@"security"]] doubleValue];
			
			//covariance_i_j = covariance_i_j > 0 ? covariance_i_j : -covariance_i_j;
			
			variance += covariance_i_j;
		}
	}
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	return [NSNumber numberWithDouble:variance];
}

- (NSNumber *)meanReturn
{
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"model->meanReturn"]];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] increaseIndentationLevel];
	NSSet *targets = [self mutableSetValueForKey:@"targets"];
	double meanReturn = 0.0;
	for( NSManagedObject *target_i in targets ) {
		meanReturn += ([[target_i valueForKey:@"weight"] doubleValue]/[[self totalWeight] doubleValue]) * [[[target_i valueForKey:@"security"] meanReturn] doubleValue];
	}
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] decreaseIndentationLevel];
	return [NSNumber numberWithDouble:meanReturn];
}

@end
