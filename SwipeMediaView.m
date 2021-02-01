#import "SwipeMediaView.h"
#import "ScreenSizes.h"
#import "AppColors.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import "FontAwesomeKit/FAKFoundationIcons.h"
#import "FontAwesomeKit/FAKIonIcons.h"
#import "DoActionSheet.h"
#import "DoActionSheet+Demo.h"
#import "APILinks.h"
#import <CoreData/CoreData.h>
#import "AFNetworking.h"
#import "ErrorAlertView.h"
#import <Social/Social.h>
#import "TabBarViewController.h"
#import "OverviewHotBoxViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <TwitterKit/TwitterKit.h>
#import "PlayLabel.h"
#import "PlayButton.h"
@implementation SwipeMediaView
{
    CGRect originalFrame;
    BOOL isLarge;
    MBProgressHUD *HUD;
    TabBarViewController *tabBarController;
}

-(void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state{
    if(state == kYTPlayerStatePlaying || state == kYTPlayerStateBuffering){
        self.playButton.text = [NSString fontAwesomeIconStringForEnum:FAPause];
    }
    else if(state == kYTPlayerStatePaused){
        self.playButton.text = [NSString fontAwesomeIconStringForEnum:FAPlayCircle];
    }
    else if(state == kYTPlayerStateEnded){
        self.playButton.text = [NSString fontAwesomeIconStringForEnum:FAPlayCircle];
        if(self.queueCoreDataArray.count != 0){
            [self nextSong];
        }
    }
}

-(void)nextSong{
    if(self.queueCoreDataArray.count == 0){
        if(self.repeatMedia == YES && self.shuffleMedia == YES){
            [self.player seekToSeconds:0 allowSeekAhead:YES];
        }
        else if(self.repeatMedia == YES && self.shuffleMedia == NO){
            [self.player seekToSeconds:0 allowSeekAhead:YES];
        }
        else{
            [self.player stopVideo];
        }
    }
    else{
        if(self.currentItemIndex == self.entityIDArray.count){
            self.currentItemIndex = 0;
            self.entityID = [[self.entityIDArray objectAtIndex:self.currentItemIndex] longValue];
        }
        else{
            self.currentItemIndex++;
            if(self.currentItemIndex >= self.entityIDArray.count){
                self.entityID = [[self.entityIDArray firstObject] longValue];
                self.currentItemIndex = 0;
            }
            else{
                self.entityID = [[self.entityIDArray objectAtIndex:self.currentItemIndex] longValue];
            }
            
        }
        [self reset:FALSE];
        [self.playerVC pause];
        [self.facebookPlayer stop];
        [self.playerVC.view removeFromSuperview];
        [self.facebookPlayer.view removeFromSuperview];
        [self.player removeFromSuperview];
        [self.playButton removeFromSuperview];
        [self.fastForward removeFromSuperview];
        [self.previousSong removeFromSuperview];
        [self.likeButton removeFromSuperview];
        [self.collectButton removeFromSuperview];
        [self.shareButton removeFromSuperview];
        [self.queueButton removeFromSuperview];
        [self.randomButton removeFromSuperview];
        [self.repeatButton removeFromSuperview];
        [self.titleLabel removeFromSuperview];
        [self.artistName removeFromSuperview];
        [self manageViews];
    }
}

-(void)playerViewDidBecomeReady:(YTPlayerView *)playerView{
    [playerView playVideo];
}

- (void)MPMoviePlayerPlaybackStateDidChange:(NSNotification *)notification
{
    //are we currently playing?
    if (self.facebookPlayer.playbackState == MPMoviePlaybackStatePlaying)
    { //yes->do something as we are playing...
        self.playButton.text = [NSString fontAwesomeIconStringForEnum:FAPause];
    }
    else
    { //nope->do something else since we are not playing
        self.playButton.text = [NSString fontAwesomeIconStringForEnum:FAPlayCircle];
    }
}

-(void)SCLPlayerDidFinishNotification:(NSNotification *)notification{
    if(self.queueCoreDataArray.count != 0){
        [self nextSong];
    }
}

- (instancetype)initWithFrame:(CGRect)frame withTop:(UIView *)top andBottom:(UIView *)bottom
{
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    _topView = top;
    _bottomView = bottom;
    originalFrame = self.frame;
    self.maximumAllowedHeight = self.frame.size.height;
    self.maximumAllowedTopView = _topView.frame.size.height;
    self.maximumAllowedBottomView = _bottomView.frame.size.height;
    isLarge = YES;

    if(isLarge){
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.maximumAllowedTopView + self.maximumAllowedBottomView);
    }
    else{
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.maximumAllowedHeight);
        
    }
    self.currentItemIndex = 0;
    [self addSubview:_topView];
    [self addSubview:_bottomView];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(minimizeView)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    [top addGestureRecognizer:swipeGesture];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(maximizeView:)];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [top addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(removeToTheLeft)];
    [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [top addGestureRecognizer:leftSwipe];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveNotifications:) name:@"MediaPlayerItem" object:nil];
    [self reset:TRUE];
    return self;
}

