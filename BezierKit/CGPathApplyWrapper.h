/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CGPathApplyWrapper : NSObject 

+ (NSArray *) bezierElementsFromCGPath:(CGPathRef)path;

@end
