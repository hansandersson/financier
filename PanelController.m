//
//  PanelController.m
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PanelController.h"


@implementation PanelController

- (IBAction)toggleSecurityRepertoireSheet:(id)sender
{
	(void)sender;
	if( [marketDetailsPanel isVisible] ) {
		[[NSApplication sharedApplication] endSheet:marketDetailsPanel returnCode:NSCancelButton];
	}
	if( [securityRepertoirePanel isVisible] ) {
		[[NSApplication sharedApplication] endSheet:securityRepertoirePanel returnCode:NSCancelButton];
	}
	else {
		[[NSApplication sharedApplication] beginSheet:securityRepertoirePanel modalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL]; 	
	}
}

- (IBAction)toggleMarketDetailsSheet:(id)sender
{
	(void)sender;
	if( [securityRepertoirePanel isVisible] ) {
		[[NSApplication sharedApplication] endSheet:securityRepertoirePanel returnCode:NSCancelButton];
	}
	if( [marketDetailsPanel isVisible] ) {
		[[NSApplication sharedApplication] endSheet:marketDetailsPanel returnCode:NSCancelButton];
	}
	else {
		[[NSApplication sharedApplication] beginSheet:marketDetailsPanel modalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL]; 	
	}
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	(void)returnCode;
	(void)contextInfo;
	/*NSManagedObject *sheetObject = [newObjectController content]; 
	 if (returnCode == NSOKButton) { 
	 NSManagedObject *newObject = [[sourceArrayController newObject] autorelease]; 
	 [newObject setValuesForKeysWithDictionary:[sheetObject valuesForKeys:[[newObject class] copyKeys]]]; 
	 [sourceArrayController addObject:newObject]; 
	 } 
	 [newObjectController setContent:nil]; 
	 [[self managedObjectContext] reset];*/
	
	[sheet orderOut:self]; 
}

@end
