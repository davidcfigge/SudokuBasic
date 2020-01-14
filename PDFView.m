/******
 *
 * The PDFView class is a subclass of UIView, and is designed to display a full PDF document.
 *
 * The PDF document must be formatted as one large page and located within the bundle.
 *
 * Specify the document name in the initWithFrame:withPdfName: method.
 *   Note that the document name must be a CFStringRef. Create this using CFSTR (e.g. withPdfName:CFSTR("MyFile.pdf"))
 *
 */

#import "PDFView.h"

@implementation PDFView


@synthesize pdfDoc, pages;

- (id)initWithFrame:(CGRect)frame withPdfName:(CFStringRef)name withPageChangeDelegate:(id<PageChangeProtocol>)del {
    self = [super initWithFrame:frame];
    if (self) {
		PageChangeDelegate = del;
		pageWidth = frame.size.width;
		pdfDoc = nil;
		[self changePdf:name];
		//pdfDoc = [self getPdfDoc:name];
		//self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		//self.autoresizesSubviews = YES;
    }
    return self;
}

-(void)NextPage {
	if (currentPage < pages) {
		currentPage++;
		[PageChangeDelegate PageChange];
		[self setNeedsDisplay];
	}
}

-(void)PreviousPage {
	if (currentPage > 0) {
		currentPage--;
		[PageChangeDelegate PageChange];
		[self setNeedsDisplay];
	}
}

-(int)GetTotalPages {
	return pages;
}


-(CGPDFDocumentRef)getPdfDoc:(CFStringRef)name {
	CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), name, NULL, NULL);
	CGPDFDocumentRef pdfdoc = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
	CFRelease(pdfURL);
	pages = CGPDFDocumentGetNumberOfPages(pdfdoc);
	CGPDFPageRef page = CGPDFDocumentGetPage(pdfdoc, 1);
	box = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
	scale = self.bounds.size.width / box.size.width;
	sizeRatio = box.size.height / box.size.width;
	return pdfdoc;
}

-(void)changePdf:(CFStringRef)name {
	if (pdfDoc != nil) CGPDFDocumentRelease(pdfDoc);
	pdfDoc = [self getPdfDoc:name];
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.width*sizeRatio);
	currentPage = 1;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	if (pdfDoc == nil) return;
    CGContextRef context = UIGraphicsGetCurrentContext();
	// before we start drawing.
	
	// Grab the PDF pages
	// We're about to modify the context CTM to draw the PDF page where we want it, so save the graphics state in case we want to do more drawing
	CGContextSaveGState(context);
	CGPDFPageRef page = CGPDFDocumentGetPage(pdfDoc, currentPage);
	float size = self.bounds.size.height;
	// PDF page drawing expects a Lower-Left coordinate system, so we flip the coordinate system
	CGContextTranslateCTM(context, 0, size);
	CGContextScaleCTM(context, scale, -scale);
	CGContextDrawPDFPage(context, page);
	CGContextRestoreGState(context);
}


- (void)dealloc {
	if (pdfDoc != nil) CGPDFDocumentRelease(pdfDoc);
    [super dealloc];
}


@end
