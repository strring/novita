/*
 SettingsViewController.m
 Novita
 
 Created by Brett Gneiting on 12/30/08.
 
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

#import "SettingsViewController.h"
#import "AboutViewController.h"
#import "UsernameCellView.h"

@implementation SettingsViewController

@synthesize table, tableArray;


#pragma mark -
#pragma mark IBAction Methods
- (IBAction)cancelInput {
	NSLog(@"cancelled username input");
	[self resignFirstResponder];
}


#pragma mark -
#pragma mark Default Methods
- (void)viewDidLoad {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSString *userName = [defaults valueForKey:@"username"];
	
	//create our settings table fields
	NSArray *userArray = [[NSArray alloc] initWithObjects:userName,nil];
	
	self.tableArray = userArray;
	
	[userArray release];
		
	//The navigation controller title
	self.title = @"Settings";
	
	//our reload button from the courses view controller was showing up for some reason
	//setting it nil manually here to get rid of it.
	self.navigationItem.rightBarButtonItem = nil;

    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[tableArray release];
	[table release];
    [super dealloc];
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = [indexPath section];
	
	return (section == 1) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return (section == 0) ? @"" : @"" ;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
	[selectedCell setSelected:YES animated:YES];
	
	return indexPath;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
	
	if([indexPath section] == 1) {
		AboutViewController *aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil];
		[self.navigationController pushViewController:aboutViewController animated:YES];
		
		//deselect the cell so its not hilighted if we come back to it via the navigation controller
		
		[selectedCell setSelected:NO animated:YES];
		
		[aboutViewController release];
	} else {
		[selectedCell setSelected:NO animated:YES];
	}
}


#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *BasicCellIdentifier = @"BasicCellIdentifier";
	static NSString *UsernameCellViewIdentifier = @"UsernameCellViewIdentifier";
	
	UITableViewCell *cell;
	
	NSUInteger section = [indexPath section];
	
	if(section == 1) {
		 cell = [tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier];
		
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:BasicCellIdentifier] autorelease];
		}
		
		cell.text = @"About Project Novita";
		
		return cell;
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:UsernameCellViewIdentifier];
		
		UsernameCellView *cell = (UsernameCellView *)[tableView dequeueReusableCellWithIdentifier:UsernameCellViewIdentifier];
		
		if(cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UsernameCell" owner:self options:nil];
			
			//We are loading our custom nib for our cell, the array is the array of items in the nib file. First Responder is not included so index 1 of the nib is the custom cell we setup.
			cell = [nib objectAtIndex:0];
		}
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		NSString *userName = [defaults valueForKey:@"username"];
		cell.usernameLabel.delegate = self;
		cell.usernameLabel.text = userName;
		
		return cell;
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//!!!: 
	//This is hardcoded because currently both sections happen to only have 1 row, be sure to change this in the future if it changes.
	return 1;
}

#pragma mark -
#pragma mark UITextField Delegate Methods
- (BOOL)textFieldShouldClear:(UITextField *)textField {
	NSLog(@"text field should clear");
	return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSLog(@"text field returned.");
	[textField resignFirstResponder];
	return YES;
}

@end
