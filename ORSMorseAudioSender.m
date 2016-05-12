//
//  ORSMorseAudioSender.m
//  Telegraph
//
//  Created by Andrew Madsen on 01/10/11.
//  Copyright 2011 Open Reel Software. All rights reserved.
//

#import "ORSMorseAudioSender.h"

@implementation ORSMorseAudioSender

- (instancetype)init 
{
    if ((self = [super init])) 
	 {
        // Initialization code here.
		_charactersToPlay = [NSMutableArray array];
		_speedInWPM = @13;
		_pitchInHz = @800;
		_usesFarnsworth = NO;
		_dahToDitRatio = @3;
	 }
    
    return self;
}


- (void)playMorseForString:(NSString *)string;
{
	if (string == nil || string.length < 1) return;
	
	for (int i = 0; i < string.length; i++)
	 {
		NSString *eachChar = [string substringWithRange: NSMakeRange(i, 1)];
		
		[self.charactersToPlay addObject: eachChar];
	 }
	
	if (!self.playing) [self playNextCharacter];
}

#pragma mark -
#pragma NSSoundDelegate Methods

- (void)sound:(NSSound *)sound didFinishPlaying:(BOOL)aBool;
{
	[self playNextCharacter];
}


#pragma mark - Private Methods

- (void)playNextCharacter;
{
	if (self.charactersToPlay.count < 1)
	 {
		self.playing = NO;
		[self informDelegateThatSendingFinished];
		return;
	 }
	
	NSString *nextCharacter = (self.charactersToPlay)[0];
	char character = [nextCharacter characterAtIndex: 0];
	NSSound *sound = [self soundForCharacter: character];
	[self.charactersToPlay removeObjectAtIndex: 0];
	if (sound == nil)
	 {
		NSLog(@"Unable to create sound!");
		self.playing = NO;
		return [self playNextCharacter];
	 }
	
	self.playing = YES;
	[self informDelegateThatCharacterWasSent: nextCharacter];
	sound.delegate = self;
	[sound play];
}

- (NSSound *)soundForCharacter:(char)character;
{	
	NSArray *elements = [self elementsForCharacter: character];
	if (elements == nil) return nil;
	
	NSUInteger speed = self.speedInWPM.unsignedIntegerValue;
	if (self.usesFarnsworth && (speed < 13)) speed = 13;
	
	NSUInteger totalDuration = 0;
	NSMutableData *sampleData = [NSMutableData data];
	for (NSNumber *element in elements)
	 {
		NSUInteger ditDuration = 1200/speed;
		NSUInteger duration;
		switch (element.unsignedIntegerValue) {
			case ORSDit:
				duration = ditDuration;
				[sampleData appendData: [self audioToneDataWithDuration: duration]];
				break;
			case ORSDah:
				duration = self.dahToDitRatio.unsignedIntegerValue*ditDuration;
				[sampleData appendData: [self audioToneDataWithDuration: duration]];
				break;
			case ORSElementSpace:
				duration = ditDuration;
				[sampleData appendData: [self audioSilenceDataWithDuration: duration]];
				break;
			case ORSCharacterSpace:
				duration = 3*(1200/self.speedInWPM.unsignedIntegerValue);
				[sampleData appendData: [self audioSilenceDataWithDuration: duration]];
				break;
			case ORSWordSpace:
				// Not 7* because we always have a space after each letter, even at the end of a word
				duration = 4*(1200/self.speedInWPM.unsignedIntegerValue);
				[sampleData appendData: [self audioSilenceDataWithDuration: duration]];
				break;
			default:
				return nil;
				break;
		}
		totalDuration +=duration;
	 }	   
	
	NSData *headerData = [self aiffHeaderForDuration: totalDuration];
	if (headerData == nil || sampleData == nil) return nil;
	
	NSMutableData *aiffData = [headerData mutableCopy];
	[aiffData appendData: sampleData];
	
	NSSound *result = [[NSSound alloc] initWithData: aiffData];
	
	return result;
}

- (NSSound *)soundForMorseElement:(NSNumber *)morseElement;
{
	if (morseElement == nil) return nil;
	
	NSUInteger ditDuration = 1200/self.speedInWPM.unsignedIntegerValue;
	NSUInteger duration;
	NSData *aiffData=nil;
	switch (morseElement.unsignedIntegerValue) {
		case ORSDit:
			duration = ditDuration;
			aiffData = [self audioToneDataWithDuration: duration];
			break;
		case ORSDah:
			duration = self.dahToDitRatio.unsignedIntegerValue*ditDuration;
			aiffData = [self audioToneDataWithDuration: duration];
			break;
		case ORSElementSpace:
			duration = ditDuration;
			aiffData = [self audioSilenceDataWithDuration: duration];
			break;
		case ORSCharacterSpace:
			duration = 3*ditDuration;
			aiffData = [self audioSilenceDataWithDuration: duration];
			break;
		case ORSWordSpace:
			duration = 4*ditDuration; // Not 7* because we always have a space after each letter, even at the end of a word
			aiffData = [self audioSilenceDataWithDuration: duration];
			break;
		default:
			return nil;
			break;
	}
	
	NSData *headerData = [self aiffHeaderForDuration: duration];
	if (headerData == nil || aiffData == nil) return nil;
	
	NSMutableData *soundData = [headerData mutableCopy];
	[soundData appendData: aiffData];
	
	NSSound *result = [[NSSound alloc] initWithData: soundData];
	
	return result;
}

