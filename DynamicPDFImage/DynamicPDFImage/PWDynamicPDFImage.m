//
//  PWDynamicPDFImage.m
//  PDFBlending
//
//  Created by Frank Illenberger on 28.08.14.
//  Copyright (c) 2014 ProjectWizards. All rights reserved.
//

#import "PWDynamicPDFImage.h"

@implementation PWDynamicPDFImage
{
    CGPDFDocumentRef      _pdfDocument;
    CGPDFContentStreamRef _stream;
}

- (void)dealloc
{
    if(_pdfDocument)
        CFRelease(_pdfDocument);
    if(_stream)
        CFRelease(_stream);
}

+ (PWDynamicPDFImage*)imageWithURL:(NSURL*)URL
{
    NSParameterAssert(URL);

    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)URL);
    if(!pdf)
        return nil;
    PWDynamicPDFImage* image = [[self alloc] initWithPDF:pdf];
    CFRelease(pdf);
    return image;
}

+ (PWDynamicPDFImage*)imageWithName:(NSString*)name bundle:(NSBundle*)bundle
{
    NSParameterAssert(name);

    NSURL* URL = [bundle ? bundle : NSBundle.mainBundle URLForResource:name
                     withExtension:@"pdf"];
    return [self imageWithURL:URL];
}

- (PWDynamicPDFImage*)initWithPDF:(CGPDFDocumentRef)pdf
{
    NSParameterAssert(pdf);

    if(self = [super init])
    {
        _pdfDocument = CGPDFDocumentRetain(pdf);

        NSAssert(CGPDFDocumentGetNumberOfPages(pdf) > 0, nil);
        _stream = CGPDFContentStreamCreateWithPage(CGPDFDocumentGetPage(pdf, 1));
    }
    return self;
}

- (CGPDFOperatorTableRef)operatorTable
{
    static CGPDFOperatorTableRef table;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        table = CGPDFOperatorTableCreate();
        CGPDFOperatorTableSetCallback(table, "b",  &operator_b);
        CGPDFOperatorTableSetCallback(table, "B",  &operator_B);
        CGPDFOperatorTableSetCallback(table, "b*", &operator_bStar);
        CGPDFOperatorTableSetCallback(table, "B*", &operator_BStar);
        CGPDFOperatorTableSetCallback(table, "c",  &operator_c);
        CGPDFOperatorTableSetCallback(table, "cm", &operator_cm);
        CGPDFOperatorTableSetCallback(table, "f",  &operator_f);
        CGPDFOperatorTableSetCallback(table, "f*", &operator_fStar);
        CGPDFOperatorTableSetCallback(table, "j",  &operator_j);
        CGPDFOperatorTableSetCallback(table, "J",  &operator_J);
        CGPDFOperatorTableSetCallback(table, "l",  &operator_l);
        CGPDFOperatorTableSetCallback(table, "m",  &operator_m);
        CGPDFOperatorTableSetCallback(table, "M",  &operator_M);
        CGPDFOperatorTableSetCallback(table, "n",  &operator_n);
        CGPDFOperatorTableSetCallback(table, "q",  &operator_q);
        CGPDFOperatorTableSetCallback(table, "Q",  &operator_Q);
        CGPDFOperatorTableSetCallback(table, "re", &operator_re);
        CGPDFOperatorTableSetCallback(table, "s",  &operator_s);
        CGPDFOperatorTableSetCallback(table, "S",  &operator_S);
        CGPDFOperatorTableSetCallback(table, "v",  &operator_v);
        CGPDFOperatorTableSetCallback(table, "w",  &operator_w);
        CGPDFOperatorTableSetCallback(table, "W",  &operator_W);
        CGPDFOperatorTableSetCallback(table, "W*", &operator_WStar);
        CGPDFOperatorTableSetCallback(table, "y",  &operator_y);
    });
    return table;
}

