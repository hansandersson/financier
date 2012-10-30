//
//  PanelController.h
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PanelController : NSObject {
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSPanel *securityRepertoirePanel;
	IBOutlet NSPanel *marketDetailsPanel;
}

- (IBAction)toggleSecurityRepertoireSheet:(id)sender;
- (IBAction)toggleMarketDetailsSheet:(id)sender;

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end
