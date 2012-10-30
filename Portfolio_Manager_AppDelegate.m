//
//  Portfolio_Manager_AppDelegate.m
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/03/09.
//  Copyright Hans Anderson 2009 . All rights reserved.
//

#import "Portfolio_Manager_AppDelegate.h"
#import "Portfolio.h"
#import "Security.h"
#import "Logger.h"

@implementation Portfolio_Manager_AppDelegate

@synthesize mainWindow;
@synthesize marketDataArray;
@synthesize marketReturnMean;
@synthesize marketReturnVariance;
@synthesize riskFreeReturn;

@synthesize persistentStoreCoordinator;
@synthesize managedObjectModel;
@synthesize managedObjectContext;

@synthesize sharedLogger;

- (id)init
{
	self = [super init];
    if( self != nil ) {
		sharedLogger = [[Logger alloc] init];

#ifdef _DEBUG
		[sharedLogger setEnabled:YES];
#endif
		
    }
	
    return self;
}

/**
    Returns the support folder for the application, used to store the Core Data
    store file.  This code uses a folder named "Portfolio_Manager" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Portfolio_Manager"];
}

/**
 Creates, retains, and returns the managed object model for the application 
 by merging all of the models found in the application bundle.
 */

- (NSManagedObjectModel *)managedObjectModel {
    if(managedObjectModel != nil) {
        return managedObjectModel;
    }
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"new managedObjectModel"]];
	
	[self willChangeValueForKey:@"managedObjectModel"];
	
	/*managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:
																									[[NSBundle bundleForClass:[self class]] pathForResource:@"PortfolioDataModel 4c" ofType:@"mom"]
																			  ]
						  ];*/
	
    //managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL URLWithString:[[NSBundle bundleForClass:[self class]] pathForResource:@"PortfolioDataModel 4c" ofType:@"mom"]]];
	managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
	
	[self didChangeValueForKey:@"managedObjectModel"];
	
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.  This 
 implementation will create and return a coordinator, having added the 
 store for the application to it.  (The folder for the store is created, 
 if necessary.)
 */

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if(persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"new persistentStoreCoordinator"]];
	
	[self willChangeValueForKey:@"persistentStoreCoordinator"];
	
    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSError *error;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent:@"Portfolio_Manager.xml"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	NSMutableDictionary *persistentStoreOptions = [[NSMutableDictionary alloc] init];
	[persistentStoreOptions setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
	[persistentStoreOptions setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
	
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:persistentStoreOptions error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    } 
	
	[self didChangeValueForKey:@"persistentStoreCoordinator"];
	
    return persistentStoreCoordinator;
}


/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.) 
 */

- (NSManagedObjectContext *)managedObjectContext {
    if(managedObjectContext != nil) {
        return managedObjectContext;
    }
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"new managedObjectContext"]];
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	
	[self willChangeValueForKey:@"managedObjectContext"];
	
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
	
	[self didChangeValueForKey:@"managedObjectContext"];
    
    return managedObjectContext;
}


/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
	(void)window;
    return [[self managedObjectContext] undoManager];
}

