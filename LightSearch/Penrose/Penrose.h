//
//  Penrose.h
//  LightSearch
//
//  Created by Won-Young Sohn on 2014. 5. 6..
//  Copyright (c) 2014년 Won-Young Sohn. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "quasisampler_prototype.h"

@interface Radiance : NSObject

@property(nonatomic, weak)	float	R;
@property(nonatomic, weak)	float	G;
@property(nonatomic, weak)	float	B;
@property(nonatomic, weak)	float	Intensity;

@end


@interface Penrose : NSObject
{
	NSArray		*	m_radiance;
	float		*	m_data;
	float			m_sumIntensity;
}

@property(nonatomic, weak)	int			width;
@property(nonatomic, weak)	int			height;
@property(nonatomic, weak)	NSArray	*	sampledPoints;
@property(nonatomic, weak)	NSArray	*	mergedPoints;

- (void)initArray(int w, int h);
- (void)setRadianceMapWithEXP(int w, int h, unsigned char *src, unsigned char *dst);
- (void)gridSampling(int numWidth, int numHeight);
- (void)mergeSampledPoints(float minDistance);

@end
