//
//  LFSCreditCardTextField.m
//  LFSCreditCardTextField
//
//  Created by Lluís Gómez Hernando on 25/04/13.
//  Copyright (c) 2013 lluisgh28. All rights reserved.
//

#import "LFSCreditCardTextField.h"

@implementation LFSCreditCardTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setIconImageView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cardIcon"]]];
        
        [self setLeftViewMode:UITextFieldViewModeAlways];
        [self setLeftView:[self iconImageView]];
        
        [self setPlaceholder:@"1234 5678 9012 3456"];
        
        [self setKeyboardType:UIKeyboardTypeNumberPad];
        
        [self setDelegate:self];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = [[self leftView] frame];
    frame.origin.x += 4;
    
    [[self leftView] setFrame:frame];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 28, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 28, 0);
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{        
    if (range.location == 18) {
        if ([string length] == 1) {
            [self setText:[NSString stringWithFormat:@"%@%@", [self text], string]];
            if ([self creditCardNumberIsValid]) {
                [self setTextColor:[UIColor greenColor]];
            } else {
                [self setTextColor:[UIColor redColor]];
            }
            return NO;
        }
    }
    // Only the 16 digits + 3 spaces
    if (range.location == 19) {
        return NO;
    }
    // Deleted first number of a quartet
    if ([string length] == 0 && (range.location == 5 || range.location == 10 || range.location == 15)) {
        NSString *newString = [[self text] substringToIndex:range.location];
        [textField setText:newString];
        [self setTextColor:[UIColor blackColor]];
        return YES;
    }    
    
    // Written first number of a quartet
    if (range.location == 4 || range.location == 9 || range.location == 14) {
        NSString *newString = [NSString stringWithFormat:@"%@ ",[textField text]];
        [textField setText:newString];
        return YES;
    }
    
    
    return YES;
}


#pragma mark - Credit Card Number methods

// Returns a string of integers, without dashes, spaces, etc.
- (NSString *)cleanCreditCardNumber {
	// Efficient way found at:
	// http://stackoverflow.com/questions/1129521/remove-all-but-numbers-from-nsstring/1426819#1426819
	return [[[self text] componentsSeparatedByCharactersInSet:
             [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
            componentsJoinedByString:@""];
}

// Returns the industry of the credit card issuer based on the
// Major Industry Identifier (MII).
- (NSString *)majorIndustry {
	int int_c = 10; // Will return "Unknown/Invalid" by default.
    
	NSString *cleanCardNo = [self cleanCreditCardNumber];
    
	NSArray *MII = [NSArray arrayWithObjects:
                    @"ISO/TC 68 and other future industry assignments",
                    @"Airlines",
                    @"Airlines and other future industry assignments",
                    @"Travel and entertainment and banking/financial",
                    @"Banking and financial",
                    @"Banking and financial",
                    @"Merchandising and banking/financial",
                    @"Petroleum and other future industry assignments",
                    @"Healthcare, telecommunications and other future industry assignments",
                    @"National assignment",
                    @"Unknown/Invalid", nil];
    
	if ([cleanCardNo length] != 0) {
		// Get the first digit since that's all that matters for MII.
		int_c = [[NSString stringWithFormat:@"%c", [cleanCardNo characterAtIndex:0]] intValue];
	}
    
	return [MII objectAtIndex:int_c];
}

// Returns the name of the credit card issuer based on the
// Issuer Identification Number (IIN).
// NOTE: This may not be complete and will return "Unknown" if not found.
- (NSString *)issuer {
	// TODO
    
	// NOTES: Some well known ones are:
	// 34xxxx, 37xxxx - American Express
	// 4xxxxx - Visa
	// 51xxxx - 55xxxx - MasterCard
	// 6011xx - Discover
    
	return @"TODO";
}

// Based on the Luhn Algorithm. This method doubles every other digit, starting
// from the end, skipping the check digit. Then all digits are added.
// NOTE 1: When a doubled digit returns a 2-digit number, each digit is added
// separately.
// NOTE 2: Returns -1 if aCreditCardNo is empty.
- (int)creditCardNumberIsValid {
	int nthChar = 1; // Used for tracking with nth digit we're on in the loop.
	int sum = 0;
    
	NSString *cleanCardNo = [self text];
    
	if ([cleanCardNo length] != 0) {
		// This for-loop goes from end to start.
		for (int i = [cleanCardNo length] - 1; i >= 0; i--) {
			int int_c = [[NSString stringWithFormat:@"%c", [cleanCardNo characterAtIndex:i]] intValue];
            
			if (nthChar % 2 == 0) {
				// Double every other digit starting from the 2nd from the end.
				int doubledValue = 0;
				doubledValue = int_c * 2;
                
				if (doubledValue >= 10) {
					// If 2-digit result, add each digit separately.
					// Adding 1 on the end always since maximum doubled digit will
					// always be 18 only (9 * 2).
					sum = sum + (doubledValue % 10) + 1;
				} else {
					// If 1-digit result, just add to the sum.
					sum = sum + doubledValue;
				}
                
			} else {
				// Otherwise, just add to the sum.
				sum = sum + int_c;
			}
			nthChar++;
		}
	} else {
		sum = -1;
	}
    
    // Sum is now a Luhn number
    // If aLuhnNo is a number divisible by 10, then the Credit Card No.
    // may be valid. Otherwise, it is definitely not valid.
	return sum % 10 == 0;
}


@end
