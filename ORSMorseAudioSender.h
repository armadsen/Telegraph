//
//  ORSMorseAudioSender.h
//  Telegraph
//
//  Created by Andrew Madsen on 01/10/11.
//  Copyright 2011 Open Reel Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ORSMorseAudioSenderDelegate;
typedef NS_ENUM(NSUInteger, ORSMorseElement) 
{
	ORSDit,
	ORSDah,
	ORSElementSpace,
	ORSCharacterSpace,
	ORSWordSpace
};

@interface ORSMorseAudioSender : NSObject <NSSoundDelegate>

@property (getter = isPlaying) BOOL playing;
@property (nonatomic, copy) NSNumber *speedInWPM;
@property (nonatomic, copy) NSNumber *pitchInHz;
@property BOOL usesFarnsworth;
@property (nonatomic, copy) NSNumber *dahToDitRatio;

@property (nonatomic, unsafe_unretained) id <ORSMorseAudioSenderDelegate> delegate;

@property (nonatomic) NSMutableArray *charactersToPlay;

-(void) playMorseForString: (NSString *) string;

@end

@protocol ORSMorseAudioSenderDelegate <NSObject>

@optional
-(void) morseSender: (ORSMorseAudioSender *) sender didSendCharacter: (NSString *) charString;
-(void) morseSenderDidFinishPlaying: (ORSMorseAudioSender *) sender;

@end