- (NSArray *)elementsForCharacter:(char)character;
{
	NSNumber *dit = @(ORSDit);
	NSNumber *dah = @(ORSDah);
	NSNumber *elementSpace = @(ORSElementSpace);
	NSNumber *charSpace = @(ORSCharacterSpace);
	NSNumber *wordSpace = @(ORSWordSpace);
	
	NSArray *charElements;
	switch (tolower(character)) {
		case 'a':
			charElements = @[dit, dah];
			break;
		case 'b':
			charElements = @[dah, dit, dit, dit];
			break;
		case 'c':
			charElements = @[dah, dit, dah, dit];
			break;
		case 'd':
			charElements = @[dah, dit, dit];
			break;
		case 'e':
			charElements = @[dit];
			break;
		case 'f':
			charElements = @[dit, dit, dah, dit];
			break;
		case 'g':
			charElements = @[dah, dah, dit];
			break;
		case 'h':
			charElements = @[dit, dit, dit, dit];
			break;
		case 'i':
			charElements = @[dit, dit];
			break;
		case 'j':
			charElements = @[dit, dah, dah, dah];
			break;
		case 'k':
			charElements = @[dah, dit, dah];
			break;
		case 'l':
			charElements = @[dit, dah, dit, dit];
			break;
		case 'm':
			charElements = @[dah, dah];
			break;
		case 'n':
			charElements = @[dah, dit];
			break;
		case 'o':
			charElements = @[dah, dah, dah];
			break;
		case 'p':
			charElements = @[dit, dah, dah, dit];
			break;
		case 'q':
			charElements = @[dah, dah, dit, dah];
			break;
		case 'r':
			charElements = @[dit, dah, dit];
			break;
		case 's':
			charElements = @[dit, dit, dit];
			break;
		case 't':
			charElements = @[dah];
			break;
		case 'u':
			charElements = @[dit, dit, dah];
			break;
		case 'v':
			charElements = @[dit, dit, dit, dah];
			break;
		case 'w':
			charElements = @[dit, dah, dah];
			break;
		case 'x':
			charElements = @[dah, dit, dit, dah];
			break;
		case 'y':
			charElements = @[dah, dit, dah, dah];
			break;
		case 'z':
			charElements = @[dah, dah, dit, dit];
			break;
		case '1':
			charElements = @[dit, dah, dah, dah, dah];
			break;
		case '2':
			charElements = @[dit, dit, dah, dah, dah];
			break;
		case '3':
			charElements = @[dit, dit, dit, dah, dah];
			break;
		case '4':
			charElements = @[dit, dit, dit, dit, dah];
			break;
		case '5':
			charElements = @[dit, dit, dit, dit, dit];
			break;
		case '6':
			charElements = @[dah, dit, dit, dit, dit];
			break;
		case '7':
			charElements = @[dah, dah, dit, dit, dit];
			break;
		case '8':
			charElements = @[dah, dah, dah, dit, dit];
			break;
		case '9':
			charElements = @[dah, dah, dah, dah, dit];
			break;
		case '0':
			charElements = @[dah, dah, dah, dah, dah];
			break;
		case '.':
			charElements = @[dit, dah, dit, dah, dit, dah];
			break;
		case ',':
			charElements = @[dah, dah, dit, dit, dah, dah];
			break;
		case '?':
			charElements = @[dit, dit, dah, dah, dit, dit];
			break;
		case '@':
			charElements = @[dit, dah, dah, dit, dah, dit];
			break;
		case ' ':
			charElements = @[wordSpace];
			break;
		default:
			return nil;
			break;
	}
	
	NSMutableArray *scratch = [NSMutableArray array];
	
	for (int i=0; i<charElements.count-1; i++)
	 {
		[scratch addObject: charElements[i]];
		[scratch addObject: elementSpace];
	 }
	[scratch addObject: charElements.lastObject];
	[scratch addObject: charSpace];
	
	
	return [scratch copy];
}

- (NSData *)audioToneDataWithDuration:(NSUInteger)milliseconds;
{
	double frequency = self.pitchInHz.doubleValue;
	
    const unsigned int sampleRate = 48000;
    const unsigned int channels = 1;
    const unsigned int bytesPerFrame = channels * sizeof(unsigned int);
    const unsigned int numSamples = milliseconds*sampleRate/1000;
	
    const unsigned int dataSize = numSamples * channels * bytesPerFrame;
    
    unsigned int i;
    
	int *soundData = malloc(dataSize);
	
	NSUInteger numFrames = numSamples * channels;
    for (i=0; i<numFrames; i++) 
	 {
        int32_t sample = INT_MAX * sin(i * M_PI * 2. * (frequency / (double)sampleRate));
		
		//shape start and end of "keydown"
		int shapeWidth=500;
		if (i < shapeWidth)
		 {
			sample = (int32_t)((double)sample*((double)i/(double)shapeWidth));
		 }
		else if ((numFrames-i) < shapeWidth)
		 {
			sample = (int32_t)((double)sample*((double)(numFrames-i)/(double)shapeWidth));
		 }
		
		soundData[i] = CFSwapInt32HostToBig(sample);
	 }
    
	NSData* data = [NSData dataWithBytes: soundData length: dataSize];
	free(soundData);
	
	return data;
}

