//
//  Chart.m
//  Core Graphics
//
//  Created by Tasos Tsolis on 29/8/16.
//  Copyright © 2016 Tasos Tsolis. All rights reserved.
//

#import "Chart.h"

#define DEFAULT_TOP_OFFSET_Y 40
#define DEFAULT_BOTTOM_OFFSET_Y 45

@interface Chart ()

@property (assign, nonatomic) CGFloat leadingOffsetX;
@property (assign, nonatomic) CGFloat trailingOffsetX;
@property (assign, nonatomic) CGFloat topOffsetY;
@property (assign, nonatomic) CGFloat bottomOffsetY;


@property (strong, nonatomic) NSArray *xCoordinates;
@property (strong, nonatomic) NSArray *yCoordinates;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIColor *color;

@end

@implementation Chart

#pragma mark - initializers

- (instancetype)init {
    self = [super init];
    if (self) {
        [self defaultSetup];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultSetup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self defaultSetup];
    }
    return self;
}

#pragma mark helper

- (void)defaultSetup {
    self.startColor = [UIColor whiteColor];
    self.endColor = [UIColor orangeColor];
    self.axesColor = [UIColor blackColor];
    self.linesColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    
    self.verticalAxeTitle = @"Axe y";
    self.horizontalAxeTitle = @"Axe x";
    
    self.numberOfHorizontalLines = 4;
    self.numberOfVerticalLines = 6;
    
    
    self.drawBackgroundGradient = YES;
    self.drawGradientUnderGraph = NO;
    self.lineEdgesHasCircles = YES;
    
    self.topOffsetY = DEFAULT_TOP_OFFSET_Y;
    self.bottomOffsetY = DEFAULT_BOTTOM_OFFSET_Y;
    
    [self defaultData];
}

- (void)defaultData {
    NSArray *xCoordinates = @[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12, @13, @14, @15, @16, @17, @18, @19, @20, @21, @22, @23, @24, @25, @26, @27, @28, @29, @30, @31];
    NSArray *array1 = @[@2, @5, @10, @8, @5, @10, @7, @12, @9, @4, @2, @5, @10, @8, @5, @10, @7, @12, @9, @4, @2, @5, @10, @8, @5, @10, @7, @12, @9, @4];
    NSArray *array2 = @[@4, @2, @6, @4, @5, @8, @3, @4, @2, @6, @4, @5, @8, @3, @3,@4, @2, @6, @4, @5, @8, @3, @4, @2, @6, @4, @5, @8, @3, @3];
    NSArray *array3 = @[@6, @4, @5, @8, @3, @4, @7, @14, @9, @4,@6, @4, @5, @8, @3, @4, @7, @12, @8, @4,@6, @4, @5, @8, @3, @4, @7, @12, @9, @4];
    self.graphs = @[@{@"xCoordinates":xCoordinates, @"yCoordinates":array1, @"name":@"Work", @"color":[UIColor greenColor]},
                    @{@"xCoordinates":xCoordinates, @"yCoordinates":array2, @"name":@"Tennis", @"color":[UIColor yellowColor]},
                    @{@"xCoordinates":xCoordinates, @"yCoordinates":array3, @"name":@"Free Time", @"color":[UIColor blueColor]}];
}

#pragma mark - Draw Rect

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self setupLeadingAndTrailingOffsets];
    [self setupBackgroundGradientWitContext:context];
    [self setupAxes];
    [self setupVerticalLinesAndLabels];
    [self setupHorizontalLinesAndLabels];
    [self setupGraphPathToContext:context];
}

#pragma mark - Setups

-(void)setupLeadingAndTrailingOffsets {
    CGFloat maxValueWidth = 0;
    CGFloat maxNameWidth = 0;
    
    for (NSDictionary *graph in self.graphs) {
        self.title = [NSString stringWithString: [graph objectForKey:@"name"]];
        self.yCoordinates = [graph objectForKey:@"yCoordinates"];
        
        CGFloat maxValueOfGraph = [self maxYCoordinate];
        UILabel *maxValueLabel = [[UILabel alloc] init];
        maxValueLabel.font = [UIFont systemFontOfSize:13.0];
        maxValueLabel.text = [NSString stringWithFormat:@"%d", (int)maxValueOfGraph];
        CGSize size =  [maxValueLabel intrinsicContentSize];
        if (size.width > maxValueWidth) {
            maxValueWidth = size.width;
        }
        
        UILabel *title = [[UILabel alloc] init];
        title.font = [UIFont systemFontOfSize:13.0];
        title.text = self.title;
        CGSize titleSize =  [title intrinsicContentSize];
        if (titleSize.width > maxNameWidth) {
            maxNameWidth = titleSize.width;
        }
    }
    
    // Leading offset x
    if (maxValueWidth < 72.5) {     // 2.5 + 20 + 2.5 + width + 2.5 = 100 ->> max Label Width = 72.5.
        self.leadingOffsetX = 2.5 + 20 + 2.5 + maxValueWidth +2.5;
    } else {
        self.leadingOffsetX = 100.0;
    }
    
    // Trailing offset x
    if (maxNameWidth < 70) {     // 5.0 + width + 5.0 = 80 ->> max Label Width = 80.
        self.trailingOffsetX = 5.0 + maxNameWidth + 5.0;
    } else {
        self.trailingOffsetX = 80;
    }
}

