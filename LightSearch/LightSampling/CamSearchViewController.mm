//
//  CamSearchViewController.m
//  LightSearch
//
//  Created by Won-Young Sohn on 2014. 5. 18..
//  Copyright (c) 2014년 Won-Young Sohn. All rights reserved.
//

#import "CamSearchViewController.h"
#import "Penrose.h"

@interface CamSearchViewController ()
{
	Penrose * penrose;
}
@end

@implementation CamSearchViewController

@synthesize imageView = _ImageView;
@synthesize fpsLabel = _fpsLabel;
@synthesize videoCamera = _videoCamera;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
	self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
	self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetLow;
	self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
	self.videoCamera.defaultFPS = 30;
	self.videoCamera.delegate = self;
	penrose = [Penrose new];
//	self.videoCamera.grayscale = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.videoCamera start];
	self.fpsLabel.text = @"af";
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)processImage:(Mat&)image
{
	NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
	
	/*
	// Do some OpenCV stuff with the image
	Mat image_copy;
	cvtColor(image, image_copy, CV_BGRA2BGR);
	
	// invert image
	bitwise_not(image_copy, image_copy);
	cvtColor(image_copy, image, CV_BGR2BGRA);
	*/
	
	Mat dstImage;
//	Mat image_copy;
//	cvtColor(image, image_copy, CV_BGRA2GRAY);
//	cvtColor(image_copy, image, CV_GRAY2BGRA);
	[penrose samplingWithMat:image andDistMat:dstImage];
	[penrose drawSamplePointsMat:image];
	
		
	NSTimeInterval endTime = [NSDate timeIntervalSinceReferenceDate];
	[self.fpsLabel setText:[NSString stringWithFormat:@"%.1f", 1 / (endTime - startTime)]];
	NSLog(@"%.1f", 1 / (endTime - startTime));
}

@end
