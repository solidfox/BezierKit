/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "UIBezierPath-Points.h"

#define POINTSTRING(_CGPOINT_) (NSStringFromCGPoint(_CGPOINT_))
#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]
#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]

const unsigned kSteps = 20;

// Return distance between two points
static float distance (CGPoint p1, CGPoint p2)
{
	float dx = p2.x - p1.x;
	float dy = p2.y - p1.y;
	
	return sqrt(dx*dx + dy*dy);
}

@implementation UIBezierPath (Points)

void getPointsFromBezier(void *info, const CGPathElement *element)
{
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    if (type != kCGPathElementCloseSubpath)
    {
        if ((type == kCGPathElementAddLineToPoint) ||
            (type == kCGPathElementMoveToPoint))
            [bezierPoints addObject:VALUE(0)];
        else if (type == kCGPathElementAddQuadCurveToPoint) {
            [bezierPoints addObject:VALUE(1)];
        }
        else if (type == kCGPathElementAddCurveToPoint) {
            CGPoint origin;
            CGPoint originControl;
            CGPoint destinationControl;
            CGPoint destination;
            [[bezierPoints lastObject] getValue:&origin];
            originControl = points[0];
            destination = points[1];
            destinationControl = points[2];
            CGPoint* results;
            
            int nPoints = somePointsOfBezier(origin, originControl,
                                             destination, destinationControl,
                                             &results);
            
            for (int i = 0; i < nPoints; ++i) {
                NSValue *pointValue = [NSValue valueWithCGPoint:results[i]];
                [bezierPoints addObject:pointValue];
            }
            
            free(results);
            results = NULL;
        }
    }
}

/**
 *  Get kSteps+1 points on the bezier line. While distributed equally over t the points will not be equidistant since t is nonlinearly related to distance travelled on the path.
 *  Written by Rob Napier: http://robnapier.net/faster-bezier
 *
 *  @param origin             The point that the bezier segment originates from.
 *  @param originControl      The origins control point.
 *  @param destinationControl The destinations control point.
 *  @param destination        The point in which the bezier ends.
 *  @param results            A pointer to the place to put the array with the results. This array will need to be released using free(*results).
 *
 *  @return The number of points calculated.
 */
unsigned int somePointsOfBezier(CGPoint origin, CGPoint originControl,
                                CGPoint destinationControl, CGPoint destination,
                                CGPoint **results) {
    *results = malloc((kSteps + 1) * sizeof(struct CGPoint));
    
    static CGFloat C0[kSteps] = {0};
    static CGFloat C1[kSteps] = {0};
    static CGFloat C2[kSteps] = {0};
    static CGFloat C3[kSteps] = {0};
    static int sInitialized = 0;
    if (!sInitialized) {
        for (unsigned step = 0; step <= kSteps; ++step) {
            CGFloat t = (CGFloat)step/(CGFloat)kSteps;
            C0[step] = (1-t)*(1-t)*(1-t); // * origin
            C1[step] = 3 * (1-t)*(1-t) * t; // * originControl
            C2[step] = 3 * (1-t) * t*t; // * destinationControl
            C3[step] = t*t*t; // * destination;
        }
        sInitialized = 1;
    }
    
    for (unsigned step = 0; step <= kSteps; ++step) {
        CGPoint point = {
            C0[step]*origin.x + C1[step]*originControl.x + C2[step]*destinationControl.x + C3[step]*destination.x,
            C0[step]*origin.y + C1[step]*originControl.y + C2[step]*destinationControl.y + C3[step]*destination.y
        };
        (*results)[step] = point;
    }
    return kSteps + 1;
}

- (NSArray *)points
{
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(self.CGPath, (__bridge void *)points, getPointsFromBezier);
    return points;
}

// Return a Bezier path built with the supplied points
+ (UIBezierPath *) pathWithPoints: (NSArray *) points
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (points.count == 0) return path;
    [path moveToPoint:POINT(0)];
    for (int i = 1; i < points.count; i++)
        [path addLineToPoint:POINT(i)];
    return path;
}

- (CGFloat) length
{
    NSArray *points = self.points;
    float totalPointLength = 0.0f;
    for (int i = 1; i < points.count; i++)
        totalPointLength += distance(POINT(i), POINT(i-1));
    return totalPointLength;
}

