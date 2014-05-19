//
//  CamSearchViewController.h
//  LightSearch
//
//  Created by Won-Young Sohn on 2014. 5. 18..
//  Copyright (c) 2014년 Won-Young Sohn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/ios.h>

using namespace cv;

@interface CamSearchViewController : UIViewController <CvVideoCameraDelegate>
{

}

@property(nonatomic, strong) IBOutlet UIImageView		*	imageView;
@property(nonatomic, strong) IBOutlet UILabel			*	fpsLabel;
@property(nonatomic, strong)		  CvVideoCamera		*	videoCamera;

@end
