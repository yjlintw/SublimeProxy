//
//  AppDelegate.m
//  SublimeProxy
//
//  Originally Created by Tim Keating to register an apple event handler, and NSLog the output on 5/18/13.
//  Modified by Allan Lavell to open Sublime Text 2 at the correct line location on 31st 07/31/13.

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setTitle:[NSString stringWithFormat:@"S"]];
    [self.statusItem setEnabled:YES];
    [self.statusItem setToolTip:@"IPMenulet"];
    [self.statusItem setTarget:self];
    
    [[NSAppleEventManager sharedAppleEventManager]
     setEventHandler:self andSelector:@selector(handleAppleEvent:withReplyEvent:)
     forEventClass:'aevt' andEventID:'odoc'];
}

- (void)handleAppleEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:@"/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"];
    
    NSData *eventData = [event data];
    
    unsigned char *buffer = malloc(sizeof(UInt16));
    [eventData getBytes: buffer range:NSMakeRange(422, sizeof(UInt16))];
    UInt16 x = *(UInt16 *)buffer;
    if (x == ((UInt16)65534)) {
        x = 0;
    }
    x += 1;
    
    const AEKeyword filekey  = '----';
    NSString *filepath = [[[event descriptorForKeyword:filekey] stringValue] substringFromIndex:7];
    NSString *filepathWithLine = [NSString stringWithFormat:@"%@:%d", filepath, x];
    filepathWithLine = [filepathWithLine stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"%@",filepathWithLine);
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: filepathWithLine, nil];
    [task setArguments: arguments];
    
    [task launch];
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    return TRUE;
}

@end
