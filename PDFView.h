//
//  PDFView.h
//  Sudoku Basic
//
//  Created by David Figge on 1/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PagingProtocol.h"

@protocol PageChangeProtocol
-(void)PageChange;
@end



@interface PDFView : UIView <PagingProtocol> {
	CGPDFDocumentRef pdfDoc;	// Reference to the document in memory
	id<PageChangeProtocol> PageChangeDelegate;	// Delegate to notify on page change
	int pages;					// Number of pages in the document
	float sizeRatio;			// Height of pdf 'box' / width of pdf 'box'
	float scale;				// Scale to use when drawing up image
	CGRect box;					// Actual 'box' for full scale drawing of this PDF (page 1)
	float pageWidth;			// Width of each page in pixels (scale to fit into this width)
	int currentPage;
}

@property (nonatomic, assign) CGPDFDocumentRef pdfDoc;
@property (nonatomic, readonly) int pages;
-(id)initWithFrame:(CGRect)frame withPdfName:(CFStringRef)name withPageChangeDelegate:(id<PageChangeProtocol>)del;
-(CGPDFDocumentRef)getPdfDoc:(CFStringRef)name;
-(void)changePdf:(CFStringRef)name;
-(void)NextPage;
-(void)PreviousPage;
@end