/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {
	(void)sender;
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	(void)sender;
	
	[mainWindow close];
	
	[loadingWindow center];
	[loadingProgressIndicator setIndeterminate:YES];
	[loadingProgressIndicator setUsesThreadedAnimation:YES];
	[loadingDetailsTextField setObjectValue:@"Saving and quitting…"];
	[loadingProgressIndicator startAnimation:self];
	[loadingWindow makeKeyAndOrderFront:self];
	[loadingWindow display];
	[loadingWindow update];
	
    NSError *error;
    NSInteger reply = NSTerminateNow;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext commitEditing]) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
				
                // This error handling simply presents error information in a panel with an 
                // "Ok" button, which does not include any attempt at error recovery (meaning, 
                // attempting to fix the error.)  As a result, this implementation will 
                // present the information to the user and then follow up with a panel asking 
                // if the user wishes to "Quit Anyway", without saving the changes.

                // Typically, this process should be altered to include application-specific 
                // recovery steps.  

                BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
                if (errorResult == YES) {
                    reply = NSTerminateCancel;
                } 

                else {
					
                    NSInteger alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
                    if (alertReturn == NSAlertAlternateReturn) {
                        reply = NSTerminateCancel;	
                    }
                }
            }
        } 
        
        else {
            reply = NSTerminateCancel;
        }
    }
    
    return reply;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	(void)aNotification;
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"applicationDidFinishLaunching"]];
	
	[loadingWindow center];
	[loadingProgressIndicator setIndeterminate:YES];
	[loadingProgressIndicator setUsesThreadedAnimation:YES];
	[loadingWindow makeKeyAndOrderFront:self];
	[loadingDetailsTextField setObjectValue:@""];
	[loadingProgressIndicator startAnimation:self];
	[loadingWindow display];
	[loadingWindow update];
	
	[loadingDetailsTextField setObjectValue:@"Loading saved data…"];
	[loadingWindow display];
	[loadingWindow update];
	
	//[self managedObjectModel];
	//[self persistentStoreCoordinator];
	//[self managedObjectContext];
	
	/*[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"willChangeValueForKey:managedObjectModel");
	[self willChangeValueForKey:@"managedObjectModel"];
	managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
	[self didChangeValueForKey:@"managedObjectModel"];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"didChangeValueForKey:managedObjectModel");
	
	NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSError *error;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
		[fileManager createDirectoryAtPath:applicationSupportFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
	
    url = [NSURL fileURLWithPath:[applicationSupportFolder stringByAppendingPathComponent: @"Portfolio_Manager.xml"]];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"willChangeValueForKey:persistentStoreCoordinator");
    [self willChangeValueForKey:@"persistentStoreCoordinator"];
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    [self didChangeValueForKey:@"persistentStoreCoordinator"];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"didChangeValueForKey:persistentStoreCoordinator");
	
	NSMutableDictionary *persistentStoreOptions = [[NSMutableDictionary alloc] init];
	
	[persistentStoreOptions setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"addPersistentStoreWithType");
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:persistentStoreOptions error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"willChangeValueForKey:managedObjectContext");
	[self willChangeValueForKey:@"managedObjectContext"];
	managedObjectContext = [[NSManagedObjectContext alloc] init];
	[managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
	[self didChangeValueForKey:@"managedObjectContext"];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"didChangeValueForKey:managedObjectContext");*/
	
	
	[loadingDetailsTextField setObjectValue:@"Loading Wilshire 5000 index data…"];
	[loadingWindow display];
	[loadingWindow update];
	
	NSError *wilshireDownloadError = nil;
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"Attempting to download Wilshire 5000 data..."]];
	
	NSString *postString = @"Accept=Accept&URL=/Indexes/calculator/csv/w500pidd.csv";
	NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSMutableURLRequest *URLrequest = [[[NSMutableURLRequest alloc] init] autorelease];
	[URLrequest setURL:[NSURL URLWithString:@"http://web.wilshire.com/Indexes/servlet/checkaccept"]];
	[URLrequest setHTTPMethod:@"POST"];
	[URLrequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[URLrequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[URLrequest setHTTPBody:postData];
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:URLrequest returningResponse:nil error:&wilshireDownloadError];
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"%@",responseString]];
	
	NSString *redirectDestination = [[[[responseString componentsSeparatedByString:@"<A HREF='"] objectAtIndex:1] componentsSeparatedByString:@"'>"] objectAtIndex:0];
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"Redirecting to %@",redirectDestination]];
	
	NSString *wilshire5000DataString = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http://web.wilshire.com",redirectDestination]] encoding:NSUTF8StringEncoding error:&wilshireDownloadError];
	NSString *wilshireSavePathString = [[self applicationSupportFolder] stringByAppendingPathComponent: @"Wilshire5000.csv"];
	
	if( wilshireDownloadError == nil ) {
		[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"Saving downloaded Wilshire 5000 data..."]];
		[wilshire5000DataString writeToFile:wilshireSavePathString atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}
	else {
		[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"%@",[wilshireDownloadError localizedDescription]]];
		[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"Attempting to load Wilshire 5000 data from disk..."]];
		wilshire5000DataString = [NSString stringWithContentsOfFile:wilshireSavePathString encoding:NSUTF8StringEncoding error:nil];
	}
	
	NSMutableArray *marketDataMutableArray_strings = [[wilshire5000DataString componentsSeparatedByString:@"\n"] mutableCopy];
	
	while( [[[marketDataMutableArray_strings objectAtIndex:0] substringToIndex:1] integerValue] == 0
		  || [[[[marketDataMutableArray_strings objectAtIndex:0] componentsSeparatedByString:@","] objectAtIndex:1] doubleValue] == 0.0 ) {
		if( [marketDataMutableArray_strings count] == 0 ) {
			[NSException raise:@"HAMarketDataNotAvailable" format:@"No data is available for the Wilshire 5000."];
		}
		[marketDataMutableArray_strings removeObjectAtIndex:0];
	}
	[marketDataMutableArray_strings removeLastObject];
	
	NSMutableArray *marketDataMutableArray_dictionaries = [NSMutableArray arrayWithCapacity:[marketDataMutableArray_strings count]];
	
	for( NSString *marketDataString_i in marketDataMutableArray_strings ) {
		NSMutableDictionary *marketDataDictionary_i = [NSMutableDictionary dictionary];
		
		NSArray *currentMarketDataStringComponents = [marketDataString_i componentsSeparatedByString:@","];
		
		NSString *dateString = [currentMarketDataStringComponents objectAtIndex:0];
		NSString *yearString = [dateString substringWithRange:NSMakeRange(0, 4)];
		NSString *monthString = [dateString substringWithRange:NSMakeRange(4, 2)];
		NSString *dayString = [dateString substringWithRange:NSMakeRange(6, 2)];
		
		[marketDataDictionary_i setObject:[NSString stringWithFormat:@"%@/%@/%@",yearString,monthString,dayString] forKey:@"dateString"];
		[marketDataDictionary_i setObject:[currentMarketDataStringComponents objectAtIndex:1] forKey:@"dailyReturn"];
		[marketDataDictionary_i setObject:[currentMarketDataStringComponents objectAtIndex:2] forKey:@"dailyCloseValue"];
		
		[marketDataMutableArray_dictionaries addObject:marketDataDictionary_i];
	}
	
	[marketDataMutableArray_dictionaries sortUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"dateString" ascending:NO]]];
	
	marketDataArray = [NSArray arrayWithArray:marketDataMutableArray_dictionaries];
	
	[loadingDetailsTextField setObjectValue:@"Calculating market statistics…"];
	[loadingWindow display];
	[loadingWindow update];
	
	marketReturnMean = [NSDecimalNumber zero];
	
	for( NSDictionary *marketDatum_i in marketDataArray ) {
		NSDecimalNumber *marketReturn_i = [NSDecimalNumber decimalNumberWithDecimal:[[marketDatum_i valueForKey:@"dailyReturn"] decimalValue]];
		marketReturnMean = [marketReturnMean decimalNumberByAdding:
									[marketReturn_i decimalNumberByDividingBy:
									 [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithUnsignedInteger:[marketDataArray count]] decimalValue]]
									 ]
									];
	}
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"marketReturnMean = %@", marketReturnMean]];
	
	marketReturnVariance = [NSDecimalNumber zero];
	
	for( NSDictionary *marketDatum_i in marketDataArray ) {
		NSDecimalNumber *marketReturn_i = [NSDecimalNumber decimalNumberWithString:[marketDatum_i valueForKey:@"dailyReturn"]];
		marketReturnVariance = [marketReturnVariance decimalNumberByAdding:
								 [[marketReturn_i decimalNumberBySubtracting:marketReturnMean]
								 decimalNumberByMultiplyingBy:
								 [marketReturn_i decimalNumberBySubtracting:marketReturnMean]]
								 ];
	}
	
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"marketReturnVariance = %@",marketReturnVariance]];
	
	NSFetchRequest *fetchRequestForSecurities = [[NSFetchRequest alloc] init];
	[fetchRequestForSecurities setEntity:[NSEntityDescription entityForName:@"Security" inManagedObjectContext:managedObjectContext]];
	
	NSMutableArray *securitiesInManagedObjectContext = [[managedObjectContext executeFetchRequest:fetchRequestForSecurities error:nil] mutableCopy];
	
	[securitiesInManagedObjectContext sortUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"symbol" ascending:YES]]];
	
	[loadingProgressIndicator setIndeterminate:NO];
	[loadingProgressIndicator setMinValue:0];
	[loadingProgressIndicator setMaxValue:(double)[securitiesInManagedObjectContext count]];
	[loadingProgressIndicator setDoubleValue:0];
	
	for( Security *security_i in securitiesInManagedObjectContext ) {
		[loadingDetailsTextField setStringValue:[NSString stringWithFormat:@"Updating %@…",[security_i valueForKey:@"symbol"]]];
		[loadingWindow display];
		[loadingWindow update];
		[security_i updateDataPoints:self];
		[loadingProgressIndicator incrementBy:0.5];
		[security_i updateMostRecentPrice:self];
		[loadingProgressIndicator incrementBy:0.3];
		[security_i recalculateStatistics];
		[loadingProgressIndicator incrementBy:0.2];
	}
	
	riskFreeReturn = [NSDecimalNumber decimalNumberWithString:@"0.01"];
	
	[loadingDetailsTextField setStringValue:@"Calculating portfolio statistics…"];
	[loadingWindow display];
	[loadingWindow update];
	[loadingProgressIndicator setIndeterminate:YES];
	[loadingProgressIndicator startAnimation:self];
	
	NSFetchRequest *fetchRequestForPortfolios = [[NSFetchRequest alloc] init];
	[fetchRequestForPortfolios setEntity:[NSEntityDescription entityForName:@"Portfolio" inManagedObjectContext:managedObjectContext]];
	
	NSArray *portfoliosInManagedObjectContext = [managedObjectContext executeFetchRequest:fetchRequestForPortfolios error:nil];
	
	for( Portfolio *portfolio_i in portfoliosInManagedObjectContext ) {
		[portfolio_i recalculateStatistics:self];
	}
	
	[loadingProgressIndicator stopAnimation:self];
	[loadingWindow close];
	
	[mainWindow center];
	[mainWindow makeKeyAndOrderFront:self];
	[[(Portfolio_Manager_AppDelegate *)[[NSApplication sharedApplication] delegate] sharedLogger] log:[NSString stringWithFormat:@"done loading"]];
}

/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void) dealloc {
    [managedObjectContext release], managedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [managedObjectModel release], managedObjectModel = nil;
    [super dealloc];
}


@end
