/*
 NovitaAppDelegate.m
 Novita

 Created by Brett Gneiting on 12/21/08.

 Copyright (c) 2009 Brett Gneiting (http://blog.bakarakuda.com)
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
*/

#import "NovitaAppDelegate.h"

@implementation NovitaAppDelegate

@synthesize window;
@synthesize tabBarController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	//if there is no user set, push the user to the settings tab and notify them to input their username
	if([defaults objectForKey:@"username"] == nil || [[defaults objectForKey:@"username"] length] < 1) {
		tabBarController.selectedIndex = 1;
		
		UIAlertView *noUserAlert = [[UIAlertView alloc] initWithTitle:@"Username Setup" message:@"Please enter your iKnow username to access your information." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[noUserAlert show];
		[noUserAlert release];
	}
	
	//Load the user defaults and check that a username is set
	[window addSubview:tabBarController.view];
	
	// Display the window
	[window makeKeyAndVisible];
}


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end
