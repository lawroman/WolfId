//
//  ViewController.m
//  WolfId
//
//  Created by Roman Law on 8/25/16.
//  Copyright © 2016 Roman Law. All rights reserved.
//
//  -Oct 31 2016 added Meeting Code, sending record to server, some cleanup
//

#import "ViewController.h"
#import "Post.h"
@import UIKit;
@import Firebase;

/**
 * AdMob ad unit IDs are not currently stored inside the google-services.plist file. Developers
 * using AdMob can store them as custom values in another plist, or simply use constants. Note that
 * these ad units are configured to return only test ads, and should not be used outside this sample.
 */
static NSString *const kBannerAdUnitID = @"ca-app-pub-1217440020027907/9706966273";
// @"ca-app-pub-3940256099942544/2934735716";


@implementation NSString (Helpers)

+(BOOL)stringIsNilOrEmpty:(NSString*)aString {
    if (!aString)
        return YES;
    return [aString isEqualToString:@""];
}
@end

@interface ViewController ()
- (void) writeToTextFile:(NSString *)infoString;
- (NSString *) getStudentIdContent;
- (CIImage *) createQRForString:(NSString *)qrString;
- (void) setWidgetsVisible:(Boolean)value;
- (NSString *) getTimeStamp;
@end

@implementation ViewController
bool isInMeeting = false;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *registeredInfo = [self getStudentIdContent];
    
    // [START create_database_reference]
    self.ref = [[FIRDatabase database] reference];
    // [END create_database_reference]
    
    if ([NSString stringIsNilOrEmpty:registeredInfo] == NO)
    {
        // hide the main inputs
        [self setWidgetsVisible:true];
        
        NSString *idInfo = [registeredInfo stringByAppendingString:@"#"];
        idInfo = [idInfo stringByAppendingString:[self getTimeStamp]];
        
        CIImage *qr = [self createQRForString:idInfo];
        UIImage *uiImage = [[UIImage alloc] initWithCIImage:qr];
        self.qrCodeView.image = uiImage;
        
        NSString *titleString = @"Registered to ";
        NSUInteger startRange =[registeredInfo rangeOfString:@"#"].location +1;
        NSRange range = NSMakeRange(startRange, registeredInfo.length - startRange);
        self.bannerLabel.text = [titleString stringByAppendingString:[registeredInfo substringWithRange:range]];
    }
    
    self.adBannerView.adUnitID = @"ca-app-pub-1217440020027907/9706966273";
    self.adBannerView.rootViewController = self;
    [self.adBannerView loadRequest:[GADRequest request]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerButton:(UIButton *)sender {
    // save student info to a local storage
    NSString *myInfo;
    NSString *myId = _idText.text;
    NSString *myName = _nameText.text.uppercaseString;
    
    if ([NSString stringIsNilOrEmpty:myId] == NO &&
        [NSString stringIsNilOrEmpty:myName] == NO)
    {
        myInfo = myId;
        myInfo = [myInfo stringByAppendingString:@"#"];
        myInfo = [myInfo stringByAppendingString:myName];
        
        // storing data
        [self writeToTextFile:myInfo];
        
        NSString *titleString = @"Registered to ";
        _bannerLabel.text = [titleString stringByAppendingString:myName ];
        
        // append current timestamp
        myInfo = [myInfo stringByAppendingString:@"#"];
        myInfo = [myInfo stringByAppendingString:[self getTimeStamp]];

        UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"Home of the Wolves"  message:nil  preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        // show only the new QR code on screen
        [self setWidgetsVisible:true];
        CIImage *qr = [self createQRForString:myInfo];
        UIImage *uiImage = [[UIImage alloc] initWithCIImage:qr];
        self.qrCodeView.image = uiImage;
    }
    else if (isInMeeting && [NSString stringIsNilOrEmpty:myId] == NO)
    {
        // send meeting code to server database
        NSString *code = _idText.text; // meeting code
        NSString *content = [self getStudentIdContent];
        
        NSUInteger startRange =[content rangeOfString:@"#"].location +1;
        NSRange range = NSMakeRange(startRange, content.length - startRange);
        
        NSString *uid = [content substringToIndex:(startRange-1)];
        NSString *username = [content substringWithRange:range];
        NSString *datestamp = [self getTimeStamp];
        
        // Create new post at /$code/$uid/
        // [START write_fan_out]
        NSString *key = [[_ref child:uid] child:uid].key;
        NSDictionary *post = @{@"uid": uid,
                               @"username": username,
                               @"datestamp": datestamp,
                               @"code": code,
                               @"content": [NSString stringWithFormat:@"%@#%@", code, content]};
        NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/%@/%@/", code, key]: post};
        [_ref updateChildValues:childUpdates];
        // [END write_fan_out]
        
        UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:[NSString stringWithFormat:@"Meeting Code %@ Sent", code]  message:nil  preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        // clear text
        _idText.text = @"";
    }
    else if (isInMeeting != true)
    {
        UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"Please enter your ID and Name." message:nil  preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];

    }
}

//Method writes a string to a text file
-(void) writeToTextFile:(NSString *)infoString{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/id.txt",
                          documentsDirectory];
    
    //create content
    NSString *content = infoString;
    //save content to the documents directory
    [content writeToFile:fileName
              atomically:NO
                encoding:NSStringEncodingConversionAllowLossy
                   error:nil];
    
}


//Method retrieves content from documents directory
-(NSString *) getStudentIdContent{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to read the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/id.txt",
                          documentsDirectory];
    NSString *content = [[NSString alloc] initWithContentsOfFile:fileName
                                                    usedEncoding:nil
                                                           error:nil];
    return content;
}

//Method to set the widgets
- (void) setWidgetsVisible:(Boolean)value {
    
    self.nameLabel.hidden = value;
    self.nameText.hidden = value;
    
    if (value == true)
    {
        // showing the meeting code input page
        
        [self.idLabel setText:@"Enter Meeting Code:"];
        [self.registerButton setTitle:@"Submit" forState:UIControlStateNormal];
        
        // clear the old text
        _idText.text = @"";
        _nameText.text = @"";
        
        isInMeeting = true;
    }
}

//Method generates a QR image
- (CIImage *) createQRForString:(NSString *)qrString {
    NSData *stringData = [qrString dataUsingEncoding: NSISOLatin1StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    
    return qrFilter.outputImage;
}

// Method to create a timestamp string
- (NSString *) getTimeStamp {
    NSDate *todaysDate = [NSDate new];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"DDDHHmm"];
    NSString *dateTimeString = [formatter stringFromDate:todaysDate];
    
    return dateTimeString;
}
@end
