//
//  ORSMorseAudioSender.h
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

- (void)playMorseForString:(NSString *)string;

@property (getter = isPlaying) BOOL playing;
@property (nonatomic, copy) NSNumber *speedInWPM;
@property (nonatomic, copy) NSNumber *pitchInHz;
@property BOOL usesFarnsworth;
@property (nonatomic, copy) NSNumber *dahToDitRatio;

@property (nonatomic, weak) id<ORSMorseAudioSenderDelegate> delegate;

@property (nonatomic) NSMutableArray *charactersToPlay;

@end

@protocol ORSMorseAudioSenderDelegate <NSObject>

@optional
- (void)morseSender:(ORSMorseAudioSender *)sender didSendCharacter:(NSString *)charString;
- (void)morseSenderDidFinishPlaying:(ORSMorseAudioSender *)sender;

@end
