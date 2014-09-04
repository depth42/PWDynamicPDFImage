PWDynamicPDFImage
=================

Are you looking for a convenient way of drawing monochrome vector images in varying colors? Then PWDynamicPDFImage may be the right class for you. It uses Quartz primitives for drawing the paths contained in a PDF image with the current fill/stroke color. This enables an easy workflow with designers in your team and prevents you from having to use more cumbersome solutions like designing font glyphs or writing individual painting code.

The example Mac app shows how to draw an example image in three different colors in an NSView. The view can also be printed for demonstrating that the vectorness of the image is preserved during drawing.

I have not tested it, but PWDynamicPDFImage should run nicely under iOS as it only uses plain CoreGraphcis and Foundation calls.

