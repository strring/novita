/*
 CoursesViewController.m
 Novita
 
 Created by Brett Gneiting on 12/31/08.
 
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

#import "CoursesViewController.h"
#import "ItemViewController.h"
#import <JSON/JSON.h>
#import "CoursesCellController.h"

@implementation CoursesViewController

@synthesize coursesTable,jsonData;

#pragma mark -
#pragma mark Custom Methods
- (BOOL)writeToFile:(NSData *)data fileName:(NSString *)fileName extension:(NSString *)extension {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectoryPath = [paths objectAtIndex:0];
	
	NSString *localResource = [documentsDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@.%@",fileName,extension]];	
	
	return ([data writeToFile:localResource atomically:YES]);	
}


-(void)getJSONFeed {
	//show the activity indicator while we are fetching info from the internet
	[UIApplication sharedApplication].isNetworkActivityIndicatorVisible = YES;
	
	//use the user defaults singleton to get our stored user name
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	//create the path to the correct user on iKnow
	NSString *coursesPath = [NSString stringWithFormat:@"http://api.iknow.co.jp/users/%@/lists.json",[defaults objectForKey:@"username"]];
	
	NSURL *coursesURL = [NSURL URLWithString:coursesPath];
	
	//load the data we received from the iKnow API into a string.
	NSString *coursesData = [[NSString alloc] initWithContentsOfURL:coursesURL];
	//NSLog(coursesData);
	
	// converting the json data into an array
	self.jsonData = [coursesData JSONValue]; 
	
	
	//save the raw JSON data as NSData
	NSData *courseData = [NSData dataWithContentsOfURL:coursesURL];
	
	//write the data to a file 
	BOOL didWriteDataToFile = [self writeToFile:courseData fileName:[defaults objectForKey:@"username"] extension:@"txt"];
	
	//verify we were able to write the file to the system
	if(didWriteDataToFile) {
		NSLog(@"wrote course data to file!");
	}
	
	// releasing the vars now
	[coursesData release];
	
	[UIApplication sharedApplication].isNetworkActivityIndicatorVisible = NO;
}


- (void)reloadUserlist {
	[self getJSONFeed];
	[coursesTable reloadData];
}


- (NSString *)saveCourseImage:(NSString *)imageURL {
	//get our documents path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectoryPath = [paths objectAtIndex:0];
	
	//break the http path into an array split by the "/"
	NSArray *imagePathArray = [imageURL componentsSeparatedByString:@"/"];
	
	//return the last Object, which will be the name of the mp3 file
	NSString *imageName = [imagePathArray lastObject];
	
	NSString *localResource = [documentsDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@",imageName]];	
	
	//write the image to our local FS
	NSMutableData *data = [[NSMutableData alloc] initWithContentsOfURL:[NSURL URLWithString:imageURL]];
	[data writeToFile:localResource atomically:YES];
	
	//return the image name
	return localResource;	
	
	//release the data we allocated
	[data release];
}


#pragma mark -
#pragma mark Default Methods 
- (void)viewDidLoad {
	//use the user defaults singleton to get our stored user name
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *currentUser = [defaults objectForKey:@"username"];
	
	//check for the existance of the local data for the users course list
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectoryPath = [paths objectAtIndex:0];
	
	NSString *localResource = [NSString stringWithFormat:@"%@/%@.txt",documentsDirectoryPath,currentUser];	
	
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL fileExists = [fm fileExistsAtPath:localResource];
	
	if(!fileExists) {
		[self getJSONFeed];
	} else {
		//file exists load the data from the file on the system and parse it with the jsonData method
		NSString *courseList = [[NSString alloc] initWithContentsOfFile:localResource];
		
		self.jsonData = [courseList JSONValue]; 
	}
	
	//set right bar button item
	UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadUserlist)];
	self.navigationItem.rightBarButtonItem = reloadButton;
		
	[reloadButton release];
	
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
	//load the user defaults singleton
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	//watch for the reloadList default, if its set to yes then reload the user list
	if([defaults boolForKey:@"reloadList"]) {
		[self reloadUserlist];
		[defaults setBool:NO forKey:@"reloadList"];
	}
	
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data

}


- (void)dealloc {
	[jsonData release];
	[coursesTable release];
    [super dealloc];
}


#pragma mark -
#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 78;
}


- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	
	ItemViewController *itemStudyView = [[ItemViewController alloc] initWithNibName:@"StudyItemsView" bundle:nil];
	
	itemStudyView.currentList = [[self.jsonData objectAtIndex:row] objectForKey:@"id"];
	itemStudyView.currentListCount = 100; //(NSInteger)[[self.jsonData objectAtIndex:row] objectForKey:@"item_count"];
	
	//NSLog(@"%@",(NSInteger)[[self.jsonData objectAtIndex:row] objectForKey:@"item_count"]);
	
	[self.navigationController pushViewController:itemStudyView animated:YES];
	itemStudyView.title = [[self.jsonData objectAtIndex:row] objectForKey:@"title"];
	
	[itemStudyView release];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[UIApplication sharedApplication].isNetworkActivityIndicatorVisible = NO;
}


#pragma mark -
#pragma mark Table Data Source Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
	
	static NSString *CoursesTableIdentifier = @"CoursesTableIdentifier";
	
	CoursesCellController *cell = (CoursesCellController *)[tableView dequeueReusableCellWithIdentifier:CoursesTableIdentifier];
	
	if(cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CoursesCell" owner:self options:nil];
		
		//We are loading our custom nib for our cell, the array is the array of items in the nib file. First Responder is not included so index 1 of the nib is the custom cell we setup.
		cell = [nib objectAtIndex:0];
	}
	
	NSString *courseImage = [[self.jsonData objectAtIndex:row] objectForKey:@"square_icon"];
	
	if([courseImage class] != [NSNull class]) {
		//there is an image for this course, if we have a local version use that, otherwise download it
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
		NSString *documentsDirectoryPath = [paths objectAtIndex:0];
		
		//break the http path into an array split by the "/"
		NSArray *imagePathArray = [courseImage componentsSeparatedByString:@"/"];
		
		//return the last Object, which will be the name of the mp3 file
		NSString *imageName = [imagePathArray lastObject];
		
		
		NSString *localResource = [NSString stringWithFormat:@"%@/%@",documentsDirectoryPath,imageName];	
		
		
		NSFileManager *fm = [NSFileManager defaultManager];
		BOOL fileExists = [fm fileExistsAtPath:localResource];
		
		if(!fileExists) {
			UIImage *image = [[UIImage alloc] initWithContentsOfFile:
							  [self saveCourseImage:
							   [[self.jsonData objectAtIndex:row] objectForKey:@"square_icon"]
							   ]
							  ];
			cell.image = image;
		} else {
			UIImage *image = [[UIImage alloc] initWithContentsOfFile:localResource];
			cell.image = image;
			[image release];
		}
		
	} else {
		//no image available, use a placeholder
		cell.image = [UIImage imageNamed:@"course_placeholder.png"];	
	}
	
	
	cell.titleLabel.text = [[self.jsonData objectAtIndex:row] objectForKey:@"title"];
	
	return cell;
	
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.jsonData count];
}


- (NSInteger)numberOFSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"";
}

@end
