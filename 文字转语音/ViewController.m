//
//  ViewController.m
//  文字转语音
//
//  Created by yangsen on 16/10/13.
//  Copyright © 2016年 sitemap. All rights reserved.
//

#import "ViewController.h"
#import "YSSpeech.h"

@interface ViewController ()
{
    CGFloat            _voice;
    CGFloat            _rate;
}
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic)YSSpeech *speech;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _speech = [[YSSpeech alloc]init];
    _speech.repeatCount = 3;
    

}


- (IBAction)start:(id)sender {
    _speech.speakWords = self.textView.text;
    [_speech startSpeaking];
}
- (IBAction)pause:(id)sender {
    if (!((UIButton *)sender).isSelected) {
        BOOL isPauseSuccess = [_speech pauseSpeaking];
        NSLog(@"isPauseSuccess :___%xb_____",isPauseSuccess);
        [sender setSelected:isPauseSuccess];
    }
    else{
        [_speech continueSpeaking];
        [sender setSelected:NO];
    }
}
- (IBAction)voice:(UISlider *)sender {
    
    _speech.pitchMultiplier = sender.value;
}
- (IBAction)rate:(UISlider *)sender {
    NSLog(@"rate:%lf",sender.value);
    _speech.rate = sender.value;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
@end