- (void)setupBackgroundGradientWitContext:(CGContextRef)context {
    if (!self.drawBackgroundGradient) {
        return;
    }
    
    NSArray *colors = @[(id)self.startColor.CGColor, (id)self.endColor.CGColor];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat colorLocations[2] = { 0.0, 1.0};
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, colorLocations);
    
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointMake(0, self.bounds.size.height);
    
    CGContextDrawLinearGradient(context,
                                gradient,
                                startPoint,
                                endPoint,
                                0);
}

-(void)setupAxes {
    CGRect chartBounds = CGRectMake(self.leadingOffsetX, self.topOffsetY, (self.frame.size.width - self.trailingOffsetX), (self.frame.size.height - self.bottomOffsetY));
    
    UIBezierPath *axes = [UIBezierPath bezierPath];
    [self.axesColor setStroke];
    axes.lineWidth = 2.0;
    [axes moveToPoint:chartBounds.origin];
    [axes addLineToPoint:CGPointMake(self.leadingOffsetX, self.frame.size.height - self.bottomOffsetY)];
    [axes addLineToPoint:CGPointMake(self.frame.size.width - self.trailingOffsetX, self.frame.size.height - self.bottomOffsetY)];
    [axes stroke];
}

-(void)setupVerticalLinesAndLabels {
    UIBezierPath *verticalLines = [UIBezierPath bezierPath];
    verticalLines.lineWidth = 1.0;
    [self.linesColor setStroke];
    
    UILabel *zeroLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 13)];
    zeroLabel.center = CGPointMake(self.leadingOffsetX, self.frame.size.height - 2.5 - 18 - 2.5 - zeroLabel.frame.size.height/2);
    zeroLabel.text = @"0";
    zeroLabel.font = [UIFont systemFontOfSize:13.0];
    zeroLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:zeroLabel];
    
    
    for (int i = 1 ; i < self.numberOfVerticalLines + 1; i++) {
        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 13)];
        valueLabel.center = CGPointMake([self xCoordinateForLine:i], self.frame.size.height - 2.5 - 18 - 2.5 - valueLabel.frame.size.height/2);
        valueLabel.text = [self xLabelForLine:i];
        valueLabel.font = [UIFont systemFontOfSize:13.0];
        valueLabel.adjustsFontSizeToFitWidth = YES;
        valueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:valueLabel];
        
        [verticalLines moveToPoint:CGPointMake([self xCoordinateForLine:i], self.topOffsetY)];
        [verticalLines addLineToPoint:CGPointMake([self xCoordinateForLine:i], self.frame.size.height - self.bottomOffsetY)];
    }
    
    [verticalLines stroke];
    
    UILabel *horizontalTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.height - self.topOffsetY - self.bottomOffsetY, 20)];
    CGFloat graphWidth = self.frame.size.width - self.leadingOffsetX - self.trailingOffsetX;
    CGFloat graphCenterX = self.leadingOffsetX + graphWidth/2;
    CGFloat graphCenterY = self.frame.size.height - 2.5 - horizontalTitle.frame.size.height/2;
    horizontalTitle.center = CGPointMake(graphCenterX, graphCenterY);
    horizontalTitle.text = self.horizontalAxeTitle;
    horizontalTitle.font = [UIFont systemFontOfSize:15.0 weight:5.0];
    horizontalTitle.textAlignment = NSTextAlignmentCenter;
    [self addSubview:horizontalTitle];
}

