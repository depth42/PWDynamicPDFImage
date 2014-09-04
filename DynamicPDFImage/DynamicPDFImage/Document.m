//
//  Document.m
//  PDFBlending
//
//  Created by Frank Illenberger on 25.08.14.
//  Copyright (c) 2014 ProjectWizards. All rights reserved.
//

#import "Document.h"

@implementation Document
            
- (NSString *)windowNibName
{
    return @"Document";
}

- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings
                                           error:(NSError **)outError
{
    NSWindowController* controller = self.windowControllers.firstObject;
    NSView* view = controller.window.contentView;
    return [NSPrintOperation printOperationWithView:view];
}

@end
