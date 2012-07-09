//
//  ViewController.m
//  gaben
//
//  Created by Local Dev User on 19/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, assign) BOOL disapprovingEyes;
- (void)fade;
@end

@implementation ViewController
@synthesize gabenImageView, disapprovingEyes;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(fade) userInfo:nil repeats:YES];
    self.disapprovingEyes = NO; 
}

- (void)viewDidUnload
{
    [self setGabenImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)fade
{
    [UIView animateWithDuration:3.0f animations:^{
        self.gabenImageView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:3.0f animations:^{
            if (self.disapprovingEyes) {
                self.gabenImageView.image = [UIImage imageNamed:@"gaben"];
            } else {
                self.gabenImageView.image = [UIImage imageNamed:@"gaben1"];
            }
            self.disapprovingEyes = !self.disapprovingEyes;
            self.gabenImageView.alpha = 1.0f;
        }];
    }];
}

@end