static void popNumbers(CGPDFScannerRef scanner, CGFloat* buffer, NSUInteger count)
{
    for(NSInteger i=count-1; i>=0; i--)
    {
        CGPDFReal value;
        if (!CGPDFScannerPopNumber(scanner, &value))
            [NSException raise:NSInternalInconsistencyException
                        format:@"PWDynamicPDFImage: Could not pop number"];
        buffer[i] = value;
    }
}

static CGFloat popFloat(CGPDFScannerRef scanner)
{
    CGFloat value;
    popNumbers(scanner, &value, 1);
    return value;
}

static CGPDFInteger popInteger(CGPDFScannerRef scanner)
{
    CGPDFInteger value;
    if(!CGPDFScannerPopInteger(scanner, &value))
        [NSException raise:NSInternalInconsistencyException
                    format:@"PWDynamicPDFImage: Could not pop number"];
    return value;
}

static CGPoint popPoint(CGPDFScannerRef scanner)
{
    CGFloat values[2];
    popNumbers(scanner, values, 2);
    return *((CGPoint *)values);
}

static CGAffineTransform popTransform(CGPDFScannerRef scanner)
{
    CGFloat values[6];
    popNumbers(scanner, values, 6);
    return *((CGAffineTransform *)values);
}

static void operator_b(CGPDFScannerRef scanner, void* info)
{
    if (!CGContextIsPathEmpty((CGContextRef)info))
        CGContextClosePath((CGContextRef)info);
    CGContextFillPath((CGContextRef)info);
    CGContextStrokePath((CGContextRef)info);
}

static void operator_B(CGPDFScannerRef scanner, void* info)
{
    CGContextFillPath((CGContextRef)info);
    CGContextStrokePath((CGContextRef)info);
}

static void operator_bStar(CGPDFScannerRef scanner, void* info)
{
    if (!CGContextIsPathEmpty((CGContextRef)info))
        CGContextClosePath((CGContextRef)info);
    CGContextEOFillPath((CGContextRef)info);
    CGContextStrokePath((CGContextRef)info);
}

static void operator_BStar(CGPDFScannerRef scanner, void* info)
{
    CGContextEOFillPath((CGContextRef)info);
    CGContextStrokePath((CGContextRef)info);
}

static void operator_c(CGPDFScannerRef scanner, void* info)
{
    CGPoint p   = popPoint(scanner);
    CGPoint cp2 = popPoint(scanner);
    CGPoint cp1 = popPoint(scanner);
    CGContextAddCurveToPoint((CGContextRef)info, cp1.x, cp1.y, cp2.x, cp2.y, p.x, p.y);
}

static void operator_cm(CGPDFScannerRef scanner, void* info)
{
    CGContextConcatCTM((CGContextRef)info, popTransform(scanner));
}

static void operator_f(CGPDFScannerRef scanner, void* info)
{
    CGContextFillPath((CGContextRef)info);
}

static void operator_fStar(CGPDFScannerRef scanner, void* info)
{
    CGContextEOFillPath((CGContextRef)info);
}

static void operator_j(CGPDFScannerRef scanner, void* info)
{
    CGContextSetLineJoin((CGContextRef)info, (CGLineJoin)popInteger(scanner));
}

static void operator_J(CGPDFScannerRef scanner, void* info)
{
    CGContextSetLineCap((CGContextRef)info, (CGLineCap)popInteger(scanner));
}

static void operator_l(CGPDFScannerRef scanner, void* info)
{
    CGPoint p = popPoint(scanner);
    CGContextAddLineToPoint((CGContextRef)info, p.x, p.y);
}

static void operator_m(CGPDFScannerRef scanner, void* info)
{
    CGPoint p = popPoint(scanner);
    CGContextMoveToPoint((CGContextRef)info, p.x, p.y);
}

static void operator_M(CGPDFScannerRef scanner, void* info)
{
    CGContextSetMiterLimit((CGContextRef)info, popFloat(scanner));
}

