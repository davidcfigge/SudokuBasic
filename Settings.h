//
//  Settings.h
//  Sudoku Basic
//
//  Created by David Figge on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum _pencilmodes_ {
	PENCIL_DEFAULT = 0, // Using pencil marks manually (hints not available)
	PENCIL_AUTO = 1,	// Using auto marks, no hints
	PENCIL_HINTS = 2,	// Using auto marks with hints
	PENCIL_MODES_COUNT,
};

enum _validatemodes_ {
	NOVALIDATION = 0,	// Don't validate contents of cells against correct answer
	VALIDATION = 1,		// Validate cell contents against correct answer
	VALIDATE_MODES_COUNT,
};

struct fontElements {
	char* fontName;						// Name of font to use
	float fontSize;							// Size of font to use
	float fontColorRed;						// Red component of RGB color, 0-1
	float fontColorGreen;					// Green component of RGB color, 0-1
	float fontColorBlue;					// Blue component of RGB color, 0-1
	float fontColorAlpha;					// Alpha (brightness) component of RGB color, 0-1
};

enum {
	FONTDEFVALUE,				// Used to print main number in center of square for defined numbers (not selectable)
	FONTVALUE,					// Used to print main number in center of square
	FONTERRVALUE,				// Used to print main number when doesn't match correct answer
	FONTPENCIL,					// Used to print (normal) pencil markings
	FONTHIGHLTPENCIL,			// Used to print highlighted pencil markings in hint mode,
	FONTCMDSTRING,				// Used to print command text on buttons on control pad
	FONTCMDSTRINGSEL,			// Used to print selected command text on buttons on control pad
	FONTOPTSTRING,				// Used to print option button text on control pad. Must be followed by SELECTED version
	FONTOPTSTRINGSEL,			// Used to print selected optoin button text on control pad. Must be followed by SEL2 version
	FONTOPTSTRINGSEL2,			// Used to print second level of option. Must follow FONTOPTSTRINGSEL
	FONTOPTSTRINGSEL3,			// Used to print third level of option. Must follow FONTOPTSTRINGSEL2
	FONTMENUITEM,				// Used to print menu items on the menu (New Game)
	FONTTIMESTRING,				// Used to print the time display on the control pad
	FONTCTLPADVALUE,			// Used to simulate a value on the control pad. Must be followed by SELECTED version
	FONTCTLPADVALUESEL,			// Used to simulated a selected value on the control pad
	FONTCTLPADPENCIL,			// Used to simulate a pencil mark on control pad. Must be followed by SELECTED version
	FONTCTLPADPENCILSEL,		// Used to simulated a selected pencil mark on the control pad
	FONTCTLPADPENCILEXCL,		// Used to display pencil mark that has been purposely excluded
	FONTCELLSELECTED,			// Color only. Used to draw line around cell to indicate selected. Must be followed by SELECTED version
	FONTCELLLEFTSELECTED,		// Color only. Used to draw a line around cell to indicted previously selected cell
	FONTCELLFILTERSHADING,		// Color only. Shade color added to cells when filtering on
	FONTCMDBTNBORDERDARK,		// Color only. Color of dark border when drawing 3-D effect on command buttons/cells
	FONTCMDBTNBORDERLIGHT,		// Color only. Color of light border when drawing 3-D effect on command buttons/cells
	FONTCMDFILTERLIGHT,			// Color only. Used to display control pad cell used in filter mode
	FONTCOUNT };

struct _themeInfo_ {
	struct fontElements fontData[FONTCOUNT];
};

@interface Settings : NSObject {
	int pencilMode;		// Must be value from _pencilmodes_
	bool filterMode;	// set if filter mode is on
	
	// Current theme information
	struct _themeInfo_ themeInfo;
	int cellCounts[5];

}

@property ( nonatomic, assign) int pencilMode;
@property ( nonatomic, assign) bool filterMode;
+(Settings*)settings;
-(void)setContext:(CGContextRef)context forFontItem:(int)FontItem;			// Set context (font, etc.) for text item
-(void)setContextForPencil:(CGContextRef)context withHighlight:(BOOL)hl;	// Set context for pencil markings
-(void)setContextForValue:(CGContextRef)context isDefValue:(BOOL)dv;		// Set context for values
-(void)setThemeInfo:(int)fontType fontName:(char*)name fontSize:(float)size fontRed:(float)red fontGreen:(float)green fontBlue:(float)blue fontAlpha:(float)alpha;
-(char*)getFontName:(int)fontType;											// Get the chosen font name for a particular font type
-(int)getFontSize:(int)fontType;											// Get the chosen font size for a particular font type
-(int)getCellCount:(int)level;												// Get number of default cells for specific difficulty level
-(void) setCellCounts;														// Set the default cell counts for the difficulty levels
@end
