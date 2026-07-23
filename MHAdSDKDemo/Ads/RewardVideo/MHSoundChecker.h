//
//  MHVolumeManager.h
//  MHAdSDK
//
//  Created by 郭建恒 on 2025/4/17.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN



@interface MHSoundChecker : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

- (void)checkSilentModeWithCompletion:(void (^)(BOOL isMuted))completion;

@end

NS_ASSUME_NONNULL_END
