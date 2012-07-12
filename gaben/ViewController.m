#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, assign) BOOL disapprovingEyes;
- (void)fade;
- (void)creepyFade;
@end

@implementation ViewController
@synthesize gabenTopImageView;
@synthesize gabenImageView, disapprovingEyes;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(fade) userInfo:nil repeats:YES];
    self.disapprovingEyes = YES; 
    self.gabenImageView.image = [UIImage imageNamed:@"gaben1"];
    self.gabenTopImageView.image = [UIImage imageNamed:@"gaben1Top"];
    self.gabenTopImageView.hidden = YES;
    double delayInSeconds = 60.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self creepyFade];
    });
    
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureMetadataOutput *metaOutput = [AVCaptureMetadataOutput new];
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
    if (videoInput) {
        [captureSession addInput:videoInput];
        [captureSession addOutput:metaOutput];
    }
    else {
        // Handle the failure.
        NSLog(@"total failure");
    }
    [captureSession startRunning];
}

- (void)viewDidUnload
{
    [self setGabenImageView:nil];
    [self setGabenTopImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight);
}

- (void)creepyFade
{
    self.gabenTopImageView.alpha = 0.5f;
    self.gabenTopImageView.hidden = NO;
    [UIView animateWithDuration:10 animations:^{
        self.gabenTopImageView.alpha = 0.2f;
        self.gabenImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:10 animations:^{
            self.gabenImageView.alpha = 1;
            self.gabenTopImageView.alpha = 0;
        } completion:^(BOOL finished) {
            self.gabenTopImageView.hidden = YES;
        }];
    }];
}

- (void)fade
{
    if (self.disapprovingEyes) {
        [UIView animateWithDuration:3 animations:^{
            self.gabenImageView.alpha = 0;
        } completion:^(BOOL finished) {
            self.gabenImageView.image = [UIImage imageNamed:@"gaben"];
            [UIView animateWithDuration:3 animations:^{
                self.gabenImageView.alpha = 1;
            }];
        }];
    } else {

        [UIView animateWithDuration:3 animations:^{
            self.gabenImageView.alpha = 0;
        } completion:^(BOOL finished) {
            self.gabenImageView.image = [UIImage imageNamed:@"gaben1"];
            [UIView animateWithDuration:3 animations:^{
                self.gabenImageView.alpha = 1;
            }];
        }];
        
        double delayInSeconds = 60.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self creepyFade];
        });
    }
    self.disapprovingEyes = !self.disapprovingEyes;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{

}

@end
