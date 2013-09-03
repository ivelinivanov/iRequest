//
//  PDFViewController.h
//  iRequest
//
//  Created by Ivelin Ivanov on 8/27/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "RequestConstants.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "GAITrackedViewController.h"

@interface PDFViewController : GAITrackedViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSDictionary *detailItem;

@property (nonatomic, retain) UIDocumentInteractionController *docController;

@end
