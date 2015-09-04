//
//  BKCardNumberField.m
//  BKMoneyKit
//
//  Created by Byungkook Jang on 2014. 8. 23..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import "BKCardNumberField.h"
#import "LFCreditCardHelper.h"

@interface BKCardNumberField ()

@property (nonatomic, strong) BKCardNumberFormatter	*cardNumberFormatter;
@property (nonatomic, strong) NSCharacterSet		*numberCharacterSet;

@end

@implementation BKCardNumberField

#pragma mark - Initialize

- (void)commonInit
{
    [super commonInit];

	self.logoLabels = @{
		LFCreditCardCompanyNone:			@"1.",
		LFCreditCardCompanyVisa:			@"2.",
		LFCreditCardCompanyMasterCard:		@"3.",
		LFCreditCardCompanyAmericanExpress:	@"4.",
	};
	self.logoWidth	= 44;
	//self.logoFont	= [UIFont fontWithName:@"airservice-icons" size:18];
	//self.logoColor	= [UIColor darkGrayColor];

    _cardNumberFormatter = [[BKCardNumberFormatter alloc] init];
    
    _numberCharacterSet = [BKMoneyUtils numberCharacterSet];
    
    self.keyboardType = UIKeyboardTypeNumberPad;
    self.clearButtonMode = UITextFieldViewModeAlways;
    
    [self addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
}

#pragma mark - Dealloc

- (void)dealloc
{
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.userDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        if (NO == [self.userDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string]) {
            return NO;
        }
    }
    
    NSString *currentText = textField.text;
    
    NSCharacterSet *nonNumberCharacterSet = [self.numberCharacterSet invertedSet];
    
    if (string.length == 0 && [[currentText substringWithRange:range] stringByTrimmingCharactersInSet:nonNumberCharacterSet].length == 0) {
        // find non-whitespace character backward
        NSRange numberCharacterRange = [currentText rangeOfCharacterFromSet:self.numberCharacterSet
                                                                    options:NSBackwardsSearch
                                                                      range:NSMakeRange(0, range.location)];
        // adjust replace range
        if (numberCharacterRange.location != NSNotFound) {
            range = NSUnionRange(range, numberCharacterRange);
        }
    }
    
    NSString *newString = [currentText stringByReplacingCharactersInRange:range withString:string];
    
    // formatting card number
    textField.text = [self.cardNumberFormatter formattedStringFromRawString:newString];

    // send editing changed action because we edited text manually.
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
    
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([self.userDelegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        if (NO == [self.userDelegate textFieldShouldClear:textField]) {
            return NO;
        }
    }
    
    // reset card number formatter
    textField.text = [self.cardNumberFormatter formattedStringFromRawString:@""];
    
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
    
    return NO;
}

- (void)textFieldEditingChanged:(id)sender
{
    [self updateCardLogoImage];
    [self updateCardLogoLabel];
}

#pragma mark - Private Methods

- (void)updateCardLogoImage
{
    if (nil == self.logoImage) {
        return;
    }
    
    BKCardPatternInfo *patternInfo = self.cardNumberFormatter.cardPatternInfo;
    
    UIImage *cardLogoImage = [BKMoneyUtils cardLogoImageWithShortName:patternInfo.shortName];
    
    self.logoImage.image = cardLogoImage;
	NSLog(@"updated logo image: %@", patternInfo.shortName);
}

- (void)updateCardLogoLabel
{
    if (nil == self.logoLabel) {
        return;
    }
    
    NSString* name = self.cardNumberFormatter.cardPatternInfo.shortName;
	if (!name) name = @"none";
   
	NSLog(@"updated logo label: %@, %@", name, LFCreditCardCompanyDinersClub);
	name = self.logoLabels[name];
	if (!name) name = self.logoLabels[LFCreditCardCompanyDefault];

    self.logoLabel.text = name;
}

#pragma mark - Public Methods

- (void)setShowsCardLogo:(BOOL)showsCardLogo
{
    if (_showsCardLogo != showsCardLogo) {
        _showsCardLogo = showsCardLogo;
        
        if (showsCardLogo) {
            
            CGFloat size = CGRectGetHeight(self.frame);
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44.f, size)];
            imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            imageView.contentMode = UIViewContentModeCenter;
            
            self.leftView = imageView;
            self.leftViewMode = UITextFieldViewModeAlways;
            
            self.logoImage = imageView;
            
            [self updateCardLogoImage];
            
        } else {
            self.leftView = nil;
        }
    }
}

- (void)setShowsLogoLabel:(BOOL)showsLogoLabel
{
    if (_showsLogoLabel != showsLogoLabel) {
        _showsLogoLabel = showsLogoLabel;
        
        if (showsLogoLabel) {
            
            CGFloat size = CGRectGetHeight(self.frame);
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.logoWidth, size)];
            label.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            label.contentMode = UIViewContentModeCenter;
			label.font = [UIFont fontWithName:@"airservice-icons" size:18];
			label.textColor = [UIColor darkGrayColor];
            
            self.leftView = label;
            self.leftViewMode = UITextFieldViewModeAlways;
            
            self.logoLabel = label;
            
            [self updateCardLogoLabel];
            
        } else {
            self.leftView = nil;
        }
    }
}

- (void)setCardNumber:(NSString *)cardNumber
{
    self.text = [self.cardNumberFormatter formattedStringFromRawString:cardNumber];
    [self updateCardLogoImage];
    [self updateCardLogoLabel];
}

- (NSString *)cardNumber
{
    return [self.cardNumberFormatter rawStringFromFormattedString:self.text];
}

- (NSString *)cardCompanyName
{
    return self.cardNumberFormatter.cardPatternInfo.companyName;
}

- (UILabel*)enableLogoLabel
{
	self.showsLogoLabel = YES;
	return self.logoLabel;
}

- (UIImageView*)enableLogoImage
{
	self.showsCardLogo = YES;
	return self.logoImage;
}

@end
