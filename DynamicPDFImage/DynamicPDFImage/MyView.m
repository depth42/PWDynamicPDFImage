//
//  MyView.m
//  PDFBlending
//
//  Created by Frank Illenberger on 25.08.14.
//  Copyright (c) 2014 ProjectWizards. All rights reserved.
//

#import "MyView.h"
#import "PWDynamicPDFImage.h"

@implementation MyView
{
    PWDynamicPDFImage* _image;
    PWDynamicPDFImage* _image2;
}

- (PWDynamicPDFImage*)image
{
    if(!_image)
        _image = [PWDynamicPDFImage imageWithName:@"CheckBoxOn" bundle:nil];
    return _image;
}

- (PWDynamicPDFImage*)image2
{
    if(!_image2)
        _image2 = [PWDynamicPDFImage imageWithName:@"Clock" bundle:nil];
    return _image2;
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef ctx = (CGContextRef)[NSGraphicsContext currentContext].graphicsPort;
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(ctx, self.bounds);

    CGContextSetRGBFillColor(ctx, 1.0, 0.0, 0.0, 1.0);
    [self.image drawInRect:CGRectMake(100, 100, 100, 100) withFraction:1.0];

    CGContextSetRGBFillColor(ctx, 0.0, 1.0, 0.0, 1.0);
    [self.image drawInRect:CGRectMake(200, 140, 100, 100) withFraction:1.0];

    CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 1.0, 1.0);
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 1.0, 1.0);
    [self.image2 drawInRect:CGRectMake(40, 190, 100, 100) withFraction:1.0];
}

@end
