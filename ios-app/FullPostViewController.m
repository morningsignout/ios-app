//
//  FullPostViewController.m
//  ios-app
//
//  Created by Shannon Phu on 9/6/15.
//  Copyright (c) 2015 Morning Sign Out Incorporated. All rights reserved.
//

#import "FullPostViewController.h"
#import "Post.h"
#import "ExternalLinksWebViewController.h"
#import "ImageViewController.h"
#import <AFNetworking.h>
#import <CoreData/CoreData.h>
#import "CDPost.h"
#import "ArticleLabels.h"
#import "Constants.h"
#import "PostHeaderInfo.h"
#include "AuthorViewController.h"
#import "AppDelegate.h"

static NSString * const header = @"<!-- Latest compiled and minified CSS --><link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css\"><!-- Optional theme --><link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css\"><!-- Latest compiled and minified JavaScript --><script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js\"></script><!-- Yeon's CSS --><link rel=\"stylesheet\" href=\"http://morningsignout.com/wp-content/themes/mso/style.css?ver=4.3\"><meta charset=\"utf-8\"> \
    <style type=\"text/css\">.ssba {}.ssba img { width: 30px !important; padding: 0px; border:  0; box-shadow: none !important; display: inline !important; vertical-align: middle; } .ssba, .ssba a {text-decoration:none;border:0;background: none;font-family: Indie Flower;font-size: 20px;}</style><div style=\"padding:5px;background-color:white;box-shadow:none;\"></div>";

static const CGFloat initialWebViewYOffset = 450;

@interface FullPostViewController () <UIWebViewDelegate, UIScrollViewDelegate> {
    NSString *fontSizeStyle;
    float mainFontSize;
    float captionFontSize;
    bool scrolled, loaded;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *html;
@property (strong, nonatomic) NSArray *font;
@property (weak, nonatomic) IBOutlet PostHeaderInfo *header;
@property (nonatomic) CGFloat lastContentOffset;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (nonatomic, strong) AppDelegate *delegate;

@end

@implementation FullPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    self.webView.translatesAutoresizingMaskIntoConstraints = YES;
    [self setupNavigationBarStyle];
    
    [self.header.coverImage setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapCoverImageRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCoverImage:)];
    [self.header.coverImage addGestureRecognizer:tapCoverImageRecognizer];
    
    [self.header.articleLabels.authorLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapAuthorRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedAuthor:)];
    [self.header.articleLabels.authorLabel addGestureRecognizer:tapAuthorRecognizer];
    
    _delegate = [[UIApplication sharedApplication] delegate];
    
    // Retrieve user font size preference if was previously saved
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Font"];
    self.font = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if (self.font.firstObject) {
        NSNumber *numberFormatFloat = [self.font.firstObject valueForKey:@"mainSize"];
        mainFontSize = [numberFormatFloat floatValue];
        numberFormatFloat = [self.font.firstObject valueForKey:@"captionSize"];
        captionFontSize = [numberFormatFloat floatValue];
    } else {
        mainFontSize = 1.5;
        captionFontSize = 1.2;
    }
    
    [self setUpLabels];
    
    NSString *filteredHTML = [self.post.body stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    filteredHTML = [filteredHTML stringByReplacingOccurrencesOfString:@"\"" withString:@"\""];
    NSString *containerFront = @"<div class=\"container\">";
    NSString *containerEnd = @"</div>";
    filteredHTML = [containerFront stringByAppendingString:filteredHTML];
    filteredHTML = [filteredHTML stringByAppendingString:containerEnd];
    filteredHTML = [header stringByAppendingString:filteredHTML];
    self.html = filteredHTML;
    
    [self loadWebView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self loadPostImage];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.header.coverImage.image = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavigationBarStyle {
    [self.navigationController.navigationBar setBarTintColor:[UIColor kNavBackgroundColor]];
    self.navigationController.navigationBar.tintColor = [UIColor kNavTextColor];
    
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];
    UIBarButtonItem *bookmarkItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(bookmarkPost)];
    UIBarButtonItem *fontIncItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(increaseFontSize)];
    UIBarButtonItem *fontDecItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(decreaseFontSize)];
    
    NSArray *actionButtonItems = @[shareItem, bookmarkItem, fontIncItem, fontDecItem];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
}

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    if ([self.delegate performSelector:@selector(managedObjectContext)]) {
        context = [self.delegate managedObjectContext];
    }
    return context;
}