-(void)reset:(BOOL)hideOrUnHide{
    //Delete all UI elements
    
    if(hideOrUnHide){
        [self hideMe:FALSE];
    }
    else{
        [self unhideMe];
    }
}

-(void)removeToTheLeft{
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         
                         self.topView.center = CGPointMake((-self->originalFrame.size.width * 0.75), self.topView.frame.size.height * 0.5);
                         self.topView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self hideMe:TRUE];
                         
                     }];
}

- (void)removeMe
{
    [self removeFromSuperview];
    
}

- (void)hideMe:(BOOL)notReset{
    
    self.hidden = YES;
    if(notReset){
        [self maximizeView:nil];
        [self removeSubviews:_topView];
        [self removeSubviews:_bottomView];
        self.mediaContentDictionary = nil;
    }
}

-(void)removeSubviews:(UIView *)view{
    [self.playerVC pause];
    [self.playerVC.view removeFromSuperview];
    [self.facebookPlayer stop];
    [self.facebookPlayer.view removeFromSuperview];
    [self.player stopVideo];
    [self.player removeFromSuperview];
    NSArray *viewsToRemove = [view subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
}

- (void)unhideMe{
    self.topView.center = CGPointMake(originalFrame.size.width / 2, originalFrame.size.height / 2);
    self.topView.alpha = 1;
    self.hidden = NO;
}

- (void)maximizeView:(UIPanGestureRecognizer *)recognizer
{
    if (isLarge){
        return;
    }

    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        CGAffineTransform first = CGAffineTransformMakeScale(2.0, 2.0);
        CGPoint destination;
        
        destination = CGPointMake((-self->originalFrame.size.width * 0.25) * 2, (-self.frame.size.height * 0.70) * 2);

        CGAffineTransform second = CGAffineTransformTranslate(self.transform, destination.x, destination.y);
        
        CGAffineTransform combo = CGAffineTransformConcat(first, second);
        self.transform = combo;
        self.bottomView.hidden = NO;
        self.bottomView.alpha = 1;
    } completion:^(BOOL finished) {
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.maximumAllowedTopView + self.maximumAllowedBottomView);
        self->isLarge = YES;
        
    }];
    
}

-(void)recieveNotifications:(NSNotification *)notification{
    self.mediaContentDictionaryMutable = [[NSMutableDictionary alloc] init];
    self.mediaContentDictionary = [[NSDictionary alloc] init];
    self.mediaContentDictionary = notification.userInfo;
    
    self.entityID = [[self.mediaContentDictionary objectForKey:@"entityID"] longValue];
    //if(self.hidden == TRUE){
    self.shuffleMedia = NO;
    self.repeatMedia = NO;
    [self reset:FALSE];
    [self.playerVC pause];
    [self.playerVC.view removeFromSuperview];
    [self.facebookPlayer stop];
    [self.facebookPlayer.view removeFromSuperview];
    [self.player stopVideo];
    [self.player removeFromSuperview];
    [self.playButton removeFromSuperview];
    [self.fastForward removeFromSuperview];
    [self.previousSong removeFromSuperview];
    [self.likeButton removeFromSuperview];
    [self.collectButton removeFromSuperview];
    [self.shareButton removeFromSuperview];
    [self.queueButton removeFromSuperview];
    [self.randomButton removeFromSuperview];
    [self.repeatButton removeFromSuperview];
    [self.titleLabel removeFromSuperview];
    [self.artistName removeFromSuperview];
    [self manageViews];
    //}
}

