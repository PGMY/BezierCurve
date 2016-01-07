//
//  BezierCurveView.m
//  BezierCurve
//
//  Created by Mika Yamamoto on 2015/02/19.
//  Copyright (c) 2015年 PGMY. All rights reserved.
//

#import "BezierCurveView.h"

@interface BezierCurveView () {
    UIView *v;
}
@property (nonatomic, retain) NSMutableArray *paths;
@property (nonatomic, retain) NSMutableArray *points;
@end

@implementation BezierCurveView
{
    UIBezierPath *path;
    UIImage *incrementalImage;
    CGPoint pts[5]; // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
    uint ctr;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setMultipleTouchEnabled:NO];
        [self setBackgroundColor:[UIColor whiteColor]];
        path = [UIBezierPath bezierPath];
        [path setLineWidth:2.0];
    }
    return self;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor greenColor];
        [self setMultipleTouchEnabled:NO];
        path = [UIBezierPath bezierPath];
        [path setLineWidth:2.0];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [incrementalImage drawInRect:rect];
    [path stroke];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ctr = 0;
    UITouch *touch = [touches anyObject];
    pts[0] = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    ctr++;
    pts[ctr] = p;
    if (ctr == 4)
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
        
        [path moveToPoint:pts[0]];
        [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
        
        [self setNeedsDisplay];
        // replace points and get ready to handle the next segment
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self drawBitmap];
    [self setNeedsDisplay];
    [path removeAllPoints];
    ctr = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)drawBitmap
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    
    if (!incrementalImage) // first time; paint background white
    {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [[UIColor whiteColor] setFill];
        [rectpath fill];
    }
    [incrementalImage drawAtPoint:CGPointZero];
    [[UIColor blackColor] setStroke];
    [path stroke];
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}


//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self setBackgroundColor:[UIColor clearColor]];
//        _paths  = [[NSMutableArray alloc] init];
//        _points = [[NSMutableArray alloc] init];
//        
//        // 点の準備
//        [_points addObject:[NSValue valueWithCGPoint:CGPointMake(50.0f,  150.0f)]];
//        [_points addObject:[NSValue valueWithCGPoint:CGPointMake(150.0f, 110.0f)]];
//        [_points addObject:[NSValue valueWithCGPoint:CGPointMake(250.0f, 140.0f)]];
//        [_points addObject:[NSValue valueWithCGPoint:CGPointMake(200.0f, 270.0f)]];
//        [_points addObject:[NSValue valueWithCGPoint:CGPointMake(120.0f, 210.0f)]];
//        [_points addObject:[NSValue valueWithCGPoint:CGPointMake(170.0f, 170.0f)]];
//        
//        v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//        v.backgroundColor = [UIColor orangeColor];
//        [self addSubview:v];
//    }
//    return self;
//}
//
//
//- (void)drawRect:(CGRect)rect {
//    [self drawLine];
//    [self drawCurveLine];
//    [self drawPoint];
//}

- (void)drawPoint
{
    [[UIColor whiteColor] setFill];
    [[UIColor blackColor] setStroke];
    for (int i = 0 ; i < _points.count ; i++) {
        CGPoint point = [[_points objectAtIndex:i] CGPointValue];
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth     = 1.0f;
        [path addArcWithCenter:point radius:3.0f startAngle:0 endAngle:360 clockwise:YES];
        [path fill];
        [path stroke];
    }
}
- (void)drawLine
{
    [[UIColor blueColor] setStroke];
    for (int i = 0 ; i < _points.count - 1 ; i++) {
        CGPoint point      = [[_points objectAtIndex:i] CGPointValue];
        CGPoint nextPoint  = [[_points objectAtIndex:i + 1] CGPointValue];
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth     = 2.0f;
        [path moveToPoint:point];
        [path addLineToPoint:nextPoint];
        [path stroke];
    }
}

- (void)drawCurveLine
{
    CGFloat lineWidth = 3.0f;
    [[UIColor redColor] setStroke];
    
    // 始点から次の点の中間点までを直線で描画
    CGPoint firstMovePoint    = [[_points firstObject] CGPointValue];
    CGPoint firstAddLinePoint = [[_points objectAtIndex:1] CGPointValue];
    UIBezierPath *path        = [UIBezierPath bezierPath];
    path.lineWidth            = lineWidth;
    [path moveToPoint:firstMovePoint];
    [path addLineToPoint:[self midPoint:firstMovePoint :firstAddLinePoint]];
    [path stroke];
    [_paths addObject:path];
    
    // 曲線描画
    for (int i = 2 ; i < _points.count ; i++) {
        UIBezierPath *path     = [UIBezierPath bezierPath];
        path.lineWidth         = lineWidth;
        CGPoint previousPoint2 = [[_points objectAtIndex:i - 2] CGPointValue];
        CGPoint previousPoint1 = [[_points objectAtIndex:i - 1] CGPointValue];
        CGPoint currentPoint   = [[_points objectAtIndex:i] CGPointValue];
        // ２つ前の中間点
        CGPoint mid1           = [self midPoint:previousPoint1: previousPoint2];
        // １つ前の中間点
        CGPoint mid2           = [self midPoint:currentPoint: previousPoint1];
        // ２つ前の中間点から
        [path moveToPoint:mid1];
        // １つ前の点を支点として、１つ前の中間点まで描画
        [path addQuadCurveToPoint:mid2 controlPoint:previousPoint1];
        [path stroke];
        [_paths addObject:path];
    }
    
    // 終点の一つ前から、終点までの中間点を直線で描画
    CGPoint endMovePoint    = [[_points objectAtIndex:_points.count - 2] CGPointValue];
    CGPoint endAddLinePoint = [[_points lastObject] CGPointValue];
    path                    = [UIBezierPath bezierPath];
    path.lineWidth          = lineWidth;
    [path moveToPoint:[self midPoint:endMovePoint :endAddLinePoint]];
    [path addLineToPoint:endAddLinePoint];
    [path stroke];
    [_paths addObject:path];
}

// 点と点の中間点を返す
- (CGPoint) midPoint:(CGPoint) p1 :(CGPoint) p2
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

- (void)startAnimation
{
    // 曲線パスを合成する
    UIBezierPath *path = [UIBezierPath bezierPath];
    [_paths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [path appendPath:obj];
    }];
    
    // パスに沿ってUIImageViewをアニメーションさせる
    CAKeyframeAnimation *animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = 3.0;
    animation.path = path.CGPath;
    [v.layer addAnimation:animation forKey:nil];
}


@end
