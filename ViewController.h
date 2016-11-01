//
//  ViewController.h
//  WolfId
//
//  Created by Roman Law on 8/25/16.
//  Copyright © 2016 Roman Law. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMobileAds;
@import Firebase;

@interface ViewController : UIViewController
- (IBAction)registerButton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *idText;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *qrView;
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *bannerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeView;
@property (weak, nonatomic) IBOutlet GADBannerView *adBannerView;
@property (strong, nonatomic) FIRDatabaseReference *ref;


@end

