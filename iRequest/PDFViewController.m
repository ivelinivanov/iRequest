//
//  PDFViewController.m
//  iRequest
//
//  Created by Ivelin Ivanov on 8/27/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "PDFViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface PDFViewController ()
{
    NSString *kRequestLetter;
}

@end

@implementation PDFViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    kRequestLetter = [NSString stringWithFormat:@"Mr. or Ms. %@\n\nPlease accept this letter as a formal request for vacation time from %@ through %@. I will make certain that all of my work is current before leaving on vacation, and will work closely with you and the other members of the department to make sure that all of my responsibilities are taken care of during my absence. \n\nI greatly appreciate your consideration and assistance with this request. Please let me know if my leave request has been approved at your earliest convenience so that I can finalize travel arrangements.\n\nRegards,\n\n\n\n (sign here)", self.detailItem[@"supervisorName"], self.detailItem[@"fromDate"], self.detailItem[@"toDate"]];
    
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportButtonPressed)];
    self.navigationItem.rightBarButtonItem = exportButton;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.screenName = @"PDF Screen";
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.webView];
}

-(IBAction)exportButtonPressed
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Export"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Send by Email"
                                                    otherButtonTitles:@"Print", @"Open in", nil];
    [actionSheet showInView:self.view];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupPageViewer];
}

-(void)setupPageViewer
{
    [self drawPDF:[self getPDFFileName]];
    [self showPDFFile];
}

#pragma mark - PDF Drawing

-(NSString*)getPDFFileName
{
    NSString* fileName = @"Request.PDF";
    
    NSArray *arrayPaths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFileName = [path stringByAppendingPathComponent:fileName];
    
    
    return pdfFileName;
    
}

-(void)drawPDF:(NSString*)fileName
{
    UIGraphicsBeginPDFContextToFile(fileName, CGRectZero, nil);
    // Mark the beginning of a new page.
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
    
    [self drawLabels];
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
}

-(void)showPDFFile
{
    NSURL *url = [NSURL fileURLWithPath:[self getPDFFileName]];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView setScalesPageToFit:YES];
    [self.webView loadRequest:request];
}

-(void)drawText:(NSString*)textToDraw inFrame:(CGRect)frameRect
{

    [textToDraw drawInRect:frameRect withAttributes:nil];

}


-(void)drawLabels
{
    
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"Request" owner:nil options:nil];
    
    UIView* mainView = [objects objectAtIndex:0];
    
    for (UIView* view in [mainView subviews]) {
        if([view isKindOfClass:[UILabel class]])
        {
            UILabel* label = (UILabel*)view;
           
            NSString *labelText = [self getTextForLabelWithTag:label.tag];
            
            [self drawText:labelText inFrame:label.frame];
        }
    }
    
}

-(NSString *)getTextForLabelWithTag:(int)tag
{
    switch (tag)
    {
        case 0:
            return @"Vacantion Request";
        case 1:
            return self.detailItem[@"senderName"];
        case 2:
            return self.detailItem[@"senderAddress"];
        case 3:
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"dd MMMM yyyy"];
            return [formatter  stringFromDate:[NSDate date]] ;
        }
        case 4:
            return self.detailItem[@"supervisorName"];
        case 5:
            return self.detailItem[@"companyName"];
        case 6:
            return self.detailItem[@"companyAddress"];
        case 7:
            return kRequestLetter;
        case 8:
            return self.detailItem[@"senderName"];
        default:
            return nil;
    }
}

#pragma mark - Action Sheet Delegate Methods

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //send by email
        NSData *pdfData = [NSData dataWithContentsOfFile:[self getPDFFileName]];
        
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        [mailController setSubject:@"Vacation Request"];
        [mailController addAttachmentData:pdfData mimeType:@"application/pdf" fileName:@"VacationRequest.pdf"];
        mailController.mailComposeDelegate = self;
        
        [self presentViewController:mailController animated:YES completion:nil];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"PDF Export" action:@"Mail export" label:nil value:nil] build]];
    }
    else if (buttonIndex == 1)
    {
        //print
        UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];

        NSData *pdfData = [NSData dataWithContentsOfFile:[self getPDFFileName]];
        printController.printingItem = pdfData;
        
        [printController presentAnimated:YES completionHandler:nil];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"PDF Export" action:@"Print export" label:nil value:nil] build]];
        
    }
    else if (buttonIndex == 2)
    {
        
        self.docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:[self getPDFFileName]]];
        
        self.docController.delegate = self;
        
        [self.docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
        
        [self.docController dismissMenuAnimated:YES];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Open" action:@"Mail export" label:nil value:nil] build]];
    }
}

#pragma mark - MailViewControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DocumentInteractionController

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application
{
    NSLog(@"Send to App %@  ...", application);
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    NSLog(@"Finished sending to app %@  ...", application);
    
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    NSLog(@"Bye");
}

@end
