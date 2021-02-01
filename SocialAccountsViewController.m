#import "SocialAccountsViewController.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import "AppColors.h"
#import "ScreenSizes.h"
#import "AFNetworking.h"
#import "APILinks.h"
#import "APIKeys.h"
#import "ErrorAlertView.h"

@interface SocialAccountsViewController ()

@end

@implementation SocialAccountsViewController

-(void)socialAuthenticationBool:(BOOL)socialAuthBool andSocialAuth:(NSString *)socialAuthString{
    if([self.socialMedia isEqualToString:@"facebook"]){
        if(socialAuthBool){
            self.facebookSwitch.on = YES;
        }
        else{
            self.facebookSwitch.on = NO;
        }
    }
    else if([self.socialMedia isEqualToString:@"twitter"]){
        if(socialAuthBool){
            self.twitterSwitch.on = YES;
        }
        else{
            self.twitterSwitch.on = NO;
        }
    }
    else if([self.socialMedia isEqualToString:@"instagram"]){
        if(socialAuthBool){
            self.instagramSwitch.on = YES;
        }
        else{
            self.instagramSwitch.on = NO;
        }
    }
    else if([self.socialMedia isEqualToString:@"youtube"]){
        if(socialAuthBool){
            self.youtubeSwitch.on = YES;
        }
        else{
            self.youtubeSwitch.on = NO;
        }
    }
    else if([self.socialMedia isEqualToString:@"youtubeVevo"]){
        if(socialAuthBool){
            self.youtubeVevoSwitch.on = YES;
        }
        else{
            self.youtubeVevoSwitch.on = NO;
        }
    }
    else if([self.socialMedia isEqualToString:@"soundcloud"]){
        if(socialAuthBool){
            self.soundcloudSwitch.on = YES;
        }
        else{
            self.soundcloudSwitch.on = NO;
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    APILinks *apiLinks = [[APILinks alloc] init];
    
    //Fetch Token
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmailToken" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *tokenArray = [managedObjectContext executeFetchRequest:request error:&error];
    NSString *tokenString = [[tokenArray valueForKey:@"tokenString"] objectAtIndex:0];
    
    AFHTTPRequestOperationManager *managerTwo = [AFHTTPRequestOperationManager manager];
    managerTwo.responseSerializer = [AFJSONResponseSerializer serializer];
    managerTwo.requestSerializer = [AFJSONRequestSerializer serializer];
    [managerTwo.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",tokenString] forHTTPHeaderField:@"Authorization"];
    [managerTwo.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [managerTwo.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSString *URLString = [apiLinks userAuthentication];
    
    [managerTwo GET:URLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        
        NSError *error = nil;
        //Get User Data
        NSFetchRequest *dataFetchUser = [[NSFetchRequest alloc] init];
        [dataFetchUser setEntity:[NSEntityDescription entityForName:@"UserData" inManagedObjectContext:managedObjectContext]];
        [dataFetchUser setIncludesPropertyValues:NO]; //only fetch the managedObjectID
        
        NSArray *carsData = [managedObjectContext executeFetchRequest:dataFetchUser error:&error];
        //error handling goes here
        for (NSManagedObject *car in carsData) {
            [managedObjectContext deleteObject:car];
        }
        NSError *saveError = nil;
        [managedObjectContext save:&saveError];
        
        
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSManagedObject *newData = [NSEntityDescription insertNewObjectForEntityForName:@"UserData" inManagedObjectContext:managedObjectContext];
        [newData setValue:responseObject forKey:@"userData"];
        
        if(![managedObjectContext save:&error]){
            NSLog(@"Cant Save! %@ %@", error, [error localizedDescription]);
        }
        
        //Fetch Dictionary
        NSFetchRequest *userDataRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *userDataEntity = [NSEntityDescription entityForName:@"UserData" inManagedObjectContext:managedObjectContext];
        [userDataRequest setEntity:userDataEntity];
        NSError *userDataError = nil;
        NSArray *userDataArray = [managedObjectContext executeFetchRequest:userDataRequest error:&userDataError];
        self.userDataArray = [userDataArray mutableCopy];
        self.userDictionary = [[[[self.userDataArray valueForKey:@"userData"] objectAtIndex:0] objectForKey:@"data"] objectAtIndex:0];
        NSLog(@"%@", self.userDictionary);
        
        BOOL facebookPage = [[[self.userDictionary objectForKey:@"facebook"] objectForKey:@"authenticated"] boolValue];
        BOOL twitter = [[[self.userDictionary objectForKey:@"twitter"] objectForKey:@"authenticated"] boolValue];
        BOOL instagram = [[[self.userDictionary objectForKey:@"instagram"] objectForKey:@"authenticated"] boolValue];
        BOOL youtube = [[[self.userDictionary objectForKey:@"youtube"] objectForKey:@"authenticated"] boolValue];
        BOOL vevo = [[[self.userDictionary objectForKey:@"vevo"] objectForKey:@"authenticated"] boolValue];
        BOOL soundcloud = [[[self.userDictionary objectForKey:@"soundcloud"] objectForKey:@"authenticated"] boolValue];
        
        if(facebookPage){
            self.facebookPageSwitch.on = YES;
        }
        else{
            self.facebookPageSwitch.on = NO;
        }
        
        if(twitter){
            self.twitterSwitch.on = YES;
        }
        else{
            self.twitterSwitch.on = NO;
        }
        
        if(instagram){
            self.instagramSwitch.on = YES;
        }
        else{
            self.instagramSwitch.on = NO;
        }
        
        if(youtube){
            self.youtubeSwitch.on = YES;
        }
        else{
            self.youtubeSwitch.on = NO;
        }
        
        if(vevo){
            self.youtubeVevoSwitch.on = YES;
        }
        else{
            self.youtubeVevoSwitch.on = NO;
        }
        
        if(soundcloud){
            self.soundcloudSwitch.on = YES;
        }
        else{
            self.soundcloudSwitch.on = NO;
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppColors *appColors = [[AppColors alloc] init];
    self.view.backgroundColor = [UIColor blackColor];
    NSLog(@"%@", self.userDictionary);

self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:self.scrollView];
        
        //Top Label
        UILabel *syncLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, self.view.frame.size.width, 30)];
        syncLabel.font = [UIFont fontWithName:@"Runda-Italic" size:14];
        syncLabel.textColor = [UIColor whiteColor];
        syncLabel.textAlignment = NSTextAlignmentCenter;
        syncLabel.numberOfLines = 2;
        [self.scrollView addSubview:syncLabel];
        
        //Get Charted Label
        UILabel *getChartedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 50)];
        getChartedLabel.font = [UIFont fontWithName:@"Runda-Bold" size:16];
        getChartedLabel.textColor = [UIColor whiteColor];
        getChartedLabel.textAlignment = NSTextAlignmentCenter;
        getChartedLabel.text = @"CONNECT YOUR SOCIAL ACCOUNTS";
        [self.scrollView addSubview:getChartedLabel];
        
        UIView *facebookPageWhiteView = [[UIView alloc] initWithFrame:CGRectMake(10, 136, 25, 26)];
        facebookPageWhiteView.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:facebookPageWhiteView];
        
        self.facebookPageIcon = [[UILabel alloc] initWithFrame:CGRectMake(5, 130, 35, 35)];
        self.facebookPageIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:35];
        self.facebookPageIcon.textColor = [UIColor colorWithRed:0.231 green:0.349 blue:0.596 alpha:1];
        [self iPhoneSixPlus:self.facebookPageIcon];
        self.facebookPageIcon.text = [NSString fontAwesomeIconStringForEnum:FAFacebookSquare];
        [self.scrollView addSubview:self.facebookPageIcon];
        
        UILabel *facebookPageLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 135, 150, 25)];
        facebookPageLabel.font = [UIFont fontWithName:@"Runda" size:18];
        facebookPageLabel.textColor = [UIColor whiteColor];
        facebookPageLabel.text = @"Facebook Page";
        [self.scrollView addSubview:facebookPageLabel];
        
        self.facebookPageSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(350, 135, 30, 10)];
        if(self.facebookPageBool){
            self.facebookPageSwitch.on = YES;
        }
        else{
            self.facebookPageSwitch.on = NO;
        }
        self.facebookPageSwitch.onTintColor = [appColors mainColor];
        [self.facebookPageSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.scrollView addSubview:self.facebookPageSwitch];
        
        UIView *twitterWhiteView = [[UIView alloc] initWithFrame:CGRectMake(10, 186, 25, 26)];
        twitterWhiteView.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:twitterWhiteView];
        
        self.twitterIcon = [[UILabel alloc] initWithFrame:CGRectMake(5, 180, 35, 35)];
        self.twitterIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:35];
        self.twitterIcon.textColor = [appColors twitterColor];
        [self iPhoneSixPlus:self.twitterIcon];
        self.twitterIcon.text = [NSString fontAwesomeIconStringForEnum:FATwitterSquare];
        [self.scrollView addSubview:self.twitterIcon];
        
        UILabel *twitterLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 185, 150, 25)];
        twitterLabel.font = [UIFont fontWithName:@"Runda" size:18];
        twitterLabel.textColor = [UIColor whiteColor];
        twitterLabel.text = @"Twitter Account";
        [self.scrollView addSubview:twitterLabel];
        
        self.twitterSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(350, 185, 30, 10)];
        if(self.twitterBool){
            self.twitterSwitch.on = YES;
        }
        else{
            self.twitterSwitch.on = NO;
        }
        self.twitterSwitch.onTintColor = [appColors mainColor];
        [self.twitterSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.scrollView addSubview:self.twitterSwitch];
        
        UIView *instagramWhiteView = [[UIView alloc] initWithFrame:CGRectMake(9, 235, 25, 26)];
        instagramWhiteView.backgroundColor = [UIColor whiteColor];
        //[self.scrollView addSubview:instagramWhiteView];
        
        self.instagramIcon = [[UILabel alloc] initWithFrame:CGRectMake(5, 230, 32, 32)];
        self.instagramIcon.font = [UIFont fontWithName:@"New-Instagram" size:32];
        self.instagramIcon.textColor = [UIColor whiteColor];
        [self iPhoneSixPlus:self.instagramIcon];
        self.instagramIcon.text = @"~";
        [self.scrollView addSubview:self.instagramIcon];
        
        UILabel *instagramLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 235, 150, 25)];
        instagramLabel.font = [UIFont fontWithName:@"Runda" size:18];
        instagramLabel.textColor = [UIColor whiteColor];
        instagramLabel.text = @"Instagram Account";
        [self.scrollView addSubview:instagramLabel];
        
        self.instagramSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(350, 235, 30, 10)];
        if(self.instagramBool){
            self.instagramSwitch.on = YES;
        }
        else{
            self.instagramSwitch.on = NO;
        }
        self.instagramSwitch.onTintColor = [appColors mainColor];
        [self.instagramSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.scrollView addSubview:self.instagramSwitch];
        
        UIView *youtubeWhiteView = [[UIView alloc] initWithFrame:CGRectMake(9, 284, 25, 26)];
        youtubeWhiteView.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:youtubeWhiteView];
        
        self.youtubeIcon = [[UILabel alloc] initWithFrame:CGRectMake(5, 280, 35, 35)];
        self.youtubeIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:35];
        self.youtubeIcon.textColor = [appColors youTubeColor];
        [self iPhoneSixPlus:self.youtubeIcon];
        self.youtubeIcon.text = [NSString fontAwesomeIconStringForEnum:FAYoutubeSquare];
        [self.scrollView addSubview:self.youtubeIcon];
        
        UILabel *youtubeLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 285, 150, 25)];
        youtubeLabel.font = [UIFont fontWithName:@"Runda" size:18];
        youtubeLabel.textColor = [UIColor whiteColor];
        youtubeLabel.text = @"YouTube Account";
        [self.scrollView addSubview:youtubeLabel];
        
        self.youtubeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(350, 285, 30, 10)];
        if(self.youtubeBool){
            self.youtubeSwitch.on = YES;
        }
        else{
            self.youtubeSwitch.on = NO;
        }
        self.youtubeSwitch.onTintColor = [appColors mainColor];
        [self.youtubeSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.scrollView addSubview:self.youtubeSwitch];
        
        self.vevoIcon = [[UILabel alloc] initWithFrame:CGRectMake(5, 330, 35, 35)];
        self.vevoIcon.font = [UIFont fontWithName:@"untitled-font-1" size:35];
        self.vevoIcon.textColor = [appColors youTubeColor];
        [self iPhoneSixPlus:self.vevoIcon];
        self.vevoIcon.text = @"a";
        [self.scrollView addSubview:self.vevoIcon];
        
        UILabel *vevoLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 335, 150, 25)];
        vevoLabel.font = [UIFont fontWithName:@"Runda" size:18];
        vevoLabel.textColor = [UIColor whiteColor];
        vevoLabel.text = @"Vevo Account";
        [self.scrollView addSubview:vevoLabel];
        
        self.youtubeVevoSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(350, 335, 30, 10)];
        if(self.vevoBool){
            self.youtubeVevoSwitch.on = YES;
        }
        else{
            self.youtubeVevoSwitch.on = NO;
        }
        self.youtubeVevoSwitch.onTintColor = [appColors mainColor];
        [self.youtubeVevoSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.scrollView addSubview:self.youtubeVevoSwitch];
        
        self.soundcloudIcon = [[UILabel alloc] initWithFrame:CGRectMake(5, 380, 35, 35)];
        self.soundcloudIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25];
        self.soundcloudIcon.textColor = [appColors soundcloudColor];
        [self iPhoneSixPlus:self.soundcloudIcon];
        self.soundcloudIcon.text = [NSString fontAwesomeIconStringForEnum:FAsoundcloud];
        [self.scrollView addSubview:self.soundcloudIcon];
        
        UILabel *soundcloudLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 385, 175, 25)];
        soundcloudLabel.font = [UIFont fontWithName:@"Runda" size:18];
        soundcloudLabel.textColor = [UIColor whiteColor];
        soundcloudLabel.text = @"Soundcloud Account";
        [self.scrollView addSubview:soundcloudLabel];
        
        self.soundcloudSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(350, 385, 30, 10)];
        if(self.soundcloudBool){
            self.soundcloudSwitch.on = YES;
        }
        else{
            self.soundcloudSwitch.on = NO;
        }
        self.soundcloudSwitch.onTintColor = [appColors mainColor];
        [self.soundcloudSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.scrollView addSubview:self.soundcloudSwitch];
}

