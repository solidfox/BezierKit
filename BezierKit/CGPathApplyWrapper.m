/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "CGPathApplyWrapper.h"

@implementation CGPathApplyWrapper

void _getBezierElements(void *info, const CGPathElement *element)
{
    NSMutableArray *bezierElements = (__bridge NSMutableArray *)info;
    CGPathElementType type = element->type;
    CGPoint *points = element->points;

    switch (type)
    {
        case kCGPathElementCloseSubpath:
            break;
        case kCGPathElementMoveToPoint:
        case kCGPathElementAddLineToPoint:
            [bezierElements addObject:@[[NSValue valueWithCGPoint:points[0]]]];
            break;
        case kCGPathElementAddQuadCurveToPoint:
            [bezierElements addObject:@[[NSValue valueWithCGPoint:points[0]],
                                        [NSValue valueWithCGPoint:points[1]]]];
            break;
        case kCGPathElementAddCurveToPoint:
            [bezierElements addObject:@[[NSValue valueWithCGPoint:points[0]],
                                        [NSValue valueWithCGPoint:points[1]],
                                        [NSValue valueWithCGPoint:points[2]]]];
            break;
    }   
}

+ (NSArray *)bezierElementsFromCGPath:(CGPathRef)path
{
    NSMutableArray *elements = [NSMutableArray array];
    CGPathApply(path, (__bridge void *)elements, _getBezierElements);
    return elements;
}

@end
