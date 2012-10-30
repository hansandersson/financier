//
//  Suggestion.h
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/04/13.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Position;
@class Portfolio;

@interface Suggestion : NSObject {
	Position *relatedPosition;
}

+ (Suggestion*)suggestionForPosition:(Position*)aPosition;

@property (retain) Position *relatedPosition;

@property (readonly) NSString *securitySymbol;
@property (readonly) NSString *securityName;
@property (readonly) NSNumber *roundQuantity;
@property (readonly) NSNumber *quantity;
@property (readonly) Portfolio *portfolio;
@property (readonly) NSString *transactionType;

@end
