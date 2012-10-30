//
//  Portfolio_Manager_AppDelegate.h
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/03/09.
//  Copyright Hans Anderson 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Logger;

@interface Portfolio_Manager_AppDelegate : NSObject 
{
    IBOutlet NSWindow *mainWindow;
	
	IBOutlet NSWindow *loadingWindow;
	IBOutlet NSProgressIndicator *loadingProgressIndicator;
	IBOutlet NSTextField *loadingDetailsTextField;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	NSArray *marketDataArray;
	
	NSDecimalNumber *marketReturnMean;
	NSDecimalNumber *marketReturnVariance;
	NSDecimalNumber *riskFreeReturn;
	
	Logger *sharedLogger;
}

@property (readonly) Logger *sharedLogger;

@property (readonly) NSWindow *mainWindow;

@property (readonly) NSArray *marketDataArray;
@property (readonly) NSDecimalNumber *marketReturnMean;
@property (readonly) NSDecimalNumber *marketReturnVariance;
@property (readonly) NSDecimalNumber *riskFreeReturn;

@property (readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly) NSManagedObjectModel *managedObjectModel;
@property (readonly) NSManagedObjectContext *managedObjectContext;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- (IBAction)saveAction:sender;

@end
