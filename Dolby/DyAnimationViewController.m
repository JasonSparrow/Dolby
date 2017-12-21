//
//  DyAnimationViewController.m
//  Dolby
//
//  Created by hr on 2017/12/17.
//  Copyright © 2017年 王腾飞. All rights reserved.
//

#import "DyAnimationViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "DyAnimation.h"

@interface DyAnimationViewController ()
@property (nonatomic, strong)AVPlayer *play;
@property (nonatomic, strong)AVPlayerItem *playItem;
@end

@implementation DyAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    /*
     使用Core Animation为视频应用程序创建叠加效果同使用它在iOS或着OS X上创建动画是一样的, 最大的区别在于运行动画的时间模型, 当创建实时动画时, CAAnimation实例从系统主机时钟获取执行时间.
     主机时间从系统启动开始计算并单向向前推进, 将动画执行时间同主机时间相关联在实时动画方面非常合适, 不过对于创建视频动画就不合适了, 视频动画需要基于影片时间来推进, 开始时间应该是影片的开始时间直到影片持续时间结束, 另外主机时间是一直向前推进, 从不会停止, 而影片时间可以停止, 暂停, 回退, 快进. 因为动画需要紧密地与视频时间绑定, 所以需要使用不同的时间执行模式
     */
    [self animation];
   
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    switch (_play.status) {
        case AVPlayerStatusReadyToPlay:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_play play];
            });
        }
            break;
            
        default:
            break;
    }
}

- (void)animation {
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 100, 200, 200);
    parentLayer.backgroundColor = [UIColor blueColor].CGColor;
    [self.view.layer addSublayer:parentLayer];
    
    
    UIImage *image = [UIImage imageNamed:@"1.jpg"];
    CALayer *imageLayer = [CALayer layer];
    
    imageLayer.contents = (__bridge id _Nullable)(image.CGImage);
    imageLayer.contentsScale = [UIScreen mainScreen].scale;
    
    CGFloat midX = CGRectGetMidX(parentLayer.bounds);
    CGFloat midY = CGRectGetMidY(parentLayer.bounds);
    
    imageLayer.bounds = parentLayer.bounds;
    imageLayer.position = CGPointMake(midX, midY);
    
    [parentLayer addSublayer:imageLayer];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    /*
     CoreAnimation 的默认行为是执行动画并在动画行为完成后进行处理, 通常这些行为就是我们希望在实时案例中使用的, 因为时间一旦过去就无法再次返回了, 这对于视频动画就会有问题, 所以需要设置动画removedOnCompletion为NO, 如果没有这样做, 则动画就是一次性的, 如果用户重播或者移动搓擦条, 将不会再次看到动画, 这显示不是我们想要的效果.
     */
    rotationAnimation.removedOnCompletion = NO;
//    rotationAnimation.fromValue = @(0);
    rotationAnimation.toValue = @(2 * M_PI);
    /*
     动画的beginTime属性被设置为0.0的话是不会看到动画效果的, Core Animation将值为0的beginTime对象转化为CACurrentMediaTime(), 这是当前的主机时间, 同影片的时间轴时间没有关系, 如果希望在影片的开头加入动画, 将动画的beginTime属性设置成AVCoreAnimationBeginTimeAtZero常量.
     */
    
    rotationAnimation.beginTime = AVCoreAnimationBeginTimeAtZero;
//    rotationAnimation.fillMode = kCAFillModeBoth;
    rotationAnimation.duration = 3.0f;
    rotationAnimation.repeatCount = HUGE_VALF;
    [imageLayer addAnimation:rotationAnimation forKey:@"rotateAnimation"];
    
    
    DyAnimation *dy = [[DyAnimation alloc] init];
    self.playItem = dy.makePlayable;
    [_playItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    _play = [AVPlayer playerWithPlayerItem:_playItem];
    
    
    AVPlayerLayer * playLayer = [AVPlayerLayer playerLayerWithPlayer:_play];
    playLayer.backgroundColor = [UIColor redColor].CGColor;
    playLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:playLayer];
    
    //AVSynchronizedLayer用于和AVPlayItem对象同步时间, 这个图层本身不展示任何内容, 只是用来与图层子树协同时间.
    AVSynchronizedLayer *syncLayer = [AVSynchronizedLayer synchronizedLayerWithPlayerItem:_playItem];
    [syncLayer addSublayer:parentLayer];
    [self.view.layer addSublayer:syncLayer];

}
    
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_playItem removeObserver:self forKeyPath:@"status" context:nil];
}


@end
