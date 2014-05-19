//
//  Penrose.mm
//  LightSearch
//
//  Created by Won-Young Sohn on 2014. 5. 6..
//  Copyright (c) 2014년 Won-Young Sohn. All rights reserved.
//

#import "Penrose.h"

@implementation Radiance

@synthesize R, G, B, Intensity;

@end

@implementation Point2DWrapped

- (void)setX:(double)x
{
	_point2d->x = x;
}

- (void)setY:(double)y
{
	_point2d->y = y;
}

- (void)setSumX:(float)sumX
{
	_point2d->sumX = sumX;
}

- (void)setSumY:(float)sumY
{
	_point2d->sumY = sumY;
}

- (void)setCount:(int)count
{
	_point2d->count = count;
}

- (double)x
{
	return _point2d->x;
}

- (double)y
{
	return _point2d->y;
}

- (float)sumX
{
	return _point2d->sumX;
}

- (float)sumY
{
	return _point2d->sumY;
}

- (int)count
{
	return _point2d->count;
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
@synthesize width = _width, height = _height, points = _points, sampledPoints = _sampledPoints, mergedPoints = _mergedPoints, sourceImage = _sourceImage;

//penrose radiance mapping with exponential function.
- (void)setRadianceMapWithEXP:(int)w height:(int)h source:(unsigned char *)src dist:(unsigned char *)dst
{
	_width = w;
	_height = h;
	
	NSInteger pixels = _width * _height;
	
	m_radiance = [NSMutableArray new];
	m_data = [NSMutableArray new];
	
	unsigned char *ladybugData = src;
	
	int RGBSize = 3;
	
	for(int i=0; i<pixels; i++)
	{
		Radiance * radiance = [Radiance new];
		radiance.B = (float)ladybugData[i*RGBSize+0];
		radiance.G = (float)ladybugData[i*RGBSize+1];
		radiance.R = (float)ladybugData[i*RGBSize+2];
		
		//max = 22026.465795 - exp(10);
		
		// RGB weight Intensity
		//m_radiance[i].Intensity = (m_radiance[i].R*0.222 + m_radiance[i].G*0.707 + m_radiance[i].B*0.071) * weight;
		
		// greyscale변환
		radiance.Intensity = ((int)radiance.R >> 16 & 0xff) + ((int)radiance.B >> 8 & 0xff) + ((int)radiance.G & 0xff);
		
		//radiance exp함수 매핑
		float tempValue = exp((float)radiance.Intensity * 0.0390625);
		
		//광원 아님 - exp(0) ~ exp(3)
		if(tempValue < 20.085537 ){
			dst[i*3 + 0] = (float)tempValue * 12.74548;
			dst[i*3 + 1] = 0;
			dst[i*3 + 2] = 0;
		}
		//반사광 : exp(4) ~ exp(7)
		else if(tempValue >= 20.085537 && tempValue < 1096.633158 ){
			dst[i*3 + 0] = 0;
			dst[i*3 + 1] = tempValue * 0.2334417;
			dst[i*3 + 2] = 0;
		}
		//주광 : exp(8) ~ exp(10)
		else if(tempValue >= 1096.633158 && tempValue <= 28103.083928){
			dst[i*3 + 0] = 0;
			dst[i*3 + 1] = 0;
			dst[i*3 + 2] = tempValue * 0.00910932;
		}
		
		[m_radiance addObject:radiance];
		[m_data addObject:[NSNumber numberWithFloat:tempValue]];
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
	
	if([_sampledPoints count] > 0 || _sampledPoints == nil)
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
			
			float temp = [((NSNumber *)[m_data objectAtIndex:(y * _width + x)]) floatValue];
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

- (float)getDistance:(Point2DWrapped *)a to:(Point2DWrapped *)b
{
	float dist = 0.0;
	float diffX, diffY;
	diffX = diffY = 0.0;
	diffX = (b.x - a.x) * (b.x - a.x);
	diffY = (b.y - a.y) * (b.y - a.y);
	dist = sqrt(diffX + diffY);
	return dist;
}

- (int)getMinDistIndex:(Point2DWrapped *)srcPt
{
	float bestDist = _width;
	float tempDist = 0.0;
	Point2DWrapped	* curPt = [[Point2DWrapped alloc] initWithPointX:0 Y:0];
	int bestIndex = 0;
	for(int i=0; i<[_mergedPoints count]; i++){
		
		curPt = [_mergedPoints objectAtIndex:i];
		tempDist = [self getDistance:srcPt to:curPt];
		if(tempDist < bestDist){
			bestDist = tempDist;
			bestIndex = i;
		}
	}
	
	return bestIndex;
}

- (void)mergeSampledPoints:(float)minDistance
{
	if([_mergedPoints count] > 0 || _mergedPoints == nil)
		_mergedPoints = [NSMutableArray new];
	
	Point2DWrapped	*	curPt;
	Point2DWrapped	*	curMergePt;
	
	float diffX, diffY = 0.0;
	int minIndex;
	
	for(int i=0; i<[_sampledPoints count]; i++){
		
		curPt = [_sampledPoints objectAtIndex:i];
		
		if(i == 0){		//start
			curPt.count = 0;
			[_mergedPoints addObject:curPt];
		}
		else{
			minIndex = [self getMinDistIndex:curPt];
			curMergePt = [_mergedPoints objectAtIndex:minIndex];
			diffX = abs(curPt.x - curMergePt.x);
			diffY = abs(curPt.y - curMergePt.y);
			
			if(diffX < minDistance && diffY < minDistance*0.5)
			{
				//merged Point
				curMergePt.sumX += curPt.x;
				curMergePt.sumY += curPt.y;
				curMergePt.count++;
				curMergePt.x = curMergePt.sumX / curMergePt.count;
				curMergePt.y = curMergePt.sumY / curMergePt.count;
				
			}
			else{
				curPt.count = 0;
				[_mergedPoints addObject:curPt];
			}
		}
	}
	
	//final points
	if ([_points count] != 0 || _points == nil)
		_points = [NSMutableArray new];
	
	for (int i=0; i<[_mergedPoints count]; i++)
	{
		curPt = [_mergedPoints objectAtIndex:i];
		
		if (curPt.count >= 3)
			[_points addObject:curPt];
	}
}


- (void)drawSamplePoints:(IplImage *)image
{
	
	NSInteger numPoint1 = [self.sampledPoints count];
	NSInteger numPoint = [self.points count];
	NSLog(@"Sampled : %d\n", numPoint1);
	NSLog(@"Merged : %d\n", numPoint);
	
	int x, y;
	
	for (NSInteger i=0; i<numPoint1; i++)
	{
		Point2DWrapped * point = [self.sampledPoints objectAtIndex:i];
		x = point.x;
		y = point.y;
		
		cvCircle(image, cvPoint(x,y), 1, cvScalar(0,0,255),	1);
	}
	
	for (NSInteger i=0; i<numPoint; i++)
	{
		Point2DWrapped * point = [self.points objectAtIndex:i];
		x = point.x;
		y = point.y;
		
		cvCircle(image, cvPoint(x,y), 2, cvScalar(0,255,0), 2);
	}
}


- (void)drawSamplePointsMat:(Mat&)image
{
	NSInteger numPoint1 = [self.sampledPoints count];
	NSInteger numPoint = [self.points count];
	NSLog(@"Sampled : %d\n", numPoint1);
	NSLog(@"Merged : %d\n", numPoint);
	
	int x, y;
	
	for (NSInteger i=0; i<numPoint1; i++)
	{
		Point2DWrapped * point = [self.sampledPoints objectAtIndex:i];
		x = point.x;
		y = point.y;
		
		circle(image, cvPoint(x,y), 1, cvScalar(0,0,255));
	}
	
	for (NSInteger i=0; i<numPoint; i++)
	{
		Point2DWrapped * point = [self.points objectAtIndex:i];
		x = point.x;
		y = point.y;
		
		circle(image, cvPoint(x,y), 2, cvScalar(0,255,0));
	}
}

- (void)samplingWithIplImage:(IplImage *)orgImage andDistImage:(IplImage *)dstImage
{
	dstImage = cvCreateImage(cvSize(orgImage->width, orgImage->height), IPL_DEPTH_8U, 3);
	[self setRadianceMapWithEXP:orgImage->width height:orgImage->height source:(unsigned char*)orgImage->imageData dist:(unsigned char*)dstImage->imageData];
	[self gridSampling:91 height:45];
	[self mergeSampledPoints:40.0];
}

- (void)samplingWithMat:(Mat&)orgImage andDistMat:(Mat&)dstImage
{
	dstImage = orgImage.clone();
	[self setRadianceMapWithEXP:orgImage.cols height:orgImage.rows source:orgImage.data dist:dstImage.data];
	[self gridSampling:91 height:45];
	[self mergeSampledPoints:40.0];
}

@end