- (void)loadPostImage {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.post.fullCoverImageURL]];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIImage *image = responseObject;
        self.header.coverImage.image = image;
        self.header.coverImage.contentMode = UIViewContentModeScaleAspectFill;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Image error: %@", error);
    }];
    [requestOperation start];
}

- (void)setUpLabels {
    //UIColor *blue = [UIColor colorWithRed:0.125 green:0.498 blue:0.722 alpha:1];          // from website
    UIColor *blue = [UIColor colorWithRed:0.11 green:0.38 blue:0.541 alpha:1];              // darker version
    UIColor *lighterblue = [UIColor colorWithRed:0.388 green:0.698 blue:0.898 alpha:1];     // from website
    //UIColor *lighterblue = [UIColor colorWithRed:0.29 green:0.573 blue:0.757 alpha:1];    // darker version
    
    self.header.articleLabels.frame = CGRectMake(0, self.header.coverImage.frame.size.height + 70, self.view.frame.size.width, 150);
    [self.header.articleLabels setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.75]];
    
    self.header.articleLabels.titleLabel.text = self.post.title;
    [self.header.articleLabels.titleLabel setTextColor:blue];
    
    self.header.articleLabels.dateLabel.text = self.post.date;
    [self.header.articleLabels.dateLabel setTextColor:blue];
    
    self.header.articleLabels.categoriesLabel.text = [self.post.category componentsJoinedByString:@", "];
    [self.header.articleLabels.categoriesLabel setTextColor:[UIColor whiteColor]];
    [self.header.articleLabels.categoriesLabel setBackgroundColor:lighterblue];
    
    self.header.articleLabels.tagsLabel.text = [self.post.tags componentsJoinedByString:@", "];
    [self.header.articleLabels.tagsLabel setTextColor:blue];
    
    // add underline to authorlabel text by making it a NSMutableAttributeString
    NSString *author = self.post.author.name;
    NSMutableAttributedString *uAuthor = [[NSMutableAttributedString alloc] initWithString:author];
    
    [uAuthor addAttributes:@{
                             NSUnderlineColorAttributeName : blue,
                             NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid),
                             }
                     range:NSMakeRange(0, uAuthor.length)];
    
    [self.header.articleLabels.authorLabel setAttributedText:uAuthor];
    [self.header.articleLabels.authorLabel setTextColor:blue];
}

- (NSString *)setFontSize {
    fontSizeStyle = [NSString stringWithFormat:@"<script> \
                     var all = document.getElementsByTagName(\"p\"); \
                     for (var i = 0; i < all.length; i++) { \
                     var par = all[i]; \
                     par.style.fontSize = '%frem'; \
                     } \
                     \
                     var captions = document.getElementsByTagName(\"figcaption\"); \
                     for (var i = 0; i < captions.length; i++) { \
                     var caption = captions[i]; \
                     caption.style.fontSize = '%frem'; \
                     } \
                     </script>", mainFontSize, captionFontSize];
    return fontSizeStyle;
}

#pragma mark - Web View Functions

- (void)loadWebView {
    NSString *filteredHTML = [self.html stringByAppendingString:[self setFontSize]];
    [self.webView loadHTMLString:filteredHTML baseURL:nil];
    self.webView.frame = CGRectMake(0, initialWebViewYOffset, self.view.frame.size.width, self.view.frame.size.height - initialWebViewYOffset);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked ) {
        NSString *urlToOpen = [NSString stringWithFormat:@"%@",request.URL];
        NSURL* url = [NSURL URLWithString:urlToOpen];
        
        // Check if image was tapped
        NSString *fileType = [urlToOpen substringFromIndex: [urlToOpen length] - 4];
        if ([fileType isEqualToString:@".jpg"] || [fileType isEqualToString:@".png"]) {
            [self performSegueWithIdentifier:@"showImage" sender:url];
            return NO;
        }
        
        ExternalLinksWebViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LinkController"];
        controller.url = url;
        
        // For push segue
        // [self.navigationController pushViewController:controller animated:YES];
        
        // For modal segue
        [self presentViewController:controller animated:YES completion:nil];
        
        return NO;
        
    }
    
    return YES;
}