-(void)switchValueChanged:(UISwitch *)switchState{
    
    if(switchState == self.facebookPageSwitch){
        if([switchState isOn]){
            self.socialMedia = @"facebook";
            [self addFacebookAccount];
            
        }
        else{
            NSLog(@"OFF");
            [self removeFacebookPage];
        }
    }
    else if(switchState == self.twitterSwitch){
        if([switchState isOn]){
            [self addTwitterAccount];
        }
        else{
            NSLog(@"OFF");
            [self removeTwitterAccount];
        }
    }
    else if(switchState == self.instagramSwitch){
        if([switchState isOn]){
            self.socialMedia = @"instagram";
            [self addInstagramAccount];
        }
        else{
            NSLog(@"OFF");
            self.socialMedia = @"instagram";
            [self removeInstagramAccount];
        }
    }
    else if(switchState == self.youtubeSwitch){
        if([switchState isOn]){
            self.socialMedia = @"youtube";
            [self addYoutubeAccount];
        }
        else{
            NSLog(@"OFF");
            [self removeYoutubeAccount];
        }
    }
    else if(switchState == self.youtubeVevoSwitch){
        if([switchState isOn]){
            self.socialMedia = @"youtubeVevo";
            [self addYoutubeAccount];
        }
        else{
            NSLog(@"OFF");
            [self removeYoutubeAccount];
        }
    }
    else if(switchState == self.soundcloudSwitch){
        if([switchState isOn]){
            self.socialMedia = @"soundcloud";
            [self addSoundcloudAccount];
        }
        else{
            NSLog(@"OFF");
            [self removeSoundcloudAccount];
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

-(void)addTwitterAccount{
    APILinks *apiLinks = [[APILinks alloc] init];
    self.authenticationInt = 1;
    self.socialMedia = @"twitter";
    NSString *twitterClientID = twitter;
    NSString *scope = @"public_profile";
    NSString *redirectURI = [NSString stringWithFormat:@"%@/",[apiLinks callbackURL]];
    self.urlStringAccount = [NSString stringWithFormat:@"https://www.twitter.com/dialog/oauth?client_id=%@&redirect_uri=%@&scope=%@&response_type=code", twitterClientID, redirectURI, scope];
    [self performSegueWithIdentifier:@"ToWebViewAccount" sender:self];
}

-(void)removeTwitterAccount{
    APILinks *apiLinks = [[APILinks alloc] init];
    
    //Fetch Token
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmailToken" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *tokenArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSString *tokenString = [[tokenArray valueForKey:@"tokenString"] objectAtIndex:0];
    
    NSString *urlString = [NSString stringWithFormat:@"%@twiiter", [apiLinks unlinkAuthenication]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", tokenString] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [manager DELETE:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"%@",operation.responseString);
    }];
}

-(void)addFacebookAccount{
    APILinks *apiLinks = [[APILinks alloc] init];
    self.authenticationInt = 1;
    self.socialMedia = @"facebook";
    NSString *facebookClientID = facebook;
    NSString *scope = @"public_profile+manage_pages+publish_actions";
    NSString *redirectURI = [NSString stringWithFormat:@"%@/",[apiLinks callbackURL]];
    self.urlStringAccount = [NSString stringWithFormat:@"https://www.facebook.com/dialog/oauth?client_id=%@&redirect_uri=%@&scope=%@&response_type=code", facebookClientID, redirectURI, scope];
    [self performSegueWithIdentifier:@"ToWebViewAccount" sender:self];
}

-(void)removeFacebookAccount{
    APILinks *apiLinks = [[APILinks alloc] init];
    
    //Fetch Token
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmailToken" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *tokenArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSString *tokenString = [[tokenArray valueForKey:@"tokenString"] objectAtIndex:0];
    
    NSString *urlString = [NSString stringWithFormat:@"%@facebook", [apiLinks unlinkAuthenication]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", tokenString] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [manager DELETE:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"%@",operation.responseString);
    }];
}

-(void)removeFacebookPage{
    APILinks *apiLinks = [[APILinks alloc] init];
    
    //Fetch Token
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmailToken" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *tokenArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSString *tokenString = [[tokenArray valueForKey:@"tokenString"] objectAtIndex:0];
    
    NSString *urlString = [NSString stringWithFormat:@"%@facebook/pages", [apiLinks unlinkAuthenication]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", tokenString] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [manager DELETE:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"%@",operation.responseString);
    }];
}

