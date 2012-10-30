//
//  Position.h
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/03/14.
//  Copyright 2009 Hans Anderson. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Portfolio;
@class Security;

@interface Position : NSObject {
	Security *security;
	Portfolio *portfolio;
	NSManagedObject *targetPosition;
	
	NSDecimalNumber *currentQuantity;
	NSDecimalNumber *currentAllocation;
	NSDecimalNumber *currentWeight;
	NSDecimalNumber *currentWeightPercentage;
	NSDecimalNumber *targetWeight;
	NSDecimalNumber *targetWeightPercentage;
	NSDecimalNumber *targetAllocation;
	NSDecimalNumber *targetQuantity;
	NSDecimalNumber *deviationWeight;
	NSDecimalNumber *deviationWeightPercentage;
	NSDecimalNumber *deviationAllocation;
	NSDecimalNumber *deviationQuantity;
}

@property (readwrite) Security *security;
@property (readwrite) Portfolio *portfolio;
@property (readwrite) NSManagedObject *targetPosition;

@property (readonly) NSDecimalNumber *currentQuantity;
@property (readonly) NSDecimalNumber *currentAllocation;
@property (readonly) NSDecimalNumber *currentWeight;
@property (readonly) NSDecimalNumber *currentWeightPercentage;
@property (readonly) NSDecimalNumber *targetWeight;
@property (readonly) NSDecimalNumber *targetWeightPercentage;
@property (readonly) NSDecimalNumber *targetAllocation;
@property (readonly) NSDecimalNumber *targetQuantity;
@property (readonly) NSDecimalNumber *deviationWeight;
@property (readonly) NSDecimalNumber *deviationWeightPercentage;
@property (readonly) NSDecimalNumber *deviationAllocation;
@property (readonly) NSDecimalNumber *deviationQuantity;

@property (readonly) NSString *securitySymbolAndName;
@property (readonly) NSString *securitySymbol;

@property (readonly) NSString *suggestion;

+ (Position *)positionFromSecurity:(Security *)aSecurity forPortfolio:(Portfolio*)aPortfolio;

@end


