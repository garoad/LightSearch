//
//  Penrose.mm
//  LightSearch
//
//  Created by Won-Young Sohn on 2014. 5. 6..
//  Copyright (c) 2014년 Won-Young Sohn. All rights reserved.
//

#import "Penrose.h"

@implementation Point2DWrapped

- (void)setX:(double)x
{
	_point2d->x = x;
}

- (void)setY:(double)y
{
	_point2d->y = y;
}

- (double)x
{
	return _point2d->x;
}

- (double)y
{
	return _point2d->y;
}

- (id)initWithPointX:(double)x Y:(double)y
{
	if (self = [super init])
	{
		_point2d = new Point2D(x, y);
	}
	
	return self;
}

@end

@implementation Penrose
@synthesize width = _width, height = _height, sampledPoints = _sampledPoints, mergedPoints = _mergedPoints, sourceImage = _sourceImage;

//penrose radiance mapping with exponential function.
- (void)setRadianceMapWithEXP:(int)w height:(int)h source:(unsigned char *)src dist:(unsigned char *)dst
{
	_width = w;
	_height = h;
	
	unsigned char *ladybugData = src;
	int pixels = _width * _height;
	
	int RGBSize = 3;
	
	for(int i=0; i<pixels; i++)
	{
		((Radiance *)[m_radiance objectAtIndex:i]).B = (float)ladybugData[i*RGBSize+0];
		((Radiance *)[m_radiance objectAtIndex:i]).G = (float)ladybugData[i*RGBSize+1];
		((Radiance *)[m_radiance objectAtIndex:i]).R = (float)ladybugData[i*RGBSize+2];
		
		//max = 22026.465795 - exp(10);
		
		// RGB weight Intensity
		//m_radiance[i].Intensity = (m_radiance[i].R*0.222 + m_radiance[i].G*0.707 + m_radiance[i].B*0.071) * weight;
		
		// greyscale변환
		((Radiance *)[m_radiance objectAtIndex:i]).Intensity = (((int)((Radiance *)[m_radiance objectAtIndex:i]).R >> 16 & 0xff) + ((int)((Radiance *)[m_radiance objectAtIndex:i]).B >> 8 & 0xff) + ((int)((Radiance *)[m_radiance objectAtIndex:i]).G & 0xff));
		
		//radiance exp함수 매핑
		m_data[i] = exp((float)((Radiance *)[m_radiance objectAtIndex:i]).Intensity * 0.0390625);
		
		//광원 아님 - exp(0) ~ exp(3)
		if(m_data[i] < 20.085537 ){
			dst[i*3 + 0] = (float)m_data[i] * 12.74548;
			dst[i*3 + 1] = 0;
			dst[i*3 + 2] = 0;
		}
		//반사광 : exp(4) ~ exp(7)
		else if(m_data[i] >= 20.085537 && m_data[i] < 1096.633158 ){
			dst[i*3 + 0] = 0;
			dst[i*3 + 1] = (float)m_data[i] * 0.2334417;
			dst[i*3 + 2] = 0;
		}
		//주광 : exp(8) ~ exp(10)
		else if(m_data[i] >= 1096.633158 && m_data[i] <= 28103.083928){
			dst[i*3 + 0] = 0;
			dst[i*3 + 1] = 0;
			dst[i*3 + 2] = (float)m_data[i] * 0.00910932;
		}
	}
}


- (void)gridSampling:(int)numWidth height:(int) numHeight
{
	float pitchX, pitchY;
	pitchX = (float)_width / numWidth;
	pitchY = (float)_height / numHeight;
	
	//random 시드
	srand(clock());
	
	int x, y = 0;
	
	if([_sampledPoints count] != 0)
		_sampledPoints = [NSMutableArray new];
	
	for(int i=0; i<numWidth; i++){
		for(int j = 0; j<numHeight; j++){
			
			x = (float)pitchX * i;
			y = (float)pitchY * j;
			
			//random 요소
			float rndX = (float)rand() / RAND_MAX;
			float rndY = (float)rand() / RAND_MAX;
			
			x += rndX*pitchX * 0.2;
			y += rndY*pitchY * 0.2;
			
			//test
			//Point2D tempPoint(x, y);
			//m_sampledPoints.push_back(tempPoint);
			//printf("%f ", m_data[y * m_width + x]);
			
			float temp = m_data[y * _width + x];
			//광원 아님 - exp(0) ~ exp(3)
			if( temp < 20.085537 ){
				//do nothing
			}
			//반사광 : exp(4) ~ exp(7)
			else if( temp >= 20.085537 && temp < 1096.633158 ){
				//do nothing
			}
			//주광 : exp(8) ~ exp(10)
			else if( temp >= 1096.633158 && temp <= 28103.083928){
				Point2DWrapped * tempPoint = [[Point2DWrapped alloc] initWithPointX:x Y:y];
				[_sampledPoints addObject:tempPoint];
			}
		}
	}
}

- (void)mergeSampledPoints:(float)minDistance
{
	
}


@end
