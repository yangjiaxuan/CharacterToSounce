//
//  YSSpeech.m
//  文字转语音
//
//  Created by yangsen on 16/10/13.
//  Copyright © 2016年 sitemap. All rights reserved.
//

#import "YSSpeech.h"

@interface YSSpeech()<AVSpeechSynthesizerDelegate>
{
    AVSpeechSynthesizer *_speechSynthier;
    AVSpeechUtterance   *_speechUtterance;
    AVSpeechSynthesisVoice *_speechVoice;
    NSInteger               _currentSpeakIndex;
    NSString               *_currentSpeakWords;
    NSInteger               _currentRepeatCount;
    BOOL                    _isSetComplete; // 设置数据是否完成
    BOOL                    _isPause; // 是否停止
}
@end

@implementation YSSpeech

- (instancetype)init{
    if (self = [super init]) {
        [self setupData];
    }
    return self;
}

- (void)setupData{

    _speechSynthier = [[AVSpeechSynthesizer alloc]init];
    _speechSynthier.delegate = self;
    _pitchMultiplier    = 1;
    _preUtteranceDelay  = 0.0;
    _postUtteranceDelay = 0.0;
    _rate               = 0.5;
    _volume             = 1;
    _repeatCount        = 1;
    _currentSpeakIndex  = _repeatCount;
    _isPause            = YES;
}


#pragma mark ----------- 读的逻辑 -----------------
- (void)startSpeaking{
    _currentRepeatCount = _repeatCount;
    _isPause = NO;
    [self startToSpeak];
}

- (void)startToSpeak{
    [_speechSynthier stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    if (!_currentSpeakWords) {
        return;
    }
    [_speechSynthier speakUtterance:[self speechUtteranceWithSpeakWords:_currentSpeakWords]];
}
- (BOOL)pauseSpeaking{
    _isPause = YES;
    return [_speechSynthier pauseSpeakingAtBoundary:AVSpeechBoundaryWord];
}

- (BOOL)continueSpeaking{
    _isPause = NO;
    return [_speechSynthier continueSpeaking];
}

- (BOOL)stopSpeaking{
    _currentRepeatCount = 1;
    return [_speechSynthier stopSpeakingAtBoundary:AVSpeechBoundaryWord];
}
#pragma mark -------- 代理 ----------
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance{
    if ([self.delegate respondsToSelector:@selector(speechdidStart:)]) {
        [self.delegate speechdidStart:self];
    }
    _isSetComplete = YES;
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"repeatCount:%lu",_currentRepeatCount);
    if (_currentRepeatCount == 1) {
        if ([self.delegate respondsToSelector:@selector(speechdidFinish:)]) {
            [self.delegate speechdidFinish:self];
        }
        _currentRepeatCount = 1;
    }
    else{
        _currentSpeakWords = _speakWords;
        _currentRepeatCount --;
        if (_isPause == YES) {
            [self pauseSpeaking];
            return;
        }
        [self startToSpeak];
    }
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance{
    if ([self.delegate respondsToSelector:@selector(speechdidPause:)]) {
        [self.delegate speechdidPause:self];
    }
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance{
    if ([self.delegate respondsToSelector:@selector(speechdidContinue:)]) {
        [self.delegate speechdidContinue:self];
    }
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance{
    if ([self.delegate respondsToSelector:@selector(speechdidCancel:)]) {
        [self.delegate speechdidCancel:self];
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance{
    _currentSpeakIndex = characterRange.location + characterRange.length;
    
    if ([self.delegate respondsToSelector:@selector(speech:willSpeakRangeOfSpeechString:)]) {
        [self.delegate speech:self willSpeakRangeOfSpeechString:characterRange];
    }
}

// 重新开始读
- (void)resetReadWord{

    NSInteger length   = _currentSpeakWords.length;
    _currentSpeakWords = [_currentSpeakWords substringWithRange:NSMakeRange(_currentSpeakIndex, length - _currentSpeakIndex)];
    [self startToSpeak];
}


#pragma mark ----------- set get ----------------

- (void)setRate:(float)rate{
    if (!_isSetComplete) {
        return;
    }
    _isSetComplete = NO;

    _rate = rate;
    [self resetReadWord];
}
- (void)setPitchMultiplier:(float)pitchMultiplier{
    if (!_isSetComplete) {
        return;
    }
    _isSetComplete = NO;
    _pitchMultiplier = pitchMultiplier;
    [self resetReadWord];
}
- (void)setVolume:(float)volume{
    if (!_isSetComplete) {
        return;
    }
    _isSetComplete = NO;
    _volume= volume;
    [self resetReadWord];
}
- (void)setPreUtteranceDelay:(NSTimeInterval)preUtteranceDelay{
    if (!_isSetComplete) {
        return;
    }
    _isSetComplete = NO;
    
    _preUtteranceDelay = preUtteranceDelay;
    [self resetReadWord];
}
- (void)setPostUtteranceDelay:(NSTimeInterval)postUtteranceDelay{
    if (!_isSetComplete) {
        return;
    }
    _isSetComplete = NO;
    
    _postUtteranceDelay = postUtteranceDelay;
    [self resetReadWord];
}
- (void)setSpeakWords:(NSString *)speakWords{
    
    if (![speakWords isEqualToString:_speakWords]) {
        _speakWords        = speakWords;
        _currentSpeakWords = speakWords;
        [self startSpeaking];
    }
}

- (void)setRepeatCount:(NSInteger)repeatCount{
    _repeatCount = repeatCount;
    if (repeatCount < _currentRepeatCount) {
        _currentRepeatCount = 1;
    }
    else{
        _currentRepeatCount = repeatCount - _currentRepeatCount;
    }
}
- (AVSpeechUtterance *)speechUtteranceWithSpeakWords:(NSString *)speakWords{
    _speechUtterance = [[AVSpeechUtterance alloc]initWithString:speakWords];
    _speechUtterance.rate               = self.rate;
    _speechUtterance.pitchMultiplier    = self.pitchMultiplier;
    _speechUtterance.postUtteranceDelay = self.postUtteranceDelay;
    _speechUtterance.preUtteranceDelay  = self.preUtteranceDelay;
    _speechUtterance.volume             = self.volume;
    _speechUtterance.voice              = [self speechVoice];
    return _speechUtterance;
}

- (AVSpeechSynthesisVoice *)speechVoice{
    if (!_speechVoice) {
        _speechVoice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh_CN"];
    }
    return _speechVoice;
}
@end
