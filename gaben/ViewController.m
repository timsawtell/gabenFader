//
//  ViewController.m
//  gaben
//
//  Created by Local Dev User on 19/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
- (void)fade;
@end

@implementation ViewController
@synthesize gavenImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(fade) userInfo:nil repeats:YES];
}

- (void)viewDidUnload
{
    [self setGavenImageView:nil];
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
        self.gavenImageView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:3.0f animations:^{
            self.gavenImageView.alpha = 1.0f;
        }];
    }];
}

@end