- (NSString *)extractYoutubeIdFromLink:(NSString *)link {
    NSString *regexString = @"((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)";
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:nil];
    
    NSArray *array = [regExp matchesInString:link options:0 range:NSMakeRange(0,link.length)];
    if (array.count > 0) {
        NSTextCheckingResult *result = array.firstObject;
        return [link substringWithRange:result.range];
    }
    return nil;
}

-(void)manageViews{
    
    
    AppColors *appColors = [[AppColors alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerPlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    NSLog(@"%@",[self extractYoutubeIdFromLink:[self.mediaContentDictionary objectForKey:@"urlString"]]);
    
    
    
    self.playerInteger = 0;
    self.player = [[YTPlayerView alloc] initWithFrame:self->_topView.frame];
    [self.player setHidden:NO];
    self.player.delegate = self;
    [self->_topView addSubview:self.player];
    
    //Youtube Video
    NSDictionary *playerVars = @{
                                 @"playsinline" : @1,
                                 @"showinfo" : @1,
                                 @"controls" : @1,
                                 @"origin" : @"https://www.example.com"
                                 };
    
    NSString *videoSource = [self extractYoutubeIdFromLink:[self.mediaContentDictionary objectForKey:@"urlString"]];
    [self.player loadWithVideoId:videoSource playerVars:playerVars];
    [self.player playVideo];
    
    //self.entityIDArray = [[NSMutableArray alloc] init];
    //self.entityIDArray = [self.queueCoreDataArray valueForKey:@"entityString"];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self->_bottomView.frame.size.width - 10, 40)];
    self.titleLabel.font = [UIFont fontWithName:@"Runda" size:15];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor whiteColor];
    NSString *titleLabelString = @"";
    id titleLabelNullCheck = [self.mediaContentDictionary objectForKey:@"title"];
    if(titleLabelNullCheck != [NSNull null]){
        titleLabelString = (NSString *)titleLabelNullCheck;
    }
    self.titleLabel.text = titleLabelString;
    [self->_bottomView addSubview:self.titleLabel];
    
    self.artistName = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, self->_bottomView.frame.size.width, 30)];
    self.artistName.font = [UIFont fontWithName:@"Runda-Bold" size:13];
    self.artistName.textAlignment = NSTextAlignmentCenter;
    self.artistName.textColor = [appColors mainColor];
    id artistNameStringID = [self.mediaContentDictionary objectForKey:@"displayName"];
    if(artistNameStringID != [NSNull null]){
        self.artistName.text = (NSString *)artistNameStringID;
    }
    else{
        self.artistName.text = @"";
    }
    [self->_bottomView addSubview:self.artistName];
    
    UIButton *artistButton = [[UIButton alloc] initWithFrame:self.artistName.frame];
    [artistButton addTarget:self action:@selector(openArtistProfile:) forControlEvents:UIControlEventTouchUpInside];
    [self->_bottomView addSubview:artistButton];
    
    //Play Button
    self.playButton = [[UILabel alloc] initWithFrame:CGRectMake(self->_bottomView.frame.size.width / 2 - 30, 170, 60, 60)];
    self.playButton.font = [UIFont fontWithName:kFontAwesomeFamilyName size:60];
    self.playButton.text = [NSString fontAwesomeIconStringForEnum:FAPause];
    self.playButton.textColor = [UIColor colorWithRed:0.016 green:0.850 blue:0.796 alpha:1];
    [self->_bottomView addSubview:self.playButton];
    
    //Button
    UIButton *play = [[UIButton alloc] initWithFrame:self.playButton.frame];
    [play addTarget:self action:@selector(playPauseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self->_bottomView addSubview:play];
    
    [self setTabBarVisible:![self tabBarIsVisible] animated:YES completion:^(BOOL finished) {
        NSLog(@"finished");
    }];
    
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (IBAction)playPauseButton:(id)sender {
    
    if([self.playButton.text isEqualToString:[NSString fontAwesomeIconStringForEnum:FAPlayCircle]]){
        self.playButton.text = [NSString fontAwesomeIconStringForEnum:FAPause];
        //YouTube
        if(self.playerInteger == 0){
            [self.player playVideo];
        }
        //SoundCloud
        else if(self.playerInteger == 1){
            [self.playerVC play];
        }
        //Facebook
        else if(self.playerInteger == 2){
            [self.facebookPlayer play];
        }
        //Instagram
        else if(self.playerInteger == 3){
            [self.facebookPlayer play];
        }
    }
    else{
        self.playButton.text = [NSString fontAwesomeIconStringForEnum:FAPlayCircle];
        //YouTube
        if(self.playerInteger == 0){
            [self.player pauseVideo];
        }
        //SoundCloud
        else if(self.playerInteger == 1){
            [self.playerVC pause];
        }
        //Facebook
        else if(self.playerInteger == 2){
            [self.facebookPlayer pause];
        }
        //Instagram
        else if(self.playerInteger == 3){
            [self.facebookPlayer pause];
        }
        
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

-(IBAction)shareToFacebook:(id)sender{
    APILinks *apiLinks = [[APILinks alloc] init];
    NSString *entityID = [[self.mediaContentDictionaryMutable objectForKey:@"content"] objectForKey:@"entity_id"];
    TabBarViewController *tabController = (TabBarViewController *)self.window.rootViewController;
    UINavigationController *navController = tabController.selectedViewController;
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]];
    //NSString *entityID = [[self.artistArray objectAtIndex:index] objectForKey:@"entity_id"];
    if (isInstalled) {
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/o/%@", [apiLinks callbackURL], entityID]];
        [FBSDKShareDialog showFromViewController:navController
                                     withContent:content
                                        delegate:nil];
        
    }
    else{
        [self minimizeView];
    }
}

-(IBAction)shareToTwitter:(id)sender{
    APILinks *apiLinks = [[APILinks alloc] init];
    NSString *entityID = [[self.mediaContentDictionaryMutable objectForKey:@"content"] objectForKey:@"entity_id"];
    TabBarViewController *tabController = (TabBarViewController *)self.window.rootViewController;
    UINavigationController *navController = tabController.selectedViewController;
    
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    //NSString *entityID = [[self.artistArray objectAtIndex:index] objectForKey:@"entity_id"];
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    [composer setText:[NSString stringWithFormat:@"%@/o/%@", [apiLinks callbackURL], entityID]];
    //[composer setImage:[UIImage imageNamed:@"twitterkit"]];
    
    // Called from a UIViewController
    [composer showFromViewController:navController completion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            NSLog(@"Tweet composition cancelled");
        }
        else {
            NSLog(@"Sending Tweet!");
        }
    }];
}

