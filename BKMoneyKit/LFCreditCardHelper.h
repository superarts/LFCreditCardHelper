#import "BKCardExpiryField.h"
#import "BKCardNumberFormatter.h"
#import "BKCardPatternInfo.h"
#import "BKForwardingTextField.h"
#import "BKCardNumberField.h"
#import "BKCardNumberLabel.h"
#import "BKCurrencyTextField.h"
#import "BKMoneyUtils.h"

typedef NSString* LFCreditCardCompany;

#define LFCreditCardCompanyNone				@"none"
#define LFCreditCardCompanyDinersClub		@"dinersclubintl"
#define LFCreditCardCompanyJCB				@"jcb"
#define LFCreditCardCompanyAmericanExpress	@"amex"
#define LFCreditCardCompanyLaserCard		@"laser"
#define LFCreditCardCompanyVisa				@"visa"
#define LFCreditCardCompanyUnionPay			@"unionpay"
#define LFCreditCardCompanyMasterCard		@"mastercard"
#define LFCreditCardCompanyMaestro			@"maestro"
#define LFCreditCardCompanyDiscover			@"discover"
#define LFCreditCardCompanyDefault			LFCreditCardCompanyNone