static void operator_n(CGPDFScannerRef scanner, void* info)
{
    if (!CGContextIsPathEmpty((CGContextRef)info))
        CGContextClosePath((CGContextRef)info);
}

static void operator_q(CGPDFScannerRef scanner, void* info)
{
    CGContextSaveGState((CGContextRef)info);
}

static void operator_Q(CGPDFScannerRef scanner, void* info)
{
    CGContextRestoreGState((CGContextRef)info);
}

static void operator_re(CGPDFScannerRef scanner, void* info)
{
    CGFloat values[4];
    popNumbers(scanner, values, 4);
    CGRect rect = *((CGRect *)values);
    CGContextAddRect((CGContextRef)info, rect);
}

static void operator_s(CGPDFScannerRef scanner, void* info)
{
    if (!CGContextIsPathEmpty((CGContextRef)info))
        CGContextClosePath((CGContextRef)info);
    CGContextStrokePath((CGContextRef)info);
}

static void operator_S(CGPDFScannerRef scanner, void* info)
{
    CGContextStrokePath((CGContextRef)info);
}

static void operator_v(CGPDFScannerRef scanner, void* info)
{
    CGPoint p   = popPoint(scanner);
    CGPoint cp2 = popPoint(scanner);
    CGPoint cp1 = CGContextGetPathCurrentPoint((CGContextRef)info);
    CGContextAddCurveToPoint((CGContextRef)info, cp1.x, cp1.y, cp2.x, cp2.y, p.x, p.y);
}

static void operator_w(CGPDFScannerRef scanner, void* info)
{
    CGContextSetLineWidth((CGContextRef)info, popFloat(scanner));
}

static void operator_W(CGPDFScannerRef scanner, void* info)
{
    CGContextClip((CGContextRef)info);
}

static void operator_WStar(CGPDFScannerRef scanner, void* info)
{
    CGContextEOClip((CGContextRef)info);
}

static void operator_y(CGPDFScannerRef scanner, void* info)
{
    CGPoint p   = popPoint(scanner);
    CGPoint cp2 = p;
    CGPoint cp1 = popPoint(scanner);
    CGContextAddCurveToPoint((CGContextRef)info, cp1.x, cp1.y, cp2.x, cp2.y, p.x, p.y);
}

- (CGSize)size
{
    if(!_pdfDocument)
        return CGSizeZero;
    CGPDFPageRef page = CGPDFDocumentGetPage(_pdfDocument, 1);
    return CGPDFPageGetBoxRect(page, kCGPDFMediaBox).size;
}

- (void)drawInRect:(CGRect)rect
      withFraction:(CGFloat)fraction
{
    CGAffineTransform transform;
    CGSize size = self.size;
    CGFloat horizontalRatio = CGRectGetWidth(rect)/size.width;
    CGFloat verticalRatio   = CGRectGetHeight(rect)/size.height;
    CGFloat scalingFactor = 1.0;

    // CGPDFPageGetDrawingTransform can only create scaling factors less or equal to 0.0, to scale the image up we
    // create our own transformation.

    CGPDFPageRef page = CGPDFDocumentGetPage(_pdfDocument, 1);

    if((horizontalRatio > 1.0) && (verticalRatio > 1.0))
    {
        scalingFactor = MIN(horizontalRatio, verticalRatio);

        transform = CGAffineTransformMakeTranslation(CGRectGetMinX(rect), CGRectGetMinY(rect));
        transform = CGAffineTransformScale(transform, scalingFactor, scalingFactor);
    }
    else
        transform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, rect, 0, FALSE);

    CGContextRef ctx = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextSaveGState(ctx);
    CGContextConcatCTM(ctx, transform);
    CGPDFScannerRef scanner = CGPDFScannerCreate(_stream, self.operatorTable, (void*)ctx);
    CGPDFScannerScan(scanner);
    CGPDFScannerRelease(scanner);
    CGContextRestoreGState(ctx);
}

@end