-(IBAction)randomButtonAction:(id)sender{
    AppColors *appColors = [[AppColors alloc] init];
    
    if([sender currentTitleColor] == [UIColor whiteColor]){
        [sender setTitleColor:[appColors mainColor] forState:UIControlStateNormal];
        self.shuffleMedia = YES;
    }
    else{
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.shuffleMedia = NO;
    }
    
}

-(IBAction)repeatButtonAction:(id)sender{
    AppColors *appColors = [[AppColors alloc] init];
    
    if([sender currentTitleColor] == [UIColor whiteColor]){
        [sender setTitleColor:[appColors mainColor] forState:UIControlStateNormal];
        self.repeatMedia = YES;
    }
    else{
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.repeatMedia = NO;
    }
}

// pass a param to describe the state change, an animated flag and a completion block matching UIView animations completion
- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    
    // bail if the current state matches the desired state
    if ([self tabBarIsVisible] == visible) return (completion)? completion(YES) : nil;
    
    // get a frame calculation ready
    CGRect frame = tabBarController.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;
    
    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        self->tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    } completion:completion];
}

//Getter to know the current state
- (BOOL)tabBarIsVisible {
    return tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.frame);
}

//An illustration of a call to toggle current state
- (IBAction)pressedButton:(id)sender {
    [self setTabBarVisible:![self tabBarIsVisible] animated:YES completion:^(BOOL finished) {
        NSLog(@"finished");
    }];
}

