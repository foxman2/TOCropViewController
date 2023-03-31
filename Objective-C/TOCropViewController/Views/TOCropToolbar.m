//
//  TOCropToolbar.h
//
//  Copyright 2015-2022 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TOCropToolbar.h"

#define TOCROPTOOLBAR_DEBUG_SHOWING_BUTTONS_CONTAINER_RECT 0   // convenience debug toggle

@interface TOCropToolbar()

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong, readwrite) UIButton *doneIconButton;

@property (nonatomic, strong, readwrite) UIButton *cancelIconButton;

@property (nonatomic, assign) BOOL reverseContentLayout; // For languages like Arabic where they natively present content flipped from English

@end

@implementation TOCropToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.12f alpha:1.0f];
    [self addSubview:self.backgroundView];
    
    // On iOS 9, we can use the new layout features to determine whether we're in an 'Arabic' style language mode
    if (@available(iOS 9.0, *)) {
        self.reverseContentLayout = ([UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft);
    }
    else {
        self.reverseContentLayout = [[[NSLocale preferredLanguages] objectAtIndex:0] hasPrefix:@"ar"];
    }
    
    // Get the resource bundle depending on the framework/dependency manager we're using
    NSBundle *resourceBundle = TO_CROP_VIEW_RESOURCE_BUNDLE_FOR_OBJECT(self);
    
    
    _doneIconButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_doneIconButton setImage:[TOCropToolbar doneImage: resourceBundle] forState:UIControlStateNormal];
    [_doneIconButton setBackgroundColor:[UIColor whiteColor]];
    _doneIconButton.layer.cornerRadius = 4;
    [_doneIconButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_doneIconButton];
    
    
    _cancelIconButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_cancelIconButton setImage:[TOCropToolbar cancelImage: resourceBundle] forState:UIControlStateNormal];
    [_cancelIconButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancelIconButton];
    
    // Set the default color for the done buttons
    self.cancelIconButton.tintColor = UIColor.whiteColor;
    self.doneButtonColor = UIColor.blackColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    CGRect frame = self.bounds;
    frame.origin.x -= self.backgroundViewOutsets.left;
    frame.size.width += self.backgroundViewOutsets.left;
    frame.size.width += self.backgroundViewOutsets.right;
    frame.origin.y -= self.backgroundViewOutsets.top;
    frame.size.height += self.backgroundViewOutsets.top;
    frame.size.height += self.backgroundViewOutsets.bottom;
    self.backgroundView.frame = frame;
    
#if TOCROPTOOLBAR_DEBUG_SHOWING_BUTTONS_CONTAINER_RECT
    static UIView *containerView = nil;
    if (!containerView) {
        containerView = [[UIView alloc] initWithFrame:CGRectZero];
        containerView.backgroundColor = [UIColor redColor];
        containerView.alpha = 0.1;
        [self addSubview:containerView];
    }
#endif
    {
        CGRect closeFrame = CGRectZero;
        closeFrame.size.height = 32;
        closeFrame.size.width = 32;
        closeFrame.origin.x = 16;
        closeFrame.origin.y = 30;
        self.cancelIconButton.frame = closeFrame;
        
        CGRect doneFrame = CGRectZero;
        doneFrame.size.width = 120;
        doneFrame.size.height = 44.0f;
        doneFrame.origin.x = CGRectGetMidX(self.bounds) - doneFrame.size.width / 2;
        doneFrame.origin.y = 24;
        self.doneIconButton.frame = doneFrame;
        
#if TOCROPTOOLBAR_DEBUG_SHOWING_BUTTONS_CONTAINER_RECT
        CGRect containerRect = (CGRect){0,CGRectGetMaxY(self.doneIconButton.frame),44.0f,CGRectGetMinY(self.cancelIconButton.frame)-CGRectGetMaxY(self.doneIconButton.frame)};
        containerView.frame = containerRect;
#endif
    }
    
}

- (void)buttonTapped:(id)button
{
    if (button == self.cancelIconButton) {
        if (self.cancelButtonTapped)
            self.cancelButtonTapped();
    }
    else if (button == self.doneIconButton) {
        if (self.doneButtonTapped)
            self.doneButtonTapped();
    }
}

- (void)setDoneButtonHidden:(BOOL)doneButtonHidden {
    if (_doneButtonHidden == doneButtonHidden)
        return;
    
    _doneButtonHidden = doneButtonHidden;
    [self setNeedsLayout];
}

- (void)setCancelButtonHidden:(BOOL)cancelButtonHidden {
    if (_cancelButtonHidden == cancelButtonHidden)
        return;
    
    _cancelButtonHidden = cancelButtonHidden;
    [self setNeedsLayout];
}

- (CGRect)doneButtonFrame
{
    return self.doneIconButton.frame;
}

- (void)setCancelButtonColor:(UIColor *)cancelButtonColor {
    // Default color is app tint color
    if (cancelButtonColor == _cancelButtonColor) { return; }
    _cancelButtonColor = cancelButtonColor;
    [_cancelIconButton setTintColor:_cancelButtonColor];
}

- (void)setDoneButtonColor:(UIColor *)doneButtonColor {
    // Set the default color when nil is specified
    if (doneButtonColor == nil) {
        doneButtonColor = [UIColor colorWithRed:1.0f green:0.8f blue:0.0f alpha:1.0f];
    }
    
    if (doneButtonColor == _doneButtonColor) { return; }
    
    _doneButtonColor = doneButtonColor;
    [_doneIconButton setTintColor:_doneButtonColor];
}

#pragma mark - Image Generation -
+ (UIImage *)doneImage:(NSBundle *)bundle
{
    return [UIImage imageNamed:@"done"];
}

+ (UIImage *)cancelImage:(NSBundle *)bundle
{
    return [UIImage imageNamed:@"close"];
}

#pragma mark - Accessors -

- (UIView *)visibleCancelButton
{
    return self.cancelIconButton;
}

@end
