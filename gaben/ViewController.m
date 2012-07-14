#import "ViewController.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()
@property (nonatomic, assign) BOOL disapprovingEyes;
@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic, assign) BOOL isUsingFrontFacingCamera;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, assign) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIImage *square;
@property (nonatomic, assign) CGPoint leftEyeOrigin;
@property (nonatomic, assign) CGPoint rightEyeOrigin;
@property (nonatomic, assign) CGSize eyeSize;
- (void)fade;
- (void)creepyFade;
@end

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
static CGFloat kEyeBallWidth = 100.0f;
static CGFloat kEyeBallHeight = 50.0f;


@implementation ViewController
@synthesize previewView, leftEyeOrigin, rightEyeOrigin;
@synthesize gabenTopImageView, square, leftEye, rightEye, eyeSize;
@synthesize gabenImageView, disapprovingEyes, faceDetector, isUsingFrontFacingCamera, videoDataOutput, videoDataOutputQueue, stillImageOutput, previewLayer;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(fade) userInfo:nil repeats:YES];
    self.disapprovingEyes = YES; 
    self.gabenImageView.image = [UIImage imageNamed:@"gabenBottom"];
    self.gabenTopImageView.image = [UIImage imageNamed:@"gabenTop"];
    UIImage *left = [UIImage imageNamed:@"iris"];
    UIImage *right = [UIImage imageNamed:@"iris"];
    self.leftEye.image = left;
    self.rightEye.image = right;
    self.eyeSize = CGSizeMake(35, 30);
    self.previewView.hidden = YES;
    double delayInSeconds = 150.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self creepyFade];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupAVCapture];
}

