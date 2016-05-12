//
//  AppController.m
//  Telegraph
//
//  Created by Andrew Madsen on 01/10/11.
//  Copyright 2011 Open Reel Software. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a
//	copy of this software and associated documentation files (the
//	"Software"), to deal in the Software without restriction, including
//	without limitation the rights to use, copy, modify, merge, publish,
//	distribute, sublicense, and/or sell copies of the Software, and to
//	permit persons to whom the Software is furnished to do so, subject to
//	the following conditions:
//
//	The above copyright notice and this permission notice shall be included
//	in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "ORSTelegraphAppController.h"
#import "ORSMorseAudioSender.h"

@implementation ORSTelegraphAppController

@synthesize text;

- (void)awakeFromNib;
{
	self.morseSender.delegate = self;
}

- (IBAction)send:(id)sender
{
	[self.morseSender playMorseForString:self.textView.string];
}

- (void)removeCharacterFromBeginningOfTextField:(NSString *)charString;
{
	if (charString == nil || charString.length < 1) return;
	
	if (charString.length > 1) charString = [charString substringToIndex:1];
	
	if ([[self.text substringToIndex:1] caseInsensitiveCompare:charString] != NSOrderedSame) return;
	
	self.text = [self.text substringFromIndex:1];
}

- (void)sendNextCharacter;
{
	if (!self.shouldSend) return;
	if (self.text == nil || (self.text).length < 1) return;
	
	[self.morseSender playMorseForString:[self.text substringToIndex:1]];
}

#pragma mark - NSTextViewDelegateMethods

- (void)textDidChange:(NSNotification *)notification;
{
	if (self.morseSender.isPlaying) return;
	
	[self sendNextCharacter];
}

#pragma mark - ORSMorseAudioSenderDelegate Methods
- (void)morseSender:(ORSMorseAudioSender *)sender didSendCharacter:(NSString *)charString;
{
	[self removeCharacterFromBeginningOfTextField:charString];
}

- (void)morseSenderDidFinishPlaying:(ORSMorseAudioSender *)sender;
{
	[self sendNextCharacter];
}

#pragma mark - Properties

@synthesize shouldSend = _shouldSend;
- (void)setShouldSend:(BOOL)shouldSend
{
	if (shouldSend != _shouldSend) {
		_shouldSend = shouldSend;
		if (_shouldSend) [self sendNextCharacter];
	}
}

@end
