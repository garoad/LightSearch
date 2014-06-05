//
//  CamSearchViewController.m
//  LightSearch
//
//  Created by Won-Young Sohn on 2014. 5. 18..
//  Copyright (c) 2014년 Won-Young Sohn. All rights reserved.
//

#import "CamSearchViewController.h"
#import "Penrose.h"
#import "UIImage+CV.h"

@interface CamSearchViewController ()
{
	Penrose * penrose;
}
@end

@implementation CamSearchViewController

@synthesize imageView = _ImageView;
@synthesize subImgView = _subImgView;
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
	self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
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
//	self.fpsLabel.text = @"af";
	
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

- (Mat)changeImage:(Mat&)image Contrast:(int)beta
{
	double alpha=3.0;//1.0~3.0 beta : 0~100
	Mat new_image = Mat::zeros(image.size(),image.type());
	
	for(int y = 0; y < image.rows; y++)
	{
		for(int x = 0;x < image.cols; x++)
		{
			for(int c = 0; c < 3; c++)
			{
				new_image.at<Vec3b>(y,x)[c]=
				saturate_cast<uchar>(alpha * (image.at<Vec3b>(y,x)[c]) + beta);
			}
		}
	}
	
	return new_image;
}

- (void)setSubImage:(UIImage *)image
{
	self.subImgView.image = image;
	self.subImgView.frame = CGRectMake(0, self.view.frame.size.height-(image.size.height/4), image.size.width/4, image.size.height/4);
}

- (void)setLabelValue:(NSString *)value
{
	self.fpsLabel.text = value;
}

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
	
	Mat image_copy;// = [self changeImage:image Contrast:0];
	
	IplImage stub, *orgImage;
	cvtColor(image, image_copy, CV_BGRA2BGR);
	stub = image_copy;
	orgImage = cvCloneImage(&stub);
	IplImage * dstImage = cvCreateImage(cvSize(orgImage->width, orgImage->height), IPL_DEPTH_8U, 3);
	[penrose samplingWithIplImage:orgImage andDistImage:dstImage];
	[penrose drawSamplePointsMat:image];
	[self performSelectorOnMainThread:@selector(setSubImage:) withObject:[UIImage UIImageFromIplImage:dstImage] waitUntilDone:YES];
	image_copy.release();
	cvReleaseImage(&orgImage);
	cvReleaseImage(&dstImage);
		
	NSTimeInterval endTime = [NSDate timeIntervalSinceReferenceDate];
	[self performSelectorOnMainThread:@selector(setLabelValue:) withObject:[NSString stringWithFormat:@"%.1f FPS", 1 / (endTime - startTime)] waitUntilDone:YES];
}

@end
