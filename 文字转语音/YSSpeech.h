//
//  YSSpeech.h
//  文字转语音
//
//  Created by yangsen on 16/10/13.
//  Copyright © 2016年 sitemap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol YSSpeechDelgate;

@interface YSSpeech : NSObject
// 读的速度 0-->1 默认0.5
@property(nonatomic) float rate;
// 读的音色 0-->2 默认1
@property(nonatomic) float pitchMultiplier;
// 读的声音大小 0-->1 默认1
@property(nonatomic) float volume;
// 读一段前话的停顿 0.0 
@property(nonatomic, readonly) NSTimeInterval preUtteranceDelay;
// 读一段话之后的停顿 0.0
@property(nonatomic, readonly) NSTimeInterval postUtteranceDelay;
// 读的话
@property (copy, nonatomic) NSString *speakWords;

@property (weak, nonatomic) id <YSSpeechDelgate> delegate;

// 重复次数；
@property (assign, nonatomic) NSInteger repeatCount;

- (void)startSpeaking;
- (BOOL)stopSpeaking;
- (BOOL)pauseSpeaking;
- (BOOL)continueSpeaking;

@end

@protocol YSSpeechDelgate <NSObject>

- (void)speechdidStart:(YSSpeech *)speech;
- (void)speechdidFinish:(YSSpeech *)speech;
- (void)speechdidPause:(YSSpeech *)speech;
- (void)speechdidContinue:(YSSpeech *)speech;
- (void)speechdidCancel:(YSSpeech *)speech;

- (void)speech:(YSSpeech *)speech willSpeakRangeOfSpeechString:(NSRange)characterRange;

@end
