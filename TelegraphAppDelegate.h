//
//  TelegraphAppDelegate.h
//  Telegraph
//
//  Created by Andrew Madsen on 01/10/11.
//  Copyright 2011 Open Reel Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TelegraphAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *__unsafe_unretained window;
}

@property (unsafe_unretained) IBOutlet NSWindow *window;

@end
