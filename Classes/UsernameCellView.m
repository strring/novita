/*
 UsernameCellView.m
 Novita
 
 Created by Brett Gneiting on 1/4/09.
 
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

#import "UsernameCellView.h"
#import <JSON/JSON.h>

@implementation UsernameCellView

@synthesize usernameLabel;

#pragma mark -
#pragma mark IBActions / Custom Methods
- (BOOL)checkIfUserExists:(NSString *)username {
	//!!!: Not Active!
	//currently there is no way to verify if the user is real or not via the API 2009/1/13 - Brett
	
	//load the user defaults singleton
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	//create the path to the correct user on iKnow
	NSString *usersPath = [NSString stringWithFormat:@"http://api.iknow.co.jp/users/%@.json",[defaults objectForKey:@"username"]];
	
	NSURL *userURL = [NSURL URLWithString:usersPath];
	
	//load the data we received from the iKnow API into a string.
	NSString *userData = [[NSString alloc] initWithContentsOfURL:userURL];
	
	NSLog(@"%@",userData);
	
	return YES;
	
}

- (IBAction)changeUsername:(id)sender {
	NSLog(@"changeUsername method was called");
	
	//the username was changed, lets connect to iKnow to verify the name is 
	//correct, if it is not we will present an alert
	//otherwise we will update our username and update the user list.
	//!!!: Not Active!
	//[self checkIfUserExists:newUsername];
	
	//load the user defaults singleton
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	//grab the new username from the text field
	NSString *newUsername = [sender text];
	
	//update our user defaults with the new name
	[defaults setValue:newUsername forKey:@"username"];
	
	//create a marker variable to update the users list when they go back to the study tab
	[defaults setBool:YES forKey:@"reloadList"];	
}

#pragma mark -
#pragma mark Default Methods
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
	
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
}


- (void)dealloc {
	[usernameLabel release];
    [super dealloc];
}

@end
