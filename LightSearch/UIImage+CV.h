//
//  UIImage+CV.h
//  LightSearch
//
//  Created by Won-Young Sohn on 2014. 5. 19..
//  Copyright (c) 2014년 Won-Young Sohn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CV)

+ (IplImage *)IplImageFromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromIplImage:(IplImage *)image;

@end