-(void)addFacebookPage{
    self.authenticationInt = 1;
    APILinks *apiLinks = [[APILinks alloc] init];
    
    if(self.facebookAccountBool){
        //Fetch Token
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
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
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        NSString *urlString = [NSString stringWithFormat:@"%@auth/facebook/pages", [apiLinks apiURL]];
        
        [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
            NSLog(@"%@", responseObject);
        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
            NSLog(@"%@", operation.responseString);
        }];
    }
    else{
        self.socialMedia = @"facebook";
        NSString *facebookClientID = facebook;
        NSString *scope = @"public_profile+publish_actions";
        NSString *redirectURI = [NSString stringWithFormat:@"%@/",[apiLinks callbackURL]];
        
        self.facebookWebview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.facebookWebview.delegate = self;
       self.urlStringAccount = [NSString stringWithFormat:@"https://www.facebook.com/dialog/oauth?client_id=%@&redirect_uri=%@&scope=%@&response_type=code", facebookClientID, redirectURI, scope];
        NSLog(@"%@", self.urlStringAccount);
        [self performSegueWithIdentifier:@"ToWebViewAccount" sender:self];
    }
}

-(void)addInstagramAccount{
    APILinks *apiLinks = [[APILinks alloc] init];
    self.authenticationInt = 1;
    NSString *instagramClientID = instagram;
    NSString *instagramRedirectURI = [NSString stringWithFormat:@"%@",[apiLinks callbackURL]];
    NSString *scope = @"basic+likes+comments";
    
    self.urlStringAccount = [NSString stringWithFormat:@"https://api.instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&scope=%@&response_type=code", instagramClientID, instagramRedirectURI, scope];
    [self performSegueWithIdentifier:@"ToWebViewAccount" sender:self];
}

