#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "WebViewAccountViewController.h"
@import GoogleSignIn;

@interface SocialAccountsViewController : UIViewController<UIWebViewDelegate, UIAlertViewDelegate, UIViewControllerTransitioningDelegate, SocialAccountAuthDelegate, GIDSignInDelegate, GIDSignInUIDelegate>{
    NSMutableData *receivedData;
}

@property int authenticationInt;
@property (strong, nonatomic) NSMutableDictionary *userDictionary;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSString *accountType;
@property (strong, nonatomic) NSString *urlStringAccount;
@property (strong, nonatomic) NSMutableArray *userDataArray;
@property (strong, nonatomic) NSString *websiteString;

//Labels
@property (strong, nonatomic) IBOutlet UILabel *websiteIcon;
@property (strong, nonatomic) IBOutlet UILabel *facebookIcon;
@property (strong, nonatomic) IBOutlet UILabel *facebookPageIcon;
@property (strong, nonatomic) IBOutlet UILabel *twitterIcon;
@property (strong, nonatomic) IBOutlet UILabel *instagramIcon;
@property (strong, nonatomic) IBOutlet UILabel *youtubeIcon;
@property (strong, nonatomic) IBOutlet UILabel *soundcloudIcon;
@property (strong, nonatomic) IBOutlet UILabel *vevoIcon;

//Checkmarks
@property (strong, nonatomic) UILabel *facebookCheckmark;
@property (strong, nonatomic) UILabel *twitterCheckmark;
@property (strong, nonatomic) UILabel *instagramCheckmark;
@property (strong, nonatomic) UILabel *soundcloudCheckmark;
@property (strong, nonatomic) UILabel *youtubeCheckmark;
@property (strong, nonatomic) UILabel *vevoCheckmark;
@property (strong, nonatomic) UILabel *websiteCheckmark;

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) UIWebView *facebookWebview;
@property (strong, nonatomic) UIWebView *twitterWebView;
@property (strong, nonatomic) UIWebView *instagramWebView;
@property (strong, nonatomic) UIWebView *soundcloudView;
@property (strong, nonatomic) UIWebView *youtubeView;
@property (nonatomic, retain) NSString *isLogin;
@property (assign, nonatomic) Boolean isReader;
@property (strong, nonatomic) NSString *socialMedia;

//Switch
@property (strong, nonatomic) UISwitch *facebookSwitch;
@property (strong, nonatomic) UISwitch *facebookPageSwitch;
@property (strong, nonatomic) UISwitch *twitterSwitch;
@property (strong, nonatomic) UISwitch *instagramSwitch;
@property (strong, nonatomic) UISwitch *youtubeSwitch;
@property (strong, nonatomic) UISwitch *youtubeVevoSwitch;
@property (strong, nonatomic) UISwitch *soundcloudSwitch;
@property (strong, nonatomic) UISwitch *websiteSwitch;

//BOOLS
@property BOOL facebookPageBool;
@property BOOL facebookAccountBool;
@property BOOL twitterBool;
@property BOOL youtubeBool;
@property BOOL vevoBool;
@property BOOL instagramBool;
@property BOOL soundcloudBool;
@property BOOL websiteBool;

@end
