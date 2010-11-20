
#import "PinentryController.h"
#import "GPGDefaults.h"

@interface PinentryController (Private)
- (void)updateButtonSizes;
@end


@implementation PinentryController : NSWindowController
@synthesize gpgDefaults;
@synthesize descriptionText;
@synthesize promptText;
@synthesize errorText;
@synthesize passphrase;
@synthesize grab;
@synthesize confirmMode;
@synthesize oneButton;
@synthesize saveInKeychain;
@synthesize canUseKeychain;

PinentryController *_sharedInstance = nil;

- (id)init {
	self = [super init];
	
	gpgDefaults = [[GPGDefaults gpgDefaults] retain];
	
	descriptionText = nil;
	promptText = nil;
	errorText = nil;
	passphrase = nil;
	okButtonText = nil;
	cancelButtonText = nil;
	
	confirmMode = NO;
	oneButton = NO;
	okPressed = NO;
	canUseKeychain = NO;
	
	saveInKeychain = [gpgDefaults boolForKey:@"GPGUsesKeychain"];

	[NSApplication sharedApplication];
	[NSBundle loadNibNamed:@"Pinentry" owner:self];
	
	
	return self;	
}
- (NSInteger)runModal {
	[window center];
	 
	if (grab) {
		[NSApp activateIgnoringOtherApps:YES];
		[window makeKeyAndOrderFront:self];
	} else {
		[NSApp requestUserAttention: NSCriticalRequest];

	}
	
	[NSApp runModalForWindow:window];
	return okPressed;
}



- (IBAction)okClick:(NSButton *)sender {
	okPressed = YES;
	[window close];
}
- (IBAction)cancelClick:(NSButton *)sender {
	[window close];
}



// Button properties

- (void)setOkButtonText:(NSString *)value {
	if (value != okButtonText) {
		[okButtonText release];
		okButtonText = [value retain];
		[self updateButtonSizes];
	}
}
- (NSString *)okButtonText {
	return okButtonText;
}
- (void)setCancelButtonText:(NSString *)value {
	if (value != cancelButtonText) {
		[cancelButtonText release];
		cancelButtonText = [value retain];
		[self updateButtonSizes];
	}	
}
- (NSString *)cancelButtonText {
	return cancelButtonText;
}

- (void)updateButtonSizes {
	float windowWidth = [window contentRectForFrameRect:[window frame]].size.width;
	NSDictionary *fontAttributes = [NSDictionary dictionaryWithObject:[NSFont messageFontOfSize:0] forKey:NSFontAttributeName];
	float okButtonWidth, cancelButtonWidth;
	
	if (okButtonText) {
		okButtonWidth = [okButtonText sizeWithAttributes:fontAttributes].width + 40;
	} else {
		okButtonWidth = 110;
	}
	
	if (cancelButtonText) {
		cancelButtonWidth = [cancelButtonText sizeWithAttributes:fontAttributes].width + 40;
	} else {
		cancelButtonWidth = 110;
	}
	
	
	if (okButtonWidth + cancelButtonWidth > 420) {
		float sum = okButtonWidth + cancelButtonWidth - 420;
		float ratio = okButtonWidth / cancelButtonWidth;
		okButtonWidth -= sum * ratio / 2;
		cancelButtonWidth -= sum * (1 / ratio) / 2;
	}
	
	
	NSRect okButtonRect = [okButton frame];
	NSRect cancelButtonRect = [cancelButton frame];
	
	okButtonRect.size.width = okButtonWidth;
	okButtonRect.origin.x = windowWidth - okButtonWidth - 14;
	
	cancelButtonRect.size.width = cancelButtonWidth;
	cancelButtonRect.origin.x = windowWidth - cancelButtonWidth - okButtonWidth - 14;
	
	
	[okButton setFrame:okButtonRect];
	[cancelButton setFrame:cancelButtonRect];
	[okButton setNeedsDisplay:YES];
	[cancelButton setNeedsDisplay:YES];
}


// Window Controller

- (void)windowWillClose:(NSNotification *)notification {
	[NSApp stopModal];
}
- (void)setWindow:(NSWindow *)newWindow {
	window = newWindow;
	window.level = 30;
}
- (NSWindow *)window {
	return window;
}

@end