- (void)creepyFade
{
    self.gabenTopImageView.alpha = 0.5;
    [UIView animateWithDuration:10 animations:^{
        self.leftEye.alpha = self.rightEye.alpha = 0.7;
        self.gabenImageView.alpha = 0.05;
        self.gabenTopImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:10 animations:^{
            self.gabenImageView.alpha = 1;
            self.gabenTopImageView.alpha = 1;
            self.leftEye.alpha = self.rightEye.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }];
}

- (void)fade
{
    if (self.disapprovingEyes) {
        [UIView animateWithDuration:3 animations:^{
            self.leftEye.alpha = self.rightEye.alpha = self.gabenImageView.alpha = self.gabenTopImageView.alpha = 0;
        } completion:^(BOOL finished) {
            self.gabenImageView.image = [UIImage imageNamed:@"gaben"];
            self.gabenTopImageView.hidden = self.leftEye.hidden = self.rightEye.hidden = YES;
            [UIView animateWithDuration:3 animations:^{
                self.gabenImageView.alpha = 1;
            }];
        }];
    } else {
        
        [UIView animateWithDuration:3 animations:^{
            self.gabenImageView.alpha = 0;
        } completion:^(BOOL finished) {
            self.gabenImageView.image = [UIImage imageNamed:@"gabenBottom"];
            self.gabenTopImageView.hidden = self.leftEye.hidden = self.rightEye.hidden = NO;
            [UIView animateWithDuration:3 animations:^{
                self.leftEye.alpha = self.rightEye.alpha = self.gabenTopImageView.alpha = self.gabenImageView.alpha = 1;
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

- (void)viewDidUnload
{
    [self setGabenImageView:nil];
    [self setGabenTopImageView:nil];
    [self setPreviewLayer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGPoint leftOrigin, rightOrigin;
    if (interfaceOrientation == UIDeviceOrientationLandscapeLeft) {
        self.gabenImageView.transform = CGAffineTransformMakeRotation(DegreesToRadians(90));
        leftOrigin.x = 520;
        leftOrigin.y = 378;
        rightOrigin.x = 502;
        rightOrigin.y = 585;
    } else if (interfaceOrientation == UIDeviceOrientationLandscapeRight) {
        self.gabenImageView.transform = CGAffineTransformMakeRotation(DegreesToRadians(270));
        leftOrigin.x = 233;
        leftOrigin.y = 408;
        rightOrigin.x = 215;
        rightOrigin.y = 616;
    }
    self.gabenTopImageView.transform = self.gabenImageView.transform;
    self.gabenImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.gabenTopImageView.frame = self.gabenImageView.frame;
    
    self.leftEye.transform = self.rightEye.transform = self.gabenImageView.transform;
    self.leftEye.frame = CGRectMake(leftOrigin.x, leftOrigin.y, self.eyeSize.width, self.eyeSize.height);
    self.rightEye.frame = CGRectMake(rightOrigin.x, rightOrigin.y, self.eyeSize.width, self.eyeSize.height);
    self.leftEyeOrigin = self.leftEye.frame.origin;
    self.rightEyeOrigin = self.rightEye.frame.origin;
    return (interfaceOrientation == UIDeviceOrientationPortrait);
}



// all the video bullshit happens down here

// called asynchronously as the capture output is capturing sample buffers, this method asks the face detector (if on)
// to detect features and for each draw the red square in a layer and set appropriate orientation
- (void)drawFaceBoxesForFeatures:(NSArray *)features forVideoBox:(CGRect)clap orientation:(UIDeviceOrientation)orientation
{
	NSInteger featuresCount = [features count];
	
    [CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	if ( featuresCount == 0 ) {
		[CATransaction commit];
		return; // early bail.
	}
    
	CGSize parentFrameSize = [self.view frame].size;
	NSString *gravity = [previewLayer videoGravity];
	BOOL isMirrored = [previewLayer isMirrored];
	CGRect previewBox = [ViewController videoPreviewBoxForGravity:gravity 
                                                                 frameSize:parentFrameSize 
                                                              apertureSize:clap.size];
	CIFaceFeature *ff = [features objectAtIndex:0];
    CGRect faceRect = [ff bounds];
    
    // flip preview width and height
    CGFloat temp = faceRect.size.width;
    faceRect.size.width = faceRect.size.height;
    faceRect.size.height = temp;
    temp = faceRect.origin.x;
    faceRect.origin.x = faceRect.origin.y;
    faceRect.origin.y = temp;
    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat widthScaleBy = previewBox.size.width / clap.size.height;
    CGFloat heightScaleBy = previewBox.size.height / clap.size.width;
    faceRect.size.width *= widthScaleBy;
    faceRect.size.height *= heightScaleBy;
    faceRect.origin.x *= widthScaleBy;
    faceRect.origin.y *= heightScaleBy;
    
    if ( isMirrored )
        faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), previewBox.origin.y);
    else
        faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);

    // now move the eyes muaahahah
    CGPoint centerOfPreview = [self centerOfRect:self.previewView.frame];
    CGPoint centerOfFace = [self centerOfRect:faceRect];
    CGFloat percentMovedX = (centerOfFace.x - centerOfPreview.x) / self.previewLayer.frame.size.width;
    CGFloat percentMovedY = (centerOfFace.y - centerOfPreview.y) / self.previewLayer.frame.size.height;
    [self moveEye:self.leftEye byPercentagePoint:CGPointMake(percentMovedX, percentMovedY)];
    [self moveEye:self.rightEye byPercentagePoint:CGPointMake(percentMovedX, percentMovedY)]; 
	
	[CATransaction commit];
}

- (void)moveEye:(UIImageView *)eyeView byPercentagePoint:(CGPoint)percent
{
    CGFloat movementX = kEyeBallWidth * percent.x * 0.1;
    CGFloat movementY = kEyeBallHeight * percent.y * 0.3;
    if (eyeView == self.leftEye) {
        eyeView.frame = CGRectMake(self.leftEyeOrigin.x + movementX, self.leftEyeOrigin.y + movementY, self.eyeSize.width, self.eyeSize.height);
    } else {
        eyeView.frame = CGRectMake(self.rightEyeOrigin.x + movementX, self.rightEyeOrigin.y + movementY, self.eyeSize.width, self.eyeSize.height);
    }
}

- (CGPoint)centerOfRect:(CGRect)rect
{
    CGPoint p = CGPointMake(rect.origin.x + (rect.size.width / 2), rect.origin.y + (rect.size.height / 2));
    return p;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{	
	// got an image
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge_transfer NSDictionary *)attachments];

	NSDictionary *imageOptions = nil;
	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
	int exifOrientation;
    
	enum {
		PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
		PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.  
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.  
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.  
		PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.  
		PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.  
		PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.  
		PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.  
	};
	
	switch (curDeviceOrientation) {
		case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
			exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
			break;
		case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
			if (isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			break;
		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
			if (isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			break;
		case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
		default:
			exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
			break;
	}
    
	imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];
	NSArray *features = [faceDetector featuresInImage:ciImage options:imageOptions];
	
    // get the clean aperture
    // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
    // that represents image data valid for display.
	CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
	CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);
	
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		[self drawFaceBoxesForFeatures:features forVideoBox:clap orientation:curDeviceOrientation];
	});
}

- (void)setupAVCapture
{
	NSError *error = nil;
	self.isUsingFrontFacingCamera = YES;
    self.square = [UIImage imageNamed:@"squarePNG"];
	AVCaptureSession *session = [AVCaptureSession new];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	    [session setSessionPreset:AVCaptureSessionPreset640x480];
	else
	    [session setSessionPreset:AVCaptureSessionPresetHigh];
	
    // Select a video device, make an input
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
                                                            message:[error localizedDescription]
                                                           delegate:nil 
                                                  cancelButtonTitle:@"Dismiss" 
                                                  otherButtonTitles:nil];
        [alertView show];
        [self teardownAVCapture];
    }
	
	if ( [session canAddInput:deviceInput] )
		[session addInput:deviceInput];
	
    // Make a still image output
	self.stillImageOutput = [AVCaptureStillImageOutput new];
	[self.stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:"AVCaptureStillImageIsCapturingStillImageContext"];
	if ( [session canAddOutput:self.stillImageOutput] )
		[session addOutput:self.stillImageOutput];
	
    // Make a video data output
	videoDataOutput = [AVCaptureVideoDataOutput new];
	
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
	NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
									   [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	[self.videoDataOutput setVideoSettings:rgbOutputSettings];
	[self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
    
    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
	self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
	[self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
	
    if ( [session canAddOutput:self.videoDataOutput] )
		[session addOutput:self.videoDataOutput];
    [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
	
	self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
	[self.previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
	[self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
	CALayer *rootLayer = [self.previewView layer];
	[rootLayer setMasksToBounds:YES];
	[self.previewLayer setFrame:[rootLayer bounds]];
	[rootLayer addSublayer:self.previewLayer];
   
    NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
	self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    
    AVCaptureDevicePosition desiredPosition;
    desiredPosition = AVCaptureDevicePositionFront;
	
	for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
		if ([d position] == desiredPosition) {
			[[self.previewLayer session] beginConfiguration];
			AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
			for (AVCaptureInput *oldInput in [[previewLayer session] inputs]) {
				[[self.previewLayer session] removeInput:oldInput];
			}
			[[self.previewLayer session] addInput:input];
			[[self.previewLayer session] commitConfiguration];
			break;
		}
	}
    [session startRunning];
}


// find where the video box is positioned within the preview layer based on the video size and gravity
+ (CGRect)videoPreviewBoxForGravity:(NSString *)gravity frameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize
{
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size = CGSizeZero;
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (viewRatio > apertureRatio) {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        } else {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
        size.width = frameSize.width;
        size.height = frameSize.height;
    }
	
	CGRect videoBox;
	videoBox.size = size;
	if (size.width < frameSize.width)
		videoBox.origin.x = (frameSize.width - size.width) / 2;
	else
		videoBox.origin.x = (size.width - frameSize.width) / 2;
	
	if ( size.height < frameSize.height )
		videoBox.origin.y = (frameSize.height - size.height) / 2;
	else
		videoBox.origin.y = (size.height - frameSize.height) / 2;
    
	return videoBox;
}

- (void)teardownAVCapture
{
	if (self.videoDataOutputQueue)
		dispatch_release(self.videoDataOutputQueue);
}


@end
