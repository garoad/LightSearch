//
//  Penrose.h
//  LightSearch
//
//  Created by Won-Young Sohn on 2014. 5. 6..
//  Copyright (c) 2014년 Won-Young Sohn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/highgui/ios.h>
#include "quasisampler_prototype.h"

@interface Radiance : NSObject

@property(nonatomic, assign)	float	R;
@property(nonatomic, assign)	float	G;
@property(nonatomic, assign)	float	B;
@property(nonatomic, assign)	float	Intensity;

@end


@interface Point2DWrapped : NSObject
{
	Point2D	*	_point2d;
}

@property(nonatomic, assign)	double	x;
@property(nonatomic, assign)	double	y;
@property(nonatomic, assign)	float	sumX;
@property(nonatomic, assign)	float	sumY;
@property(nonatomic, assign)	int		count;

- (id)initWithPointX:(double)x Y:(double)y;
@end


@interface Penrose : NSObject
{
	NSMutableArray	*	m_radiance;
	NSMutableArray	*	m_data;
	float				m_sumIntensity;
}

@property(nonatomic, assign)	int						width;
@property(nonatomic, assign)	int						height;
@property(nonatomic, strong)	NSMutableArray		*	points;
@property(nonatomic, strong)	NSMutableArray		*	sampledPoints;
@property(nonatomic, strong)	NSMutableArray		*	mergedPoints;
@property(nonatomic, assign)	IplImage			*	sourceImage;

- (void)samplingWithIplImage:(IplImage *)orgImage andDistImage:(IplImage *)dstImage;
- (void)drawSamplePoints:(IplImage *)image;
- (void)setRadianceMapWithEXP:(int)w height:(int)h source:(unsigned char *)src dist:(unsigned char *)dst;
- (void)gridSampling:(int)numWidth height:(int) numHeight;
- (void)mergeSampledPoints:(float)minDistance;

@end
