//
//  AppController.h
//  Telegraph
//
//  Created by Andrew Madsen on 01/10/11.
//  Copyright 2011 Open Reel Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ORSMorseAudioSender.h"

@class ORSMorseAudioSender;

@interface AppController : NSObject <NSTextViewDelegate, ORSMorseAudioSenderDelegate>
{
	IBOutlet NSTextView *textView;
	IBOutlet ORSMorseAudioSender *morseSender;
	
	NSString *text;
	
	BOOL shouldSend;
}

@property (nonatomic) IBOutlet ORSMorseAudioSender *morseSender;

@property (nonatomic, copy) NSString *text;

@property BOOL shouldSend;

- (IBAction)send:(id)sender;

-(void) removeCharacterFromBeginningOfTextField: (NSString *) charString;
-(void) sendNextCharacter;

@end
