//
//  Logger.h
//  Portfolio Manager
//
//  Created by Hans Anderson on 10/01/04.
//  Copyright 2010 ultraMentem Tech Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Logger : NSObject {
	NSUInteger indentationLevel;
	BOOL enabled;
}

@property (readwrite) BOOL enabled;

- (void)log:(NSString *)entryString;
- (void)decreaseIndentationLevel;
- (void)increaseIndentationLevel;

@end