-(void)setupHorizontalLinesAndLabels {
    UIBezierPath *horizontalLines = [UIBezierPath bezierPath];
    horizontalLines.lineWidth = 1.0;
    [self.linesColor setStroke];
    
    for (int i = 1 ; i < self.numberOfHorizontalLines + 1; i++) {
        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (self.leadingOffsetX -2.5- 20 -2.5 - 2.5), 20)];
        valueLabel.center = CGPointMake(self.leadingOffsetX - valueLabel.frame.size.width/2 - 2.5, [self yCoordinateForline:i]);
        valueLabel.text = [self yLabelForLine:i];
        valueLabel.font = [UIFont systemFontOfSize:13.0];
        valueLabel.adjustsFontSizeToFitWidth = YES;
        valueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:valueLabel];
        
        [horizontalLines moveToPoint:CGPointMake(self.leadingOffsetX, [self yCoordinateForline:i])];
        [horizontalLines addLineToPoint:CGPointMake(self.frame.size.width - self.trailingOffsetX, [self yCoordinateForline:i])];
    }
    
    [horizontalLines stroke];
    
    UILabel *verticalTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.height - self.topOffsetY - self.bottomOffsetY, 20)];
    CGFloat graphHeight = self.frame.size.height - self.topOffsetY - self.bottomOffsetY;
    CGFloat graphCenterY = self.topOffsetY + graphHeight/2;
    verticalTitle.center = CGPointMake(verticalTitle.frame.size.height/2 + 2.5, graphCenterY);
    verticalTitle.text = self.verticalAxeTitle;
    verticalTitle.font = [UIFont systemFontOfSize:15.0 weight:5.0];
    verticalTitle.textAlignment = NSTextAlignmentCenter;
    verticalTitle.transform=CGAffineTransformMakeRotation( ( 270 * M_PI ) / 180 );
    [self addSubview:verticalTitle];
}

-(void)setupGraphPathToContext:(CGContextRef)context {
    
    int index1 = 0;
    for (NSDictionary *graph in self.graphs) {
        
        self.xCoordinates = [graph objectForKey:@"xCoordinates"];
        self.yCoordinates = [graph objectForKey:@"yCoordinates"];
        self.title = [NSString stringWithString: [graph objectForKey:@"name"]];
        self.color = [graph objectForKey:@"color"];
        if (!self.color) self.color = [UIColor whiteColor];
        
        
        UIBezierPath *graphPath = [UIBezierPath bezierPath];
        graphPath.lineWidth = 1.5;
        [self.color setFill];
        [self.color setStroke];
        
        // line
        [graphPath moveToPoint:CGPointMake([self xCoordinateForPoint:0], [self yCoordinateForPoint:0])];
        
        // circle
        CGPoint point = CGPointMake([self xCoordinateForPoint:0], [self yCoordinateForPoint:0]);
        point.x -= 5.0 /2;
        point.y -= 5.0/2;
        UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x, point.y, 5.0, 5.0)];
        
        for (int i = 1; (i < [self.xCoordinates count]) ; i++) {
            // line
            CGPoint nextPoint = CGPointMake([self xCoordinateForPoint:i], [self yCoordinateForPoint:i]);
            [graphPath addLineToPoint:nextPoint];
            
            // circle
            if (self.lineEdgesHasCircles) {
                CGPoint point = CGPointMake([self xCoordinateForPoint:i], [self yCoordinateForPoint:i]);
                point.x -= 5.0 /2;
                point.y -= 5.0/2;
                
                UIBezierPath *nextCicle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x, point.y, 5.0, 5.0)];
                [circle appendPath:nextCicle];
            }
        }
        
        [self drawGradientUnderPath:graphPath context:context];
        
        // line
        [graphPath stroke];
        
        // circle
        if (self.lineEdgesHasCircles) {
            [circle fill];
        }
        
        // Set up appendix
        [self setupAppendixForIndex:index1];
        
        index1 = index1 + 1;
    }
}

-(void)drawGradientUnderPath:(UIBezierPath *)graphPath context:(CGContextRef)context {
    if (!self.drawGradientUnderGraph) {
        return;
    }
    
    CGContextSaveGState(context);
    
    UIBezierPath *clippingPath = [graphPath copy];
    
    CGFloat xCoord = [self xCoordinateForPoint:((int)[self.xCoordinates count] - 1)];
    CGFloat yCoord = (self.frame.size.height - self.bottomOffsetY);
    [clippingPath addLineToPoint:CGPointMake(xCoord, yCoord)];
    
    xCoord = [self xCoordinateForPoint:0];
    [clippingPath addLineToPoint:CGPointMake(xCoord, yCoord)];
    
    [clippingPath closePath];
    [clippingPath addClip];
    
    
    NSArray *colors = @[(id)[UIColor whiteColor].CGColor, (id)self.color.CGColor];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat colorLocations[2] = {0.20, 1.0};
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, colorLocations);
    
    CGFloat highestYPoint = 0.0;
    for (NSNumber *number in self.yCoordinates) {
        if ([number floatValue] > highestYPoint) {
            highestYPoint = [number floatValue];
        }
    }
    
    CGPoint startPoint1 = CGPointMake(self.leadingOffsetX, highestYPoint);
    CGPoint endPoint1 = CGPointMake(self.leadingOffsetX, yCoord);
    
    CGContextDrawLinearGradient(context, gradient, startPoint1, endPoint1, 0);
    
    CGContextRestoreGState(context);
}