- (void)increaseFontSize {
    mainFontSize += 0.1;
    captionFontSize += 0.05;
    [self reflectFontChangesOnHTML];
}

- (void)decreaseFontSize {
    mainFontSize -= 0.1;
    captionFontSize -= 0.05;
    [self reflectFontChangesOnHTML];
}

- (void)share
{
    NSString *textToShare = @"Look at this awesome website for aspiring iOS Developers!";
    NSURL *myWebsite = [NSURL URLWithString:@"http://www.codingexplorer.com/"];
    
    NSArray *objectsToShare = @[textToShare, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
//    NSArray *excludeActivities = @[UIActivityTypeMail,
//                                   UIActivityTypeMessage,
//                                   UIActivityTypePrint,
//                                   UIActivityTypePostToFacebook,
//                                   UIActivityTypePostToTwitter,
//                                   UIActivityTypePostToWeibo,
//                                   UIActivityTypeCopyToPasteboard];
//    
//    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)reflectFontChangesOnHTML {
    [self storeFontSize];
    
    NSString *alteredHTML = [self.html stringByAppendingString:[self setFontSize]];
    [self.webView loadHTMLString:alteredHTML baseURL:nil];
}

- (void)storeFontSize {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObjectModel *savedFont = self.font.firstObject;
    
    if (savedFont) {
        // Update existing device
        [savedFont setValue:[NSNumber numberWithFloat:mainFontSize] forKey:@"mainSize"];
        [savedFont setValue:[NSNumber numberWithFloat:captionFontSize] forKey:@"captionSize"];
        
    } else {
        // Create a new managed object
        NSManagedObject *newFont = [NSEntityDescription insertNewObjectForEntityForName:@"Font" inManagedObjectContext:context];
        [newFont setValue:[NSNumber numberWithFloat:mainFontSize] forKey:@"mainSize"];
        [newFont setValue:[NSNumber numberWithFloat:captionFontSize] forKey:@"captionSize"];
    }
    
    [self.delegate saveContext];
}

- (void)bookmarkPost
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    [CDPost addBookmarkPost:self.post toManagedObjectContext:managedObjectContext];
    NSLog(@"Finished adding bookmark");
    [self.delegate saveContext];
}

- (void)tappedCoverImage:(UITapGestureRecognizer *)tap {
    [self performSegueWithIdentifier:@"showImage" sender:[NSURL URLWithString:self.post.fullCoverImageURL]];
}

- (void)tappedAuthor:(UITapGestureRecognizer *)tap {
    [self performSegueWithIdentifier:@"showAuthor" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showImage"]) {
        ImageViewController *imgVC = segue.destinationViewController;
        imgVC.photoURL = sender;
    } else if ([segue.identifier isEqualToString:@"showAuthor"]) {
        AuthorViewController *authorVC = segue.destinationViewController;
        authorVC.author = self.post.author;
    }
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    float scrollViewHeight = scrollView.frame.size.height;
    float scrollContentSizeHeight = scrollView.contentSize.height;
    float scrollOffset = scrollView.contentOffset.y;
    
    if (scrollOffset > 0 && !scrolled)
    {
        // then we are at the top
        [UIView animateWithDuration:0.5 animations:^{
            self.webView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height - 60);
        } completion:^(BOOL completed){
            [self.webView.scrollView setContentOffset:CGPointZero animated:YES];
            scrolled = YES;
        }];
        
    }
    else if (scrollOffset < -80) {
        [UIView animateWithDuration:0.5 animations:^{
            self.webView.frame = CGRectMake(0, initialWebViewYOffset, self.view.frame.size.width, self.view.frame.size.height - initialWebViewYOffset);
        } completion:^(BOOL completed){
            scrolled = NO;
        }];
    }
    else if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
    {
        // then we are at the end
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    loaded = NO;
    self.progressView.hidden = NO;
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(loadUpdated) userInfo:nil repeats:YES];
    self.progressView.progress = 0;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIView animateWithDuration:1.5 animations:^{
        self.progressView.progress = 1;
    } completion:^(BOOL completed){
        self.progressView.hidden = YES;
        loaded = YES;
    }];
}

-(void)loadUpdated {
    if (!loaded) {
        [UIView animateWithDuration:0.1 animations:^{
            self.progressView.progress += 0.02;
        }];
    }
}


@end
