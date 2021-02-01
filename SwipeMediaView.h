#import <UIKit/UIKit.h>
#import "YTPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "NAModalSheet.h"
#import <SCLPlayer/SCLPlayerViewController.h>
#import <AVKit/AVKit.h>

@interface SwipeMediaView : UIView<YTPlayerViewDelegate, AVAudioPlayerDelegate, MBProgressHUDDelegate, NAModalSheetDelegate>

- (instancetype)initWithFrame:(CGRect)frame withTop:(UIView *)top andBottom:(UIView *)bottom NS_DESIGNATED_INITIALIZER;
@property (readwrite, strong, nonatomic) SCLPlayerViewController* playerVC;


@property (strong, nonatomic) NSMutableArray *userDataArray;
@property (strong, nonatomic) NSMutableDictionary *userDictionary;

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIView *bottomView;

@property (strong, nonatomic) NSString *socialMedia;
@property (strong, nonatomic) NSString *facebookShareUrl;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) UILabel *currentTimeLabel;
@property long entityID;
@property (strong, nonatomic) NSString *entityIDString;

@property float maximumAllowedHeight;
@property float maximumAllowedTopView;
@property float maximumAllowedBottomView;

@property (strong, nonatomic) NSMutableArray *mediaPlayerArray;
@property (strong, nonatomic) NSDictionary *mediaContentDictionary;
@property (strong, nonatomic) NSMutableDictionary *mediaContentDictionaryMutable;
@property (strong, nonatomic) NSMutableArray *queueCoreDataArray;
@property (strong, nonatomic) NSMutableArray *entityIDArray;
@property NSInteger currentItemIndex;
@property long likeInteger;
@property NSInteger playerInteger;
@property  NSTimeInterval interval;
@property NSTimer *timer;

@property BOOL shuffleMedia;
@property BOOL repeatMedia;

@property (strong, nonatomic) UIButton *voteButton;
@property (strong, nonatomic) UIButton *pickAWinnerButton;
@property BOOL votedBool;

@property (nonatomic, strong) NSString *totalTime;

@property (strong, nonatomic) UILabel *playButton;
@property (strong, nonatomic) UILabel *previousSong;
@property (strong, nonatomic) UILabel *fastForward;
@property (strong, nonatomic) UIButton *likeButton;
@property (strong, nonatomic) UIButton *collectButton;
@property (strong, nonatomic) UIButton *queueButton;
@property (strong, nonatomic) UIButton *repeatButton;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UIButton *randomButton;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *artistName;


//Youtube
@property (nonatomic, strong) IBOutlet YTPlayerView *player;

//SoundCloud
@property (strong, nonatomic) IBOutlet UIImageView *soundcloudArtwork;
@property (nonatomic, strong) AVAudioPlayer *soundcloudPlayer;
@property (nonatomic, strong) id playbackObserver;
@property (strong, nonatomic) IBOutlet UISlider *songSlider;
@property (nonatomic, strong) NSString *artworkSoundcloudURL;
@property (nonatomic, strong) NSString *songStringURL;

//Facebook Player and Instagram
@property (nonatomic, strong) MPMoviePlayerController *facebookPlayer;
@end
