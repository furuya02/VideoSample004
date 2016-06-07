//
//  ViewController.m
//  VideoSample004
//
//  Created by hirauchi.shinichi on 2016/06/07.
//  Copyright © 2016年 SAPPOROWORKS. All rights reserved.
//

#import "ViewController.h"
#import "AVPlayerView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (nonatomic,strong) AVPlayerView *playerView;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic) BOOL isFullScreen;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL *url = [NSURL URLWithString:@"https://s3-ap-northeast-1.amazonaws.com/hls-sample/index.m3u8"];
    _player = [[AVPlayer alloc]initWithURL:url];
    _playerView = [[AVPlayerView alloc]initWithFrame:CGRectMake(0,
                                                               20,
                                                               self.view.frame.size.width,
                                                               300)];
    [(AVPlayerLayer*)_playerView.layer setPlayer:_player];
    [self.view addSubview:_playerView];
    [self.view bringSubviewToFront:_playerView];

    //ビデオの長さ(Sec)を取得
    Float64 duration = CMTimeGetSeconds(_player.currentItem.asset.duration);

    // スライダーの最大値を設定
    _slider.maximumValue = duration;

    // 再生時間とシークバー位置を連動させるためのタイマー
    const double interval = ( 0.5f * _slider.maximumValue ) / _slider.bounds.size.width;
    const CMTime time     = CMTimeMakeWithSeconds( interval, NSEC_PER_SEC );
    [_player addPeriodicTimeObserverForInterval:time
                                          queue:NULL
                                     usingBlock:^( CMTime time ) { [self syncSeekBar]; }];
}

- (IBAction)tapPlayButton:(id)sender {
    [_player play];
}
- (IBAction)tapForwardingButton:(id)sender {
    Float64 time     = CMTimeGetSeconds([_player currentTime]);
    time += 3;
    [_player seekToTime:CMTimeMakeWithSeconds( time, NSEC_PER_SEC )];
}
- (IBAction)tapRewindButton:(id)sender {
    Float64 time     = CMTimeGetSeconds([_player currentTime]);
    time -= 3;
    [_player seekToTime:CMTimeMakeWithSeconds( time, NSEC_PER_SEC )];
}

- (IBAction)tapPauseButton:(id)sender {
    [_player pause];
}
- (IBAction)changeSeekBar:(id)sender {
    [_player seekToTime:CMTimeMakeWithSeconds( _slider.value, NSEC_PER_SEC )];
}

- (void)syncSeekBar
{
    // スライダーの位置合わせ
    Float64 duration = CMTimeGetSeconds(_player.currentItem.asset.duration);
    Float64 time     = CMTimeGetSeconds([_player currentTime]);
    Float64 value    = ( _slider.maximumValue - _slider.minimumValue ) * time / duration + _slider.minimumValue;
    [_slider setValue:value];
}


@end
