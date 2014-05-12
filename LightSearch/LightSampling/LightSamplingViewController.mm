//
//  LightSamplingViewController.m
//  LightSearch
//
//  Created by Won-Young Sohn on 2014. 5. 6..
//  Copyright (c) 2014년 Won-Young Sohn. All rights reserved.
//

#import "LightSamplingViewController.h"
#import "Penrose.h"
#import <opencv2/core/core_c.h>
#import <opencv2/core/types_c.h>

@interface LightSamplingViewController ()

@end

@implementation LightSamplingViewController

// UIImage -> IplImage 변환
- (IplImage*)IplImageFromUIImage:(UIImage*)image {
    
    CGImageRef imageRef = image.CGImage;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    IplImage *iplimage = cvCreateImage(cvSize(image.size.width,image.size.height), IPL_DEPTH_8U, 4 );
    
    CGContextRef contextRef = CGBitmapContextCreate(
                                                    iplimage->imageData,
                                                    iplimage->width,
                                                    iplimage->height,
                                                    iplimage->depth,
                                                    iplimage->widthStep,
                                                    colorSpace,
                                                    kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef,
                       CGRectMake(0, 0, image.size.width, image.size.height),
                       imageRef);
    
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplimage, ret, CV_RGBA2BGR);
    cvReleaseImage(&iplimage);
    
    return ret;
}

// IplImage -> UIImage 변환
- (UIImage*)UIImageFromIplImage:(IplImage*)image {
    
    CGColorSpaceRef colorSpace;
    if (image->nChannels == 1)
    {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        //BGR에서 RGB로 변환
        cvCvtColor(image, image, CV_BGR2RGB);
    }
    NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(image->width,
                                        image->height,
                                        image->depth,
                                        image->depth * image->nChannels,
                                        image->widthStep,
                                        colorSpace,
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault
                                        );
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return ret;
}

- (void)drawSamplePoints:(IplImage *)image withPenrose:(Penrose *)penrose
{
	
	NSInteger numPoint1 = [penrose.sampledPoints count];
	NSInteger numPoint = [penrose.points count];
	NSLog(@"Sampled : %d\n", numPoint1);
	NSLog(@"Merged : %d\n", numPoint);

	int x, y;
	
	for (NSInteger i=0; i<numPoint1; i++)
	{
		Point2DWrapped * point = [penrose.sampledPoints objectAtIndex:i];
		x = point.x;
		y = point.y;
		
		cvCircle(image, cvPoint(x,y), 1, cvScalar(0,0,255));
	}
	
	for (NSInteger i=0; i<numPoint; i++)
	{
		Point2DWrapped * point = [penrose.points objectAtIndex:i];
		x = point.x;
		y = point.y;
		
		cvCircle(image, cvPoint(x,y), 2, cvScalar(0,255,0));
	}
}

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	UIImage * orgImage = [UIImage imageNamed:@"hdr1.png"];
	IplImage * sourceImage = [self IplImageFromUIImage:orgImage];
	IplImage * radianImage = cvCreateImage(cvSize(sourceImage->width, sourceImage->height), IPL_DEPTH_8U, 3);
	Penrose * penrose = [Penrose new];
	[penrose setRadianceMapWithEXP:sourceImage->width height:sourceImage->height source:(unsigned char*)sourceImage->imageData dist:(unsigned char*)radianImage->imageData];
	[penrose gridSampling:91 height:45];
	[penrose mergeSampledPoints:40.0];
	[self drawSamplePoints:sourceImage withPenrose:penrose];
	self.resultImageView.image = [self UIImageFromIplImage:sourceImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
