//
//  PWDynamicPDFImage.h
//  PDFBlending
//
//  Created by Frank Illenberger on 28.08.14.
//  Copyright (c) 2014 ProjectWizards. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PWDynamicPDFImage : NSObject

+ (PWDynamicPDFImage*)imageWithName:(NSString*)name
                             bundle:(NSBundle*)bundle;

- (void)drawInRect:(CGRect)rect
      withFraction:(CGFloat)fraction;

@end