- (NSArray *) pointPercentArray
{
    // Use total length to calculate the percent of path consumed at each control point
    NSArray *points = self.points;
    int pointCount = (int)points.count;
    
    float totalPointLength = self.length;
    float distanceTravelled = 0.0f;
    
	NSMutableArray *pointPercentArray = [NSMutableArray array];
	[pointPercentArray addObject:@(0.0)];
    
	for (int i = 1; i < pointCount; i++)
	{
		distanceTravelled += distance(POINT(i), POINT(i-1));
		[pointPercentArray addObject:@(distanceTravelled / totalPointLength)];
	}
	
	// Add a final item just to stop with. Probably not needed.
	[pointPercentArray addObject:[NSNumber numberWithFloat:1.1f]]; // 110%
    
    return pointPercentArray;
}

- (CGPoint) pointAtPercent: (CGFloat) percent withSlope: (CGPoint *) slope
{
    NSArray *points = self.points;
    NSArray *percentArray = self.pointPercentArray;
    CFIndex lastPointIndex = points.count - 1;
    
    if (!points.count)
        return CGPointZero;
    
    // Check for 0% and 100%
    if (percent <= 0.0f) return POINT(0);
    if (percent >= 1.0f) return POINT(lastPointIndex);

    // Find a corresponding pair of points in the path
    CFIndex index = 1;
    while ((index < percentArray.count) &&
           (percent > ((NSNumber *)percentArray[index]).floatValue))
        index++;
    
    // This should not happen.
    if (index > lastPointIndex) return POINT(lastPointIndex);
    
    // Calculate the intermediate distance between the two points
    CGPoint point1 = POINT(index -1);
    CGPoint point2 = POINT(index);
    
    float percent1 = [[percentArray objectAtIndex:index - 1] floatValue];
    float percent2 = [[percentArray objectAtIndex:index] floatValue];
    float percentOffset = (percent - percent1) / (percent2 - percent1);
    
    float dx = point2.x - point1.x;
    float dy = point2.y - point1.y;
    
    // Store dy, dx for retrieving arctan
    if (slope) *slope = CGPointMake(dx, dy);
    
    // Calculate new point
    CGFloat newX = point1.x + (percentOffset * dx);
    CGFloat newY = point1.y + (percentOffset * dy);
    CGPoint targetPoint = CGPointMake(newX, newY);
    
    return targetPoint;
}

void getBezierElements(void *info, const CGPathElement *element)
{
    NSMutableArray *bezierElements = (__bridge NSMutableArray *)info;
    CGPathElementType type = element->type;
    CGPoint *points = element->points;

    switch (type)
    {
        case kCGPathElementCloseSubpath:
            [bezierElements addObject:@[@(type)]];
            break;
        case kCGPathElementMoveToPoint:
        case kCGPathElementAddLineToPoint:
            [bezierElements addObject:@[@(type), VALUE(0)]];
            break;
        case kCGPathElementAddQuadCurveToPoint:
            [bezierElements addObject:@[@(type), VALUE(0), VALUE(1)]];
            break;
        case kCGPathElementAddCurveToPoint:
            [bezierElements addObject:@[@(type), VALUE(0), VALUE(1), VALUE(2)]];
            break;
    }   
}

- (NSArray *) bezierElements
{
    NSMutableArray *elements = [NSMutableArray array];
    CGPathApply(self.CGPath, (__bridge void *)elements, getBezierElements);
    return elements;
}

+ (UIBezierPath *) pathWithElements: (NSArray *) elements
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (elements.count == 0) return path;
    
    for (NSArray *points in elements)
    {
        if (!points.count) continue;
        CGPathElementType elementType = [points[0] integerValue];
        switch (elementType)
        {
            case kCGPathElementCloseSubpath:
                [path closePath];
                break;
            case kCGPathElementMoveToPoint:
                if (points.count == 2)
                    [path moveToPoint:POINT(1)];
                break;
            case kCGPathElementAddLineToPoint:
                if (points.count == 2)
                    [path addLineToPoint:POINT(1)];
                break;
            case kCGPathElementAddQuadCurveToPoint:
                if (points.count == 3)
                    [path addQuadCurveToPoint:POINT(2) controlPoint:POINT(1)];
                break;
            case kCGPathElementAddCurveToPoint:
                if (points.count == 4)
                    [path addCurveToPoint:POINT(3) controlPoint1:POINT(1) controlPoint2:POINT(2)];
                break;
        }
    }
    
    return path;
}
@end