-(void)setupAppendixForIndex:(int)index1 {
    UILabel *appendix1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.trailingOffsetX - 10.0, 20)];
    appendix1.center = CGPointMake(self.frame.size.width - self.trailingOffsetX/2, [self yCoordinateForAppendix:index1]);
    appendix1.textColor = self.color;
    appendix1.font = [UIFont systemFontOfSize:13.0];
    
    appendix1.text = self.title;
    appendix1.adjustsFontSizeToFitWidth = YES;
    appendix1.textAlignment = NSTextAlignmentCenter;
    [self addSubview:appendix1];
}


#pragma mark - Max value

- (CGFloat)maxXCoordinate {
    return [self maxValueForKey:@"xCoordinates"];
}

- (CGFloat)maxYCoordinate {
    return [self maxValueForKey:@"yCoordinates"];
}

-(CGFloat)maxValueForKey:(NSString *)key {
    CGFloat maxValue = 0.0;
    
    for (NSDictionary *graph in self.graphs) {
        NSArray *value = [graph objectForKey:key];
        
        for (NSNumber *number in value) {
            if ([number floatValue] > maxValue) {
                maxValue = [number floatValue];
            }
        }
    }
    return maxValue;
}

#pragma mark - Appendix coordinates

- (CGFloat)yCoordinateForAppendix:(int)appendix {
    CGFloat margin = self.topOffsetY;
    CGFloat graphHeight = self.frame.size.height - self.topOffsetY - self.bottomOffsetY;
    CGFloat spacer = graphHeight /([self.graphs count] + 1);

    CGFloat y = margin + (appendix + 1) * spacer;
    
    return y;
}

#pragma mark - Coordinates + labels for auxiliary lines

-(CGFloat)xCoordinateForLine:(int)numberOfLine {
    CGFloat graphWidth = self.frame.size.width - self.leadingOffsetX - self.trailingOffsetX;
    CGFloat widthForThisLine = numberOfLine * (graphWidth / self.numberOfVerticalLines);
    
    return self.leadingOffsetX + widthForThisLine;
}

-(CGFloat)yCoordinateForline:(int)numberOfLine {
    CGFloat graphHeight = self.frame.size.height - self.topOffsetY - self.bottomOffsetY;
    CGFloat heightForThisLine = numberOfLine * (graphHeight / self.numberOfHorizontalLines);
    
    return self.frame.size.height - self.bottomOffsetY - heightForThisLine;
}

-(NSString *)xLabelForLine:(int)numberOfline {
    CGFloat maxValue = [self maxXCoordinate];
    CGFloat valueForThisLine = numberOfline * maxValue / self.numberOfVerticalLines;
    
    return [NSString stringWithFormat:@"%.0f", valueForThisLine];;
}

-(NSString *)yLabelForLine:(int)numberOfline {
    CGFloat maxValue = [self maxYCoordinate];
    CGFloat valueForThisLine = numberOfline * maxValue / self.numberOfHorizontalLines;

    return [NSString stringWithFormat:@"%.0f", valueForThisLine];;
}

#pragma mark - Coordinates of points

-(CGFloat)xCoordinateForPoint:(int)point {
    CGFloat graphWidth = self.frame.size.width - self.leadingOffsetX - self.trailingOffsetX;
    CGFloat maxValue = [self maxXCoordinate];
    CGFloat xValue = 0;
    if (point < [self.xCoordinates count]) {
        xValue = [[self.xCoordinates objectAtIndex:point] floatValue];
    }
    CGFloat xCoordinate = (xValue / maxValue) * graphWidth;
    
    return self.leadingOffsetX + xCoordinate;
}


-(CGFloat)yCoordinateForPoint:(int)point {
    CGFloat graphHeight = self.frame.size.height - self.topOffsetY - self.bottomOffsetY ;
    CGFloat maxValue = [self maxYCoordinate];
    CGFloat yValue = 0;
    if (point < [self.yCoordinates count]) {
        yValue = [[self.yCoordinates objectAtIndex:point] floatValue];
    }
    CGFloat yCoordinate = (yValue / maxValue) * graphHeight;
    
    return self.frame.size.height - self.bottomOffsetY - yCoordinate;
}




@end