-(void)removeInstagramAccount{
    APILinks *apiLinks = [[APILinks alloc] init];
    
    //Fetch Token
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmailToken" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *tokenArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSString *tokenString = [[tokenArray valueForKey:@"tokenString"] objectAtIndex:0];
    
    NSString *urlString = [NSString stringWithFormat:@"%@instagram", [apiLinks unlinkAuthenication]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", tokenString] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [manager DELETE:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"%@",operation.responseString);
    }];
    
}

-(void)addSoundcloudAccount{
    APILinks *apiLinks = [[APILinks alloc] init];
    self.authenticationInt = 1;
    NSString *soundcloudClientID = @"6a98b83798ca4b2e83afee5191db33fe";
    NSString *soundcloudRedirectURI = [NSString stringWithFormat:@"%@",[apiLinks callbackURL]];
    self.urlStringAccount = [NSString stringWithFormat:@"https://soundcloud.com/connect?client_id=%@&redirect_uri=%@&response_type=code", soundcloudClientID, soundcloudRedirectURI];
    [self performSegueWithIdentifier:@"ToWebViewAccount" sender:self];
}

-(void)removeSoundcloudAccount{
    APILinks *apiLinks = [[APILinks alloc] init];
    
    //Fetch Token
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmailToken" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *tokenArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSString *tokenString = [[tokenArray valueForKey:@"tokenString"] objectAtIndex:0];
    
    NSString *urlString = [NSString stringWithFormat:@"%@soundcloud", [apiLinks unlinkAuthenication]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", tokenString] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [manager DELETE:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"%@",operation.responseString);
    }];
}

