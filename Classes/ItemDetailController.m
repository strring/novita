/*
 ItemDetailController.m
 Novita
 
 Created by Brett Gneiting on 1/1/09.
 
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

#import "ItemDetailController.h"
#import "CustomItemCell.h"
#import "ItemDetailCell.h"
#import "ItemDetailSentenceCell.h"
#import <AVFoundation/AVFoundation.h>


@implementation ItemDetailController

@synthesize itemDetailDictionary,receivedData,detailTable;

#pragma mark -
#pragma mark Custom Methods
-(void)popView {
	[self.navigationController popViewControllerAnimated:YES];
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
	
	[detailTable reloadData];
}

#pragma mark -
#pragma mark Default Methods
- (void)viewDidLoad {
	//set back button item
	//!!! This is incorrect, we want a real back button but with a custom title
	//no time to fix now. m(_ _)m
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(popView)];
	self.navigationItem.leftBarButtonItem = backButton;
	
	[backButton release];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[itemDetailDictionary release];
	[receivedData release];
	[detailTable release];
    [super dealloc];
}


#pragma mark -
#pragma mark Table View Data Source Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger section = [indexPath section];
	NSInteger row = [indexPath row];
	
	if(section == 0) {
		static NSString *ItemDetailCellIndentifier = @"ItemDetailCellIdentifier";
		
		ItemDetailCell *cell = (ItemDetailCell *)[tableView dequeueReusableCellWithIdentifier:ItemDetailCellIndentifier];

		if(cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ItemDetailCell" owner:self options:nil];
			
			//We are loading our custom nib for our cell, the array is the array of items in the nib file. First Responder is not included so index 1 of the nib is the custom cell we setup.
			cell = [nib objectAtIndex:0];
		}
		
		if([[itemDetailDictionary valueForKey:@"responses"] count] == 1) {
			cell.kanjiLabel.text = [[itemDetailDictionary valueForKey:@"cue"] valueForKey:@"text"];
		} else {
			cell.kanjiLabel.text = [[[itemDetailDictionary valueForKey:@"responses"] objectAtIndex:1] valueForKey:@"text"];
		}
		
		cell.kanaLabel.text = [[itemDetailDictionary valueForKey:@"cue"] valueForKey:@"text"];
		//responses is an array so we need to get the value for the responses array in the dictionary key, then choose the index of the array and return the correct dictionary key
		cell.meaningLabel.text = [[[itemDetailDictionary valueForKey:@"responses"] objectAtIndex:0] valueForKey:@"text"];
		
		return cell;
	} else {
		static NSString *ItemDetailSentenceCellIdentifier = @"ItemDetailSentenceCellIdentifier";
		
		ItemDetailSentenceCell *cell = (ItemDetailSentenceCell *)[tableView dequeueReusableCellWithIdentifier:ItemDetailSentenceCellIdentifier];
		if(cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ItemDetailSentenceCell" owner:self options:nil];
			
			//We are loading our custom nib for our cell, the array is the array of items in the nib file. First Responder is not included so index 1 of the nib is the custom cell we setup.
			cell = [nib objectAtIndex:0];
		}
		
		//NSLog(@"%@",[[itemDetailDictionary valueForKey:@"sentences"] objectAtIndex:row]);
		
		NSMutableString *mutableSentence = [[[itemDetailDictionary valueForKey:@"sentences"] objectAtIndex:row] valueForKey:@"text"];
		mutableSentence = (NSMutableString *)[mutableSentence stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
		mutableSentence = (NSMutableString *)[mutableSentence stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
		
		cell.sentence.text = mutableSentence; 
		
		NSMutableString *mutableHrktSentence = [[[[itemDetailDictionary valueForKey:@"sentences"] objectAtIndex:row] valueForKey:@"transliterations"] valueForKey:@"Hrkt"];
		mutableHrktSentence = (NSMutableString *)[mutableHrktSentence stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
		mutableHrktSentence = (NSMutableString *)[mutableHrktSentence stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
		
		cell.kanaSentence.text = mutableHrktSentence;

		cell.meaningSentence.text = [[[[[itemDetailDictionary valueForKey:@"sentences"] objectAtIndex:row] valueForKey:@"translations"] objectAtIndex:0] valueForKey:@"text"];
		
		
		//check if there is a sound file for this row, if there is display a graphic so the user knows to tap it
		if([[itemDetailDictionary valueForKey:@"sentences"] count] < 1) {
			return nil;
		}
		
		
		if([[[[itemDetailDictionary valueForKey:@"sentences"] objectAtIndex:row] valueForKey:@"sound"] class] != [NSNull class]) {
			
			//check if the sound file is local, if it is show the blue icon
			NSString *selectedWord = [[[itemDetailDictionary valueForKey:@"sentences"] objectAtIndex:row] objectForKey:@"sound"];
			
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
		
		
		return cell;
	}
	
	return nil;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	//!!!
	//we are hard coding the number of sections for now 
	// 1.item details (kanji, kana, meaning)
	// 2.Sentence row
	return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//we are hard coding one row per section for now
	if(section == 0) {
		return 1;	
	} else {
		//NSLog(@"Sentence Count: %d",[[itemDetailDictionary valueForKey:@"sentences"] count]);
		return [[itemDetailDictionary valueForKey:@"sentences"] count];
	}
}


#pragma mark -
#pragma mark Table View Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if([indexPath section] == 0) {
		return 90;	
	} else {
		return 119;
	}
	
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if([indexPath section] == 1) {
		return indexPath;
	} else {
		return nil;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
	
	NSString *selectedWord = [[[self.itemDetailDictionary valueForKey:@"sentences"] objectAtIndex:row] 
							  objectForKey:@"sound"];
	
	if([selectedWord class] != [NSNull class]) {	
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

@end
