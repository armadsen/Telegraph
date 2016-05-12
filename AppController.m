//
//  AppController.m
//  Telegraph
//
//  Created by Andrew Madsen on 01/10/11.
//  Copyright 2011 Open Reel Software. All rights reserved.
//

#import "AppController.h"
#import "ORSMorseAudioSender.h"

@implementation AppController

@synthesize morseSender;

@synthesize text;

- (void)awakeFromNib;
{
	morseSender.delegate = self;
}

- (IBAction)send:(id)sender 
{
	[morseSender playMorseForString:self.textView.string];
}

- (void)removeCharacterFromBeginningOfTextField:(NSString *)charString;
{
	if (charString == nil || charString.length < 1) return;
	
	if (charString.length > 1) charString = [charString substringToIndex: 1];
	
	if ([[self.text substringToIndex: 1] caseInsensitiveCompare: charString] != NSOrderedSame) return;
	
	self.text = [self.text substringFromIndex: 1];
}

- (void)sendNextCharacter;
{
	if (!self.shouldSend) return;
	if (self.text == nil || (self.text).length < 1) return;
	
	[morseSender playMorseForString:[self.text substringToIndex:1]];
}

#pragma mark -
#pragma mark NSTextViewDelegateMethods

-(void) textDidChange:(NSNotification *)notification;
{
	if (morseSender.isPlaying) return;
	
	[self sendNextCharacter];
}

#pragma mark -
#pragma mark ORSMorseAudioSenderDelegate Methods
-(void) morseSender: (ORSMorseAudioSender *) sender didSendCharacter: (NSString *) charString;
{
	[self removeCharacterFromBeginningOfTextField: charString];
}

-(void) morseSenderDidFinishPlaying: (ORSMorseAudioSender *) sender;
{
	[self sendNextCharacter];
}

#pragma mark -
#pragma mark Accessor Methods

@synthesize shouldSend = _shouldSend;
- (void)setShouldSend:(BOOL)shouldSend
{
	if (shouldSend != _shouldSend) {
		_shouldSend = shouldSend;
		if (_shouldSend) [self sendNextCharacter];
	}
}

@end
