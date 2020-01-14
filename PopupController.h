//
//  PopupController.h
//  Sudoku Basic
//
//  Created by David Figge on 12/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PopupController
-(void)PopupController:(UIViewController*)controller didSelectItem:(int)item withID:(int)msgID;	// Called when user selected label from window
-(void)PopupControllerSelectionCanceled:(UIViewController*)controller withID:(int)msgID;		// Called when user cancels operation (clicks outside of window)
@end