-(NSString *)timeFormatted:(int)totalSeconds{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds /60) % 60;
    
    return [NSString stringWithFormat:@"%01d:%02d",minutes, seconds];
}

-(IBAction)openArtistProfile:(id)sender{
    [self minimizeView];
    TabBarViewController *tabController = (TabBarViewController *)self.window.rootViewController;
    UINavigationController *navController = tabController.selectedViewController;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    OverviewHotBoxViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"OverviewHotBox"];
    vc.userID = [[self.mediaContentDictionaryMutable objectForKey:@"user"] objectForKey:@"id"];
    [navController pushViewController:vc animated:YES];
}

-(IBAction)voteForEntry:(id)sender{
    APILinks *apiLinks = [[APILinks alloc] init];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *userDataRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *userDataEntity = [NSEntityDescription entityForName:@"UserData" inManagedObjectContext:managedObjectContext];
    [userDataRequest setEntity:userDataEntity];
    NSError *userDataError = nil;
    NSArray *userDataArray = [managedObjectContext executeFetchRequest:userDataRequest error:&userDataError];
    self.userDataArray = [userDataArray mutableCopy];
    self.userDictionary = [[[[self.userDataArray valueForKey:@"userData"] objectAtIndex:0] objectForKey:@"data"] objectAtIndex:0];
    self.entityIDString = [[self.userDictionary objectForKey:@"id"] stringValue];
    
    [sender setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:18]];
    [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sender setTitle:[NSString stringWithFormat:@"%@ Voted", [NSString fontAwesomeIconStringForEnum:FACheckCircle]] forState:UIControlStateNormal];
    
    //Fetch Token
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmailToken" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *tokenArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSString *tokenString = [[tokenArray valueForKey:@"tokenString"] objectAtIndex:0];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", tokenString] forHTTPHeaderField:@"Authorization"];
    
    NSString *entryID = [[[self.mediaContentDictionaryMutable objectForKey:@"content"] objectForKey:@"entry"] objectForKey:@"id"];
    
    NSString *voteUrlString = [NSString stringWithFormat:@"%@contests/%@/entries/%@/vote", [apiLinks apiURL], self.entityIDString, entryID];

    self.votedBool = TRUE;
    
    [manager POST:voteUrlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"%@", operation.responseString);
    }];
}

- (void)minimizeView
{
    if (!isLarge) return;
    
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.maximumAllowedHeight);

    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        CGAffineTransform first = CGAffineTransformMakeScale(0.5, 0.5);
        CGPoint destination;
        double percent = 0;
        
        percent = self.frame.size.height * 0.70;
        destination = CGPointMake(self.frame.size.width * 0.25, percent);
        
        destination = CGPointMake(self.frame.size.width * 0.25, percent);
        
        CGAffineTransform second = CGAffineTransformTranslate(self.transform, destination.x, destination.y);
        
        CGAffineTransform combo = CGAffineTransformConcat(first, second);
        self.transform = combo;
        self.bottomView.alpha = 0;
        
        
    } completion:^(BOOL finished) {
        self.bottomView.hidden = YES;
        self->isLarge = NO;
        
    }];
    
}

@end
