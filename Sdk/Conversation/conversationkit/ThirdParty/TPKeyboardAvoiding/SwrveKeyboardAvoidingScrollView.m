//
//  SwrveKeyboardAvoidingScrollView.m
//
//  Created by Michael Tyson on 30/09/2013.
//  Copyright 2013 A Tasty Pixel. All rights reserved.
//

#import "SwrveKeyboardAvoidingScrollView.h"

@interface SwrveKeyboardAvoidingScrollView () <UITextFieldDelegate, UITextViewDelegate>
@end

@implementation SwrveKeyboardAvoidingScrollView

// http://stackoverflow.com/questions/20664918/xcode-spurious-warnings-for-creating-selector-for-nonexistent-method-compare
#pragma GCC diagnostic-ignored -Wselector

#pragma mark - Setup/Teardown

- (void)setup {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SwrveKeyboardAvoiding_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
#pragma clang pop
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SwrveKeyboardAvoiding_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToActiveTextField) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToActiveTextField) name:UITextFieldTextDidBeginEditingNotification object:nil];
}

-(id)initWithFrame:(CGRect)frame {
    if ( !(self = [super initWithFrame:frame]) ) return nil;
    [self setup];
    return self;
}

-(void)awakeFromNib {
    [self setup];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self SwrveKeyboardAvoiding_updateContentInset];
}

-(void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    [self SwrveKeyboardAvoiding_updateFromContentSizeChange];
}

- (void)contentSizeToFit {
    self.contentSize = [self SwrveKeyboardAvoiding_calculatedContentSizeFromSubviewFrames];
}

- (BOOL)focusNextTextField {
    return [self SwrveKeyboardAvoiding_focusNextTextField];

}
- (void)scrollToActiveTextField {
    [self SwrveKeyboardAvoiding_scrollToActiveTextField];
}

#pragma mark - Responders, events

-(void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if ( !newSuperview ) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(SwrveKeyboardAvoiding_assignTextDelegateForViewsBeneathView:) object:self];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self SwrveKeyboardAvoiding_findFirstResponderBeneathView:self] resignFirstResponder];
    [super touchesEnded:touches withEvent:event];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ( ![self focusNextTextField] ) {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(SwrveKeyboardAvoiding_assignTextDelegateForViewsBeneathView:) object:self];
    [self performSelector:@selector(SwrveKeyboardAvoiding_assignTextDelegateForViewsBeneathView:) withObject:self afterDelay:0.1];
}

@end
