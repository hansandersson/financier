//
//  Logger.m
//  Portfolio Manager
//
//  Created by Hans Anderson on 10/01/04.
//  Copyright 2010 ultraMentem Tech Studios. All rights reserved.
//

#import "Logger.h"


@implementation Logger

@synthesize enabled;

- (id)init
{
	self = [super init];
    if( self != nil ) {
		indentationLevel = 0;
		enabled = NO;
    }
	
    return self;
}

- (void)log:(NSString *)entryString
{
	if( enabled ) {
		NSMutableString *indentationString = [NSMutableString string];
		for( NSUInteger i = 0; i < indentationLevel; i++ ) {
			[indentationString appendString:@"  "];
		}
		NSLog(@"%@%@",indentationString,entryString);
	}
}

- (void)decreaseIndentationLevel
{
	indentationLevel = indentationLevel > 1 ? indentationLevel - 1 : 0;
}

- (void)increaseIndentationLevel
{
	indentationLevel = indentationLevel + 1;
}

@end
