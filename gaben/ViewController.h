#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *gabenImageView;
@property (strong, nonatomic) IBOutlet UIImageView *gabenTopImageView;

@end
