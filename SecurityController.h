//
//  SecurityController.h
//  Portfolio Manager
//
//  Created by Hans Anderson on 09/03/11.
//  Copyright 2009 Hans Anderson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SecurityController : NSObject {
	IBOutlet NSWindow *myWindow;
	IBOutlet NSPanel *newSecuritySheet;
	IBOutlet NSTextField *securitySymbolToAddTextField;
	IBOutlet NSTextField *securityNameToAddTextField;
	IBOutlet NSProgressIndicator *securityVerificationProgressIndicator;
	IBOutlet NSButton *verifyButton;
	IBOutlet NSButton *addButton;
	
	IBOutlet NSArrayController *securityArrayController;
}

- (IBAction)updateAllSecurities:(id)sender;

- (IBAction)openNewSecuritySheet:(id)sender;
- (IBAction)addSecurityFromSheet:(id)sender;
- (void)resetNewSecuritySheet;
- (IBAction)closeNewSecuritySheet:(id)sender;

@end
