//
//  ViewController.m
//  iRequest
//
//  Created by Ivelin Ivanov on 8/27/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "RequestViewController.h"
#import "PDFViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface RequestViewController ()
{
    UIDatePicker *firstDatePicker;
    UIDatePicker *lastDatePicker;
    
    NSDate *firstDate;
    NSDate *lastDate;
}

@end

@implementation RequestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    firstDate = [NSDate date];
    lastDate = [NSDate date];
    
    firstDatePicker = [[UIDatePicker alloc] init];
    lastDatePicker = [[UIDatePicker alloc] init];
    
    firstDatePicker.datePickerMode = UIDatePickerModeDate;
    lastDatePicker.datePickerMode = UIDatePickerModeDate;
    
    self.firstDayOfLeave.inputView = firstDatePicker;
    self.lastDayOfLeave.inputView = lastDatePicker;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMMM yyyy"];
    
    NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
    
    self.firstDayOfLeave.text = stringFromDate;
    self.lastDayOfLeave.text = stringFromDate;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.screenName = @"Request Screen";
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)shouldExportToPDF
{
    for (UIView *view in self.view.subviews)
    {
        if([view isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField *)view;
            if ([textField.text isEqualToString:@""])
            {
                return  NO;
            }
        }
    }
    
    return YES;
}

-(BOOL)validDatesAreEntered
{

    NSLog(@"%f", [lastDate timeIntervalSinceDate:firstDate]);
    
    if ([lastDate timeIntervalSinceDate:firstDate] < -1)
    {
        return NO;
    }
    
    return YES;
}




-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSDictionary *resultDict = @{@"supervisorName": self.supervisorName.text,
                                 @"companyName": self.company.text,
                                 @"companyAddress": self.companyAddress.text,
                                 @"senderName": self.senderName.text,
                                 @"senderAddress": self.senderAddress.text,
                                 @"fromDate": self.firstDayOfLeave.text,
                                 @"toDate": self.lastDayOfLeave.text
                                 };
    
    PDFViewController *destination = (PDFViewController *)[segue destinationViewController];
    destination.detailItem = resultDict;
    
}
- (IBAction)generateButtonPressed:(id)sender
{
    if ([self shouldExportToPDF])
    {
        [self performSegueWithIdentifier:@"toDetailView" sender:self];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Can't generate pdf. Some of the fields are empty!"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil] show];
    }
}

#pragma mark - TextField Delegate Methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.firstDayOfLeave] || [textField isEqual:self.lastDayOfLeave])
    {
        textField.text = @"";
    }
    
    return YES;
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.firstDayOfLeave] || [textField isEqual:self.lastDayOfLeave])
    {
        UIDatePicker *datePicker = (UIDatePicker *)textField.inputView;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMMM yyyy"];
        
        NSString *stringFromDate = [formatter stringFromDate:datePicker.date];
        
        textField.text = stringFromDate;
        
        if ([textField isEqual:self.firstDayOfLeave])
        {
            firstDate = datePicker.date;
        }
        else
        {
            lastDate = datePicker.date;
        }
    }
    
    if (![self validDatesAreEntered])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!"
                                                        message:@"The last day of your vacantion is before the first one!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

@end
