//
//  PagingProtocol.h
//  Sudoku Basic
//
//  Created by David Figge on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PagingProtocol
-(void)NextPage;
-(void)PreviousPage;
-(int)GetTotalPages;
@end