- (NSData *)audioSilenceDataWithDuration:(NSUInteger)milliseconds;
{       
    const unsigned int sampleRate = 48000;
    const unsigned int channels = 1;
    const unsigned int bytesPerFrame = channels * sizeof(unsigned int);
    const unsigned int numSamples = milliseconds*sampleRate/1000;
	
    const unsigned int dataSize = numSamples * channels * bytesPerFrame;
    
    unsigned int i;
    
	int *soundData = malloc(dataSize);
	
    for (i=0; i < numSamples * channels; i++) {
        soundData[i] = CFSwapInt32HostToBig(0);
    }
    
	NSData* data = [NSData dataWithBytes: soundData length: dataSize];
	free(soundData);
	
	return data;
}

- (NSData *)aiffHeaderForDuration:(NSUInteger)milliseconds;
{
    struct Simple_AIFF_File {
        /* FORM chunk */
        unsigned int formID;
        int formChunkSize;
        unsigned int formType;
        
        /* COMM chunk */
        unsigned int commID;
        int commChunkSize;
        short numChannels;
        unsigned int numSampleFrames;
        short sampleSize;
        extended80 sampleRate;
        
        /* SSND chunk */
        unsigned int ssndID;
        int ssndChunkSize;
        unsigned int offset;
        unsigned int blockSize;
        int soundData[];
    } __attribute__ ((__packed__));
    
    
    const unsigned int sampleRate = 48000;
    const unsigned int channels = 1;
    const unsigned int bytesPerFrame = channels * sizeof(unsigned int);
    const unsigned int numSamples = milliseconds*sampleRate/1000;
	
    const unsigned int dataSize = numSamples * channels * bytesPerFrame;
    const unsigned int totalSize = dataSize + sizeof(struct Simple_AIFF_File);
    
    unsigned int i;
    
    struct Simple_AIFF_File* aiff = malloc(totalSize);
    if (!aiff) {
        printf("Out of memory allocating %u bytes!\n", totalSize);
        return nil;
    }
    
    aiff->formID = CFSwapInt32HostToBig('FORM');
    aiff->formChunkSize = CFSwapInt32HostToBig(totalSize - offsetof(struct Simple_AIFF_File, formType));
    aiff->formType = CFSwapInt32HostToBig('AIFF');
    
    aiff->commID = CFSwapInt32HostToBig('COMM');
    aiff->commChunkSize = CFSwapInt32HostToBig(18);
    aiff->numChannels = CFSwapInt16HostToBig(1);
    aiff->numSampleFrames = CFSwapInt32HostToBig(numSamples);
    aiff->sampleSize = CFSwapInt16HostToBig(32);
    
	memset(&(aiff->sampleRate), 0, 10);
	
    double sampleRateDouble = (double)sampleRate;
	dtox80(&sampleRateDouble, &aiff->sampleRate);
	for (int j = 0; j < 10; j++)
	 {
		uint8_t first =		*((int8_t*)((int8_t*)&((*aiff).sampleRate)+j));
		uint8_t second =	*((int8_t*)((int8_t*)&((*aiff).sampleRate)+9-j));
		*((uint8_t*)&((*aiff).sampleRate)+j)=second;
		*((uint8_t*)&((*aiff).sampleRate)+9-j)=first;
	 }
	
    aiff->ssndID = CFSwapInt32HostToBig('SSND');
    aiff->ssndChunkSize = CFSwapInt32HostToBig(dataSize + 8);
    aiff->offset = CFSwapInt32HostToBig(0);
    aiff->blockSize = CFSwapInt32HostToBig(0);
    
    for (i=0; i < numSamples * channels; i++) {
        aiff->soundData[i] = 0;
    }
    
    NSData* data = [NSData dataWithBytes: aiff length: totalSize-dataSize];
	free(aiff);
	
	return data;
}

- (void)informDelegateThatCharacterWasSent:(NSString *)string;
{
	if (self.delegate == nil) return;
	if (![self.delegate respondsToSelector: @selector(morseSender:didSendCharacter:)]) return;
	
	[self.delegate morseSender: self didSendCharacter: string];

}

- (void)informDelegateThatSendingFinished;
{
	if (self.delegate == nil) return;
	if (![self.delegate respondsToSelector: @selector(morseSenderDidFinishPlaying:)]) return;
	
	[self.delegate morseSenderDidFinishPlaying: self];
}

@end