-(void)addYoutubeAccount{
    APILinks *apiLinks = [[APILinks alloc] init];
    self.authenticationInt = 1;
    NSString *youtubeClientID = youtube;
    NSString *redirectURL = [NSString stringWithFormat:@"%@",[apiLinks callbackURL]];
    NSString *scope = @"https://www.googleapis.com/auth/youtube";
    
    self.urlStringAccount = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=%@&redirect_uri=%@&scope=%@&approval_prompt=force&access_type=offline", youtubeClientID, redirectURL, scope];
    [self performSegueWithIdentifier:@"ToWebViewAccount" sender:self];
}

-(void)removeYoutubeAccount{
    APILinks *apiLinks = [[APILinks alloc] init];
    
    //Fetch Token
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmailToken" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *tokenArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSString *tokenString = [[tokenArray valueForKey:@"tokenString"] objectAtIndex:0];
    
    NSString *urlString = [NSString stringWithFormat:@"%@youtube", [apiLinks unlinkAuthenication]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", tokenString] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [manager DELETE:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"%@",operation.responseString);
    }];
}

//Loading the Web View here to streamline the process. Copied from Web View Controller. 

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    APILinks *apiLinks = [[APILinks alloc] init];
    
    if([self.socialMedia isEqualToString:@"facebook"]){
        NSLog(@"URLLRRLLRLRLR %@", [request URL]);
        if([[[request URL] host] isEqualToString:[NSString stringWithFormat:@"%@", [apiLinks hostURL]]]){
            NSString *verifier = nil;
            NSArray *urlParams = [[[request URL] query] componentsSeparatedByString:@"?"];
            
            for(NSString *params in urlParams){
                NSArray *keyValue = [params componentsSeparatedByString:@"="];
                NSString *key = [keyValue objectAtIndex:0];
                
                if([key isEqualToString:@"code"]){
                    verifier = [keyValue objectAtIndex:1];
                    NSLog(@"%@", verifier);
                    break;
                }
            }
            
            if(verifier){
                
                [self.facebookWebview removeFromSuperview];
                
                NSString *url = [apiLinks facebookAuthentication];
                
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                NSDictionary *params = @ {@"code":verifier};
                
                //Fetch Token
                NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmailToken" inManagedObjectContext:managedObjectContext];
                [request setEntity:entity];
                NSError *error = nil;
                NSArray *tokenArray = [managedObjectContext executeFetchRequest:request error:&error];
                
                NSString *tokenString = [[tokenArray valueForKey:@"tokenString"] objectAtIndex:0];
                [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",tokenString] forHTTPHeaderField:@"Authorization"];
                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                
                [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"JSON: %@", responseObject);
                    self.facebookSwitch.on = YES;
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", operation.responseString);
                    self.facebookSwitch.on = NO;
                }];
                
            }
            else{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Could not connect Social Media" message:@"Could not connect Facebook account. Please try again" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:@"Okay"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSLog(@"OK action");
                                               [self.facebookWebview removeFromSuperview];
                                               self.facebookSwitch.on = NO;
                                           }];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
                
                
            }
        }
    }
    /*
    else if([self.socialMedia isEqualToString:@"youtube"]){
        if([[[request URL] host] isEqualToString:[NSString stringWithFormat:@"%@", [apiLinks hostURL]]]){
            NSString *verifier = nil;
            NSArray *urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
            
            for(NSString *params in urlParams){
                NSArray *keyValue = [params componentsSeparatedByString:@"="];
                NSString *key = [keyValue objectAtIndex:0];
                
                if([key isEqualToString:@"code"]){
                    verifier = [keyValue objectAtIndex:1];
                    NSLog(@"%@", verifier);
                    break;
                }
            }
            
            if(verifier){
                [self.youtubeView removeFromSuperview];
                
                NSString *url = [apiLinks youtubeAuthentication];
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                NSDictionary *params = @{@"code":verifier};
                
                //Fetch Token
                NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmailToken" inManagedObjectContext:managedObjectContext];
                [request setEntity:entity];
                NSError *error = nil;
                NSArray *tokenArray = [managedObjectContext executeFetchRequest:request error:&error];
                
                NSString *tokenString = [[tokenArray valueForKey:@"tokenString"] objectAtIndex:0];
                [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",tokenString] forHTTPHeaderField:@"Authorization"];
                
                [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"JSON: %@", responseObject);
                    self.youtubeSwitch.on = YES;
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", operation.responseString);
                    self.youtubeSwitch.on = NO;
                }];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Could not connect Social Media" message:@"Could not connect Youtube account. Please try again" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                [alertView show];
                [self.youtubeView removeFromSuperview];
                self.youtubeSwitch.on = NO;
            }
        }
    }
     */
    else if([self.socialMedia isEqualToString:@"instagram"]){
        if([[[request URL] host] isEqualToString:[NSString stringWithFormat:@"%@", [apiLinks hostURL]]]){
            NSString *verifier = nil;
            NSArray *urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
            
            for(NSString *params in urlParams){
                NSArray *keyValue = [params componentsSeparatedByString:@"="];
                NSString *key = [keyValue objectAtIndex:0];
                
                if([key isEqualToString:@"code"]){
                    verifier = [keyValue objectAtIndex:1];
                    NSLog(@"%@", verifier);
                    break;
                }
            }
            if(verifier){
                [self.instagramWebView removeFromSuperview];
                
                //Send to server
                NSString *url = [apiLinks instagramAuthentication];
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                NSDictionary *params = @{@"code":verifier};
                //Fetch Token
                NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmailToken" inManagedObjectContext:managedObjectContext];
                [request setEntity:entity];
                NSError *error = nil;
                NSArray *tokenArray = [managedObjectContext executeFetchRequest:request error:&error];
                
                NSString *tokenString = [[tokenArray valueForKey:@"tokenString"] objectAtIndex:0];
                [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",tokenString] forHTTPHeaderField:@"Authorization"];
                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                
                [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"JSON: %@", responseObject);
                    self.instagramSwitch.on = YES;
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", operation.responseString);
                    self.instagramSwitch.on = NO;
                }];
            }
            else{
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Could not connect Social Media" message:@"Could not connect Instagram account. Please try again" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:@"Okay"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSLog(@"OK action");
                                               [self.instagramWebView removeFromSuperview];
                                               self.instagramSwitch.on = NO;
                                           }];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }
    else if([self.socialMedia isEqualToString:@"soundcloud"]){
        if([[[request URL] host] isEqualToString:[NSString stringWithFormat:@"%@", [apiLinks hostURL]]]){
            NSString *verifier = nil;
            NSArray *urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
            
            for(NSString *params in urlParams){
                NSArray *keyValue = [params componentsSeparatedByString:@"="];
                NSString *key = [keyValue objectAtIndex:0];
                
                if([key isEqualToString:@"code"]){
                    verifier = [keyValue objectAtIndex:1];
                    NSLog(@"%@", verifier);
                    break;
                }
            }
            
            if(verifier){
                [self.soundcloudView removeFromSuperview];
                
                //Send to Server
                NSString *url = [apiLinks soundcloudAuthentication];
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                NSDictionary *params = @{@"code":verifier};
                //Fetch Token
                NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmailToken" inManagedObjectContext:managedObjectContext];
                [request setEntity:entity];
                NSError *error = nil;
                NSArray *tokenArray = [managedObjectContext executeFetchRequest:request error:&error];
                
                NSString *tokenString = [[tokenArray valueForKey:@"tokenString"] objectAtIndex:0];
                [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",tokenString] forHTTPHeaderField:@"Authorization"];
                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                
                [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"JSON: %@", responseObject);
                    self.soundcloudSwitch.on = YES;
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", operation.responseString);
                    self.soundcloudSwitch.on = NO;
                }];
            }
            else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Could not connect Social Media" message:@"Could not connect Soundcloud account. Please try again" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:@"Okay"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSLog(@"OK action");
                                               [self.soundcloudView removeFromSuperview];
                                               self.soundcloudSwitch.on = NO;
                                           }];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }
    else if([self.socialMedia isEqualToString:@"youtubeVevo"]){
        if([[[request URL] host] isEqualToString:[NSString stringWithFormat:@"%@", [apiLinks hostURL]]]){
            NSString *verifier = nil;
            NSArray *urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
            
            for(NSString *params in urlParams){
                NSArray *keyValue = [params componentsSeparatedByString:@"="];
                NSString *key = [keyValue objectAtIndex:0];
                
                if([key isEqualToString:@"code"]){
                    verifier = [keyValue objectAtIndex:1];
                    NSLog(@"%@", verifier);
                    break;
                }
            }
            
            if(verifier){
                [self.youtubeView removeFromSuperview];
                NSString *url = [apiLinks vevoAuthentication];
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                NSDictionary *params = @{@"code":verifier};
                
                //Fetch Token
                NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmailToken" inManagedObjectContext:managedObjectContext];
                [request setEntity:entity];
                NSError *error = nil;
                NSArray *tokenArray = [managedObjectContext executeFetchRequest:request error:&error];
                
                NSString *tokenString = [[tokenArray valueForKey:@"tokenString"] objectAtIndex:0];
                [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",tokenString] forHTTPHeaderField:@"Authorization"];
                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                
                [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"JSON: %@", responseObject);
                    self.youtubeVevoSwitch.on = YES;
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", operation.responseString);
                    self.youtubeVevoSwitch.on = NO;
                }];
                
            }
            else{
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Could not connect Social Media" message:@"Could not connect Vevo account. Please try again" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:@"Okay"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSLog(@"OK action");
                                               [self.youtubeView removeFromSuperview];
                                               self.youtubeVevoSwitch.on = NO;
                                           }];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }
    return YES;
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data

{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", error] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"Okay"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                               }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    // ERROR!
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"ToWebViewAccount"]){
        WebViewAccountViewController *vc = (WebViewAccountViewController *)[segue.destinationViewController topViewController];
        vc.urlString = self.urlStringAccount;
        vc.socialMedia = self.socialMedia;
        vc.myDelegate = self;
    }
}


@end
