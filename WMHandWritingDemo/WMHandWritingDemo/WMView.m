//
//  WMView.m
//  titleDemo
//
//  Created by WM on 2017/3/23.
//  Copyright © 2017年 wumian. All rights reserved.
//

#import "WMView.h"
#import <CoreText/CoreText.h>


@interface WMView()<CAAnimationDelegate>

/// 字迹图层
@property(nonatomic,strong)CAShapeLayer *pathLayer;

/// 字迹动画的时间
@property(nonatomic,assign)NSTimeInterval textAnimationTime;

 /// 渐变色layer
@property(nonatomic,strong)CAGradientLayer *gradientLayer;

/// 动画
@property(nonatomic,strong)CABasicAnimation *textAnimation;


@end

@implementation WMView

- (CAShapeLayer *)pathLayer{
    if (_pathLayer == nil) {
        _pathLayer = [CAShapeLayer layer];
    }
    return _pathLayer;
}

- (CAGradientLayer *)gradientLayer{
    if (_gradientLayer == nil) {
        _gradientLayer = [CAGradientLayer layer];
    }
    return _gradientLayer;
}

- (instancetype)initWithFrame:(CGRect)rect message:(NSString *)message{
    if (self = [super initWithFrame:rect]) {
        [self show:message];
    }
    return self;
}

- (void)show:(NSString *)string{
    
    self.textAnimationTime = 5;
    
    // 添加渐变色layer以及动画
    [self addGradientLayer];
    
    // 添加文字动画
    [self addPathLayer:string];
    
    //添加gradientLayer的遮罩
    self.gradientLayer.mask = self.pathLayer;
}

/**
 添加渐变色的layer 和动画
 */
- (void)addGradientLayer{
    int count = 10;
    
    NSMutableArray *colors = [NSMutableArray array];
    
    UIColor *topColor = [UIColor colorWithRed:(91.0/255.0) green: (91.0/255.0) blue:(91.0/255.0) alpha:1];
    
    UIColor *buttomColor = [UIColor colorWithRed:(24.0/255.0) green:(24.0/255.0) blue:(24.0/255.0) alpha:1];
    
    NSMutableArray *gradientColors = [NSMutableArray arrayWithArray:@[topColor,buttomColor]];
    
    for (int i =0; i<count; i++) {
        UIColor *color  = [UIColor colorWithRed:arc4random_uniform(255.0) / 255.0 green:arc4random_uniform(255.0) / 255.0 blue:arc4random_uniform(255.0) / 255.0 alpha:1];
        [colors addObject:color];
    }
    NSLog(@"%@",gradientColors);
    
    // 渐变色的方向
    self.gradientLayer.startPoint = CGPointMake(0, 0.5);
    self.gradientLayer.endPoint = CGPointMake(1, 0.5);
    self.gradientLayer.colors = @[(__bridge id)topColor.CGColor,
                                  (__bridge id)buttomColor.CGColor];
    self.gradientLayer.frame = self.bounds;
    self.gradientLayer.type = kCAGradientLayerAxial;
    [self.layer addSublayer:self.gradientLayer];
    
    
    
    // 渐变色的动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"colors"];
    animation.duration = 0.5;
    animation.repeatCount = MAXFLOAT;
    
    NSMutableArray *toColors =  [NSMutableArray array];
    
    for (int i=0; i<count; i++) {
        UIColor *color  = [UIColor colorWithRed:arc4random_uniform(256.0) / 255.0 green:arc4random_uniform(256.0) / 255.0 blue:arc4random_uniform(256.0) / 255.0 alpha:1];
        [toColors addObject:(__bridge id)color.CGColor];
    }
    animation.autoreverses = true;
    animation.toValue = toColors;
    [self.gradientLayer addAnimation:animation forKey:@"gradientLayer"];
}

/**
 添加笔迹的动画
 - parameter message: 显示的文字
 */
- (void)addPathLayer:(NSString *)string{
    UIBezierPath *textPath = [self bezierPathFrom:string];
    self.pathLayer.bounds = CGPathGetBoundingBox(textPath.CGPath);
    self.pathLayer.position = self.gradientLayer.position;
    self.pathLayer.geometryFlipped = YES;
    self.pathLayer.path = textPath.CGPath;
    self.pathLayer.fillColor = nil;
    self.pathLayer.lineWidth = 1;
    self.pathLayer.strokeColor = [UIColor blackColor].CGColor;
    
    // 笔迹的动画
    CABasicAnimation *textAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    textAnimation.duration = self.textAnimationTime;
    textAnimation.fromValue = @(0);
    textAnimation.toValue = @(1);
    self.textAnimation = textAnimation;
    textAnimation.delegate = self;
    [self.pathLayer addAnimation:textAnimation forKey:@"strokeEnd"];
}


/**
 将字符串转变成贝塞尔曲线
 */
- (UIBezierPath *)bezierPathFrom:(NSString *)string{
    CGMutablePathRef paths = CGPathCreateMutable();
    CFStringRef fontName = __CFStringMakeConstantString("MFTongXin_Noncommercial-Regular");
      
    NSString *strNS = (__bridge NSString *)fontName;
    NSLog(@"%@",strNS);
    
    CTFontRef fontRef = CTFontCreateWithName(fontName, 50, nil);
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string                                                                     attributes:@{(NSString*)kCTFontAttributeName:(__bridge id)fontRef}];
   
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    
    CFArrayRef runA = CTLineGetGlyphRuns(line);
    
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runA); runIndex++) {
        
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runA, runIndex);
        
        CTFontRef runFontC = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        
        int temp = 0;
        
        CGFloat offset = 0.0;
        
        //具体的笔画
        for (CFIndex i = 0; i< CTRunGetGlyphCount(run); i++) {
            
            CFRange range = CFRangeMake(i, 1);
            
            CGGlyph glyph = 0;
            
            CGPoint position = CGPointZero;
            
            CTRunGetGlyphs(run, range, &glyph);
            
            CTRunGetPositions(run, range, &position);
            
            CGFloat temp3 = position.x;
    
            CGFloat temp2 = (int)(temp3 / width);
            
            CGFloat temp1 =0;
            
            if(temp2 > temp1){
                
                temp = temp2 ;
                
                offset = position.x - ((CGFloat)temp * width);
            }
                CGPathRef path = CTFontCreatePathForGlyph(runFontC, glyph, nil);
            
                CGFloat x = position.x - ((CGFloat)temp * width) - offset ;
            
                CGFloat y = position.y - ((CGFloat)temp * 80);
            
                CGAffineTransform transform = CGAffineTransformMakeTranslation(x, y);
            
                CGPathAddPath(paths, &transform, path);
            }
        }
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointZero];
    [bezierPath appendPath:[UIBezierPath bezierPathWithCGPath:paths]];
    
    return bezierPath;
}

@end






