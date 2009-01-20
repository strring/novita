/*
 ItemViewController.m
 Novita
 
 Created by Brett Gneiting on 12/27/08.
 
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

#import "ItemViewController.h"
#import "CustomItemCell.h"
#import "ItemDetailController.h"
#import <JSON/JSON.h>
#import <AVFoundation/AVFoundation.h>

@implementation ItemViewController

@synthesize currentList, currentListCount, jsonData, itemsTable, receivedData;


#pragma mark -
#pragma mark Custom Methods
- (BOOL)writeToFile:(NSData *)data fileName:(NSString *)fileName extension:(NSString *)extension {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectoryPath = [paths objectAtIndex:0];
	
	NSString *localResource = [documentsDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@.%@",fileName,extension]];	
	
	return ([data writeToFile:localResource atomically:YES]);	
}


- (void)getJSONFeed {
	//Show activity indicator
	[UIApplication sharedApplication].isNetworkActivityIndicatorVisible = YES;
	
	//create the path to the correct item list on iKnow
	NSString *itemPath = [NSString stringWithFormat:@"http://api.iknow.co.jp/lists/%@/items.json?per_page=%d&include_sentences=true",self.currentList,currentListCount];
	
	NSURL *itemURL = [NSURL URLWithString:itemPath];
	
	//save the raw JSON data as NSData
	NSData *itemData = [[NSData alloc] initWithContentsOfURL:itemURL];
	NSString *itemString = [[NSString alloc] initWithContentsOfURL:itemURL];
	// converting the json data into an array
	self.jsonData = [itemString JSONValue]; 
	
	[itemString release];
	
	//write the data to a file 
	BOOL didWriteDataToFile = [self writeToFile:itemData fileName:self.currentList extension:@"txt"];
	
	//verify we were able to write the file to the system
	if(didWriteDataToFile) {
		NSLog(@"Wrote item data to file!");
	}
	
	[itemData release];
	
	[UIApplication sharedApplication].isNetworkActivityIndicatorVisible = NO;
}


-(void)popView {
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Default Methods
- (void)viewDidLoad {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectoryPath = [paths objectAtIndex:0];
	
	NSString *localResource = [NSString stringWithFormat:@"%@/%@.txt",documentsDirectoryPath,self.currentList];	
	
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL fileExists = [fm fileExistsAtPath:localResource];
	
	if(!fileExists) {
		[self getJSONFeed];
	} else {
		//file exists load the data from the file on the system and parse it with the jsonData method
		NSString *courseList = [[NSString alloc] initWithContentsOfFile:localResource];
		
		self.jsonData = [courseList JSONValue]; 
	}
	
	//set back button item
	//!!! This is incorrect, we want a real back button but with a custom title
	//no time to fix now. m(_ _)m
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(popView)];
	self.navigationItem.leftBarButtonItem = backButton;
	
	[backButton release];	
	
	[super viewDidLoad];
}


- (void)dealloc {
	[jsonData release];
	[currentList release];
	[receivedData release];
    [super dealloc];
}


#pragma mark -
#pragma mark Save Sound Data
- (void) saveDataFromURL:(NSURL *)url asLocalResource:(NSString *)localResource {
	//show the activity indicator while we are fetching info from the internet
	[UIApplication sharedApplication].isNetworkActivityIndicatorVisible = YES;
	
	NSMutableData *data = [[NSMutableData alloc] initWithContentsOfURL:url];
	self.receivedData = data;
	[self.receivedData writeToFile:localResource atomically:YES];
	[data release];
	
	[UIApplication sharedApplication].isNetworkActivityIndicatorVisible = NO;
	
	[itemsTable reloadData];
}


#pragma mark -
#pragma mark UITableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSUInteger row = [indexPath row];
	
	NSString *selectedWord = [[[self.jsonData objectAtIndex:row] objectForKey:@"cue"] objectForKey:@"sound"];

	if([selectedWord length] > 0) {	
		//break the http path into an array split by the "/"
		NSArray *soundPathArray = [selectedWord componentsSeparatedByString:@"/"];
		
		//return the last Object, which will be the name of the mp3 file
		NSString *soundFile = [soundPathArray lastObject];
		
		//does the sound file already exist? If not then save it 
		//locally otherwise don't resave it
		NSFileManager *fm = [NSFileManager defaultManager];
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
		NSString *documentsDirectoryPath = [paths objectAtIndex:0];
		
		NSString *localSoundFilePath = [documentsDirectoryPath stringByAppendingPathComponent:soundFile];
		
		BOOL fileExists = [fm fileExistsAtPath:localSoundFilePath];
		
		if(!fileExists) {
			NSURL *remoteSoundPath = [NSURL URLWithString:selectedWord];
			[self saveDataFromURL:remoteSoundPath asLocalResource:localSoundFilePath];
		} else {
			NSMutableData *data = [[NSMutableData alloc] initWithContentsOfFile:localSoundFilePath];
			
			self.receivedData = data;
			[data release];
		}
		NSError *error;
	
		AVAudioPlayer *playPronunciation = [[AVAudioPlayer alloc] initWithData:self.receivedData error:&error];
		
		[playPronunciation play];
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
	}
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
	
	ItemDetailController *detailController = [[ItemDetailController alloc] initWithNibName:@"ItemDetailView" bundle:nil];
	NSDictionary *currentItem = [self.jsonData objectAtIndex:row];
	
	if([[currentItem valueForKey:@"responses"] count] == 1) {
		//if this item does not have a kanji item display the kana entry n the navigation title bar
		detailController.title = [[currentItem valueForKey:@"cue"] valueForKey:@"text"];
	} else {
		//if this item has a kanji item display that as the navigation bar title
		detailController.title = [[[currentItem valueForKey:@"responses"] objectAtIndex:1] valueForKey:@"text"];
	}
	
	detailController.itemDetailDictionary = currentItem;
	
	[self.navigationController pushViewController:detailController animated:YES];

	[detailController release];
}


- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *currentItem = [self.jsonData objectAtIndex:[indexPath row]];
	NSString *itemSentence = [currentItem valueForKey:@"sentences"];
	
	NSNull *nullClass = [[NSNull alloc] init];
	
	return ([itemSentence class] == [nullClass class]) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDetailDisclosureButton;
	[nullClass release];
}


#pragma mark -
#pragma mark UITableView DataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger row = [indexPath row];
	static NSString *ItemCellIndentifier = @"ItemCellIdentifier";
	
	CustomItemCell *cell = (CustomItemCell *)[tableView dequeueReusableCellWithIdentifier:ItemCellIndentifier];
	
	if(cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomItemCell" owner:self options:nil];
		
		//We are loading our custom nib for our cell, the array is the array of items in the nib file. First Responder is not included so index 1 of the nib is the custom cell we setup.
		cell = [nib objectAtIndex:0];
	}
	NSDictionary *currentItem = [self.jsonData objectAtIndex:row];
	
	if([[[currentItem valueForKey:@"cue"] valueForKey:@"sound"]
 length] > 0) {
		
		//check if the sound file is local, if it is show the blue icon
		NSString *selectedWord = [[[self.jsonData objectAtIndex:row] objectForKey:@"cue"] objectForKey:@"sound"];
		
		//break the http path into an array split by the "/"
		NSArray *soundPathArray = [selectedWord componentsSeparatedByString:@"/"];
		
		//return the last Object, which will be the name of the mp3 file
		NSString *soundFile = [soundPathArray lastObject];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
		NSString *documentsDirectoryPath = [paths objectAtIndex:0];
		
		NSString *localResource = [NSString stringWithFormat:@"%@/%@",documentsDirectoryPath,soundFile];	
		
		NSFileManager *fm = [NSFileManager defaultManager];
		BOOL fileExists = [fm fileExistsAtPath:localResource];
		
		if(fileExists) {
			UIImage *soundImage = [UIImage imageNamed:@"speaker_icon.png"];
			cell.image = soundImage;
		} else {
			UIImage *soundImage = [UIImage imageNamed:@"speaker_icon_not_downloaded.png"];
			cell.image = soundImage;
		}
		
	}
	cell.kanaLabel.text = [[currentItem valueForKey:@"cue"] valueForKey:@"text"];
	
	if([[currentItem valueForKey:@"responses"] count] == 1) {
		cell.kanjiLabel.text = [[currentItem valueForKey:@"cue"] valueForKey:@"text"];
	} else {
		cell.kanjiLabel.text = [[[currentItem valueForKey:@"responses"] objectAtIndex:1] valueForKey:@"text"];
	}
	
	
	//responses is an array so we need to get the value for the responses array in the dictionary key, then choose the index of the array and return the correct dictionary key
	cell.meaningLabel.text = [[[currentItem valueForKey:@"responses"] objectAtIndex:0] valueForKey:@"text"];
	return cell;
	
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.jsonData count];
}


#pragma mark -
#pragma mark AVAudioPlayer Delegate Methods
- (void)audioPlayerDidFinishPlaying: (AVAudioPlayer*)player successfully: (BOOL)flag
{
	NSLog(@"Played Sound File");
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
	NSLog(@"AVAudioPlayer Error: %@",error);
}


- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
	NSLog(@"player interrupted");
}


- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
	NSLog(@"interruption ended");
}

@end
