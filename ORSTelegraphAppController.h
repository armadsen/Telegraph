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

@interface ORSTelegraphAppController : NSObject <NSTextViewDelegate, ORSMorseAudioSenderDelegate>

- (IBAction)send:(id)sender;

- (void)removeCharacterFromBeginningOfTextField:(NSString *)charString;
- (void)sendNextCharacter;

// Properties

@property (nonatomic, strong) IBOutlet NSWindow *window;
@property (nonatomic) IBOutlet NSTextView *textView;
@property (nonatomic) IBOutlet ORSMorseAudioSender *morseSender;

@property (nonatomic, copy) NSString *text;

@property (nonatomic) BOOL shouldSend;

@end
