//
//  NEConstConstraints.h
//  SnailReader
//
//  Created by JimmyOu on 2018/10/9.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#define UIColorFromHex(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]


#pragma mark - Line Chart

#define kJBColorLineChartControllerBackground UIColorFromHex(0xb7e3e4)
#define kJBColorLineChartBackground UIColorFromHex(0xb7e3e4)
#define kJBColorLineChartHeader UIColorFromHex(0x1c474e)
#define kJBColorLineChartHeaderSeparatorColor UIColorFromHex(0x8eb6b7)
#define kJBColorLineChartDefaultSolidLineColor [UIColor colorWithWhite:1.0 alpha:0.5]
#define kJBColorLineChartDefaultSolidSelectedLineColor [UIColor colorWithWhite:1.0 alpha:1.0]
#define kJBColorLineChartDefaultDashedLineColor [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0]
#define kJBColorLineChartDefaultDashedSelectedLineColor [UIColor colorWithWhite:1.0 alpha:1.0]
#define kJBColorLineChartDefaultSolidFillColor [UIColor clearColor]
#define kJBColorLineChartDefaultDashedFillColor [UIColor colorWithWhite:1.0 alpha:0.3]
#define kJBColorLineChartDefaultGradientStartColor UIColorFromHex(0x0000FF)
#define kJBColorLineChartDefaultGradientEndColor UIColorFromHex(0x00FF00)


#define mark - Area Chart

#define kJBColorAreaChartControllerBackground UIColorFromHex(0xb7e3e4)
#define kJBColorAreaChartBackground UIColorFromHex(0xb7e3e4)
#define kJBColorAreaChartHeader UIColorFromHex(0x1c474e)
#define kJBColorAreaChartHeaderSeparatorColor UIColorFromHex(0x8eb6b7)
#define kJBColorAreaChartDefaultSunLineColor [UIColor clearColor]
#define kJBColorAreaChartDefaultSunAreaColor [UIColorFromHex(0xfcfb3a) colorWithAlphaComponent:0.5]
#define kJBColorAreaChartDefaultSunSelectedLineColor [UIColor clearColor]
#define kJBColorAreaChartDefaultSunSelectedAreaColor UIColorFromHex(0xfcfb3a)
#define kJBColorAreaChartDefaultMoonLineColor [UIColor clearColor]
#define kJBColorAreaChartDefaultMoonAreaColor [[UIColor blackColor] colorWithAlphaComponent:0.5]
#define kJBColorAreaChartDefaultMoonSelectedLineColor [UIColor clearColor]
#define kJBColorAreaChartDefaultMoonSelectedAreaColor [UIColor blackColor]


#pragma mark - Tooltips

#define kJBColorTooltipColor [UIColor colorWithWhite:1.0 alpha:0.9]
#define kJBColorTooltipTextColor UIColorFromHex(0x313131)


#pragma mark - Font
#pragma mark - Footers

#define kJBFontFooterLabel [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]
#define kJBFontFooterSubLabel [UIFont fontWithName:@"HelveticaNeue" size:10.0]

#pragma mark - Headers

#define kJBFontHeaderTitle [UIFont fontWithName:@"HelveticaNeue-Bold" size:24]
#define kJBFontHeaderSubtitle [UIFont fontWithName:@"HelveticaNeue-Light" size:14]

#pragma mark - Information

#define kJBFontInformationTitle [UIFont fontWithName:@"HelveticaNeue" size:20]
#define kJBFontInformationValue [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:100]
#define kJBFontInformationUnit [UIFont fontWithName:@"HelveticaNeue" size:60]

#pragma mark - Tooltip

#define kJBFontTooltipText [UIFont fontWithName:@"HelveticaNeue-Bold" size:14]


