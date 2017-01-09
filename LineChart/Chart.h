//
//  Chart.h
//  Core Graphics
//
//  Created by Tasos Tsolis on 29/8/16.
//  Copyright © 2016 Tasos Tsolis. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface Chart : UIView

/**
 * @brief An array which contains the data of the graph. For each line of the graph, a dictionary must be inserted in the graphs array.
 * @discussion The dictionary should contains the following keys and objects:
 * @discussion key:"xCoordinates"  object: An array which contains the x coordinates of the graph. Each item of the array should be a NSNumber.
 * @discussion key:"yCoordinates"  object: An array which contains the y coordinates of the graph. Each item of the array should be a NSNumber.
 * @discussion key:"name"          object: A string which represents the title of the line on the graph.
 * @discussion key:"color"         object: An UIColor object which represent the color of the line on the graph.
 */
@property (strong, nonatomic) NSArray *graphs;

/// Define the title of the vertical axe.
@property (strong, nonatomic) IBInspectable NSString *verticalAxeTitle;

/// Define the title of the horizontal axe.
@property (strong, nonatomic) IBInspectable NSString *horizontalAxeTitle;

/// Define the start color for the background gradient.
@property (strong, nonatomic) IBInspectable UIColor *startColor;

/// Define the end color for the background gradient.
@property (strong, nonatomic) IBInspectable UIColor *endColor;

/// Define the color of the two axes.
@property (strong, nonatomic) IBInspectable UIColor *axesColor;

/// Define the color of the horizontal and vertical lines.
@property (strong, nonatomic) IBInspectable UIColor *linesColor;

/// Defien the number of horizontal lines.
@property (assign, nonatomic) IBInspectable int numberOfHorizontalLines;

/// Deine the number of vertical lines.
@property (assign, nonatomic) IBInspectable int numberOfVerticalLines;

/// A bool indicating if at the edges of the lines should be drown circles.
@property (assign, nonatomic) IBInspectable BOOL lineEdgesHasCircles;

/// A bool indicating if should be drawn a gradient under the lines of the graph.
@property (assign, nonatomic) IBInspectable BOOL drawGradientUnderGraph;

/// A bool indicating if should be drawn a background gradient.
@property (assign, nonatomic) IBInspectable BOOL drawBackgroundGradient;

@end

