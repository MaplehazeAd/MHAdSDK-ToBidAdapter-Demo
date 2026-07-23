//
//  MHVolumeManager.m
//  MHAdSDK
//
//  Created by 郭建恒 on 2025/4/17.
//

#import "MHSoundChecker.h"
#import <AudioToolbox/AudioToolbox.h>

@interface MHSoundChecker ()
{
    
}
// 在头文件中声明
@property (nonatomic, assign) SystemSoundID silentSoundID;
@property (nonatomic, copy) void (^completionBlock)(BOOL);
@property (nonatomic, strong) NSDate *playStartTime;

@end

@implementation MHSoundChecker

- (void)checkSilentModeWithCompletion:(void (^)(BOOL))completion {
    // 1. 准备静音音频文件（必须使用CAF格式）
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"sound_check" withExtension:@"caf"];
    if (!fileURL) {
        NSLog(@"错误：缺少静音文件");
        completion(NO);
        return;
    }
    
    // 2. 创建系统声音
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &_silentSoundID);
    
    // 3. 注册播放完成回调
//    AudioServicesAddSystemSoundCompletion(_silentSoundID, NULL, NULL, soundCompletionHandler, (__bridge void*)self);
    AudioServicesAddSystemSoundCompletion(
        _silentSoundID,
        NULL,
        NULL,
        soundCompletionHandler,
        (__bridge_retained void *)self  // ⬅️ 关键修改：用 __bridge_retained 保证对象存活
    );
    
    // 4. 记录播放开始时间
    _playStartTime = [NSDate date];
    _completionBlock = [completion copy];
    
    // 5. 播放声音（关键步骤）
    AudioServicesPlaySystemSound(_silentSoundID);
    
    // 6. 设置超时检测（0.3秒后强制判定）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (self.completionBlock) {
            // 计算播放耗时
            NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:self.playStartTime];
            // 耗时 >0.1秒视为未静音
            BOOL isMuted = (duration < 0.1);
            self.completionBlock(isMuted);
            self.completionBlock = nil;
            
            // 清理资源
            AudioServicesRemoveSystemSoundCompletion(self.silentSoundID);
            AudioServicesDisposeSystemSoundID(self.silentSoundID);
        }
    });
}

// 声音播放完成回调
static void soundCompletionHandler(SystemSoundID ssID, void *clientData) {
    
    MHSoundChecker *checker = (__bridge_transfer MHSoundChecker *)clientData;
    // 安全判断，虽然理论上不应该为 nil
    if (!checker) {
        return;
    }
    if (checker.completionBlock) {
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:checker.playStartTime];
        // 正常播放完成时间在 0.01~0.05 秒之间
        BOOL isMuted = (duration < 0.1);
        checker.completionBlock(isMuted);
        checker.completionBlock = nil;
        
        // 清理资源
        AudioServicesRemoveSystemSoundCompletion(checker.silentSoundID);
        AudioServicesDisposeSystemSoundID(checker.silentSoundID);
    }
}

@end
