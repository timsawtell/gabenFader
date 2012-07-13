#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *gabenImageView;
@property (strong, nonatomic) IBOutlet UIImageView *gabenTopImageView;
@property (strong, nonatomic) IBOutlet UIView *previewView;
@property (nonatomic, strong) IBOutlet UIImageView *leftEye;
@property (nonatomic, strong) IBOutlet UIImageView *rightEye;

@end
