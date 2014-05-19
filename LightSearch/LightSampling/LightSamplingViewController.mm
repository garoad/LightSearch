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
#import "UIImage+CV.h"

@interface LightSamplingViewController ()

@end

@implementation LightSamplingViewController

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

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
	UIImage * orgImage = [UIImage imageNamed:@"hdr1.png"];
	IplImage * sourceImage = [UIImage IplImageFromUIImage:orgImage];
	IplImage * radianceImage = nil;
	Penrose * penrose = [Penrose new];
	[penrose samplingWithIplImage:sourceImage andDistImage:radianceImage];
	[penrose drawSamplePoints:sourceImage];
	self.resultImageView.image = [UIImage UIImageFromIplImage:sourceImage];
	NSTimeInterval endTime = [NSDate timeIntervalSinceReferenceDate];
	NSLog(@"FPS : %.1f", 1 / (endTime - startTime));

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
