//
//  MyHybridPlugin.h
//  HybridIOSApp
//
//  Created by 邢磊 on 16/1/14.
//
//

#import <Cordova/CDVPlugin.h>

@interface MyHybridPlugin : CDVPlugin
- (void)playClip:(CDVInvokedUrlCommand*) command;
@end
