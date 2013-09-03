//
//  ViewController.h
//  iRequest
//
//  Created by Ivelin Ivanov on 8/27/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "RequestConstants.h"
#import "GAITrackedViewController.h"

@interface RequestViewController : GAITrackedViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *supervisorName;
@property (weak, nonatomic) IBOutlet UITextField *company;
@property (weak, nonatomic) IBOutlet UITextField *companyAddress;

@property (weak, nonatomic) IBOutlet UITextField *senderName;
@property (weak, nonatomic) IBOutlet UITextField *senderAddress;

@property (weak, nonatomic) IBOutlet UITextField *firstDayOfLeave;
@property (weak, nonatomic) IBOutlet UITextField *lastDayOfLeave;

- (IBAction)generateButtonPressed:(id)sender;

@end
