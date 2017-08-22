//
//  BranchEvent.m
//  Branch-SDK
//
//  Created by Edward Smith on 7/24/17.
//  Copyright © 2017 Branch Metrics. All rights reserved.
//

#import "BranchEvent.h"
#import "BNCLog.h"

#pragma mark BranchStandardEvents

// Commerce events

BranchStandardEvent BranchStandardEventAddToCart          = @"ADD_TO_CART";
BranchStandardEvent BranchStandardEventAddToWishlist      = @"ADD_TO_WISHLIST";
BranchStandardEvent BranchStandardEventViewCart           = @"VIEW_CART";
BranchStandardEvent BranchStandardEventInitiatePurchase   = @"INITIATE_PURCHASE";
BranchStandardEvent BranchStandardEventAddPaymentInfo     = @"ADD_PAYMENT_INFO";
BranchStandardEvent BranchStandardEventPurchase           = @"PURCHASE";
BranchStandardEvent BranchStandardEventSpendCredits       = @"SPEND_CREDITS";

// Content Events

BranchStandardEvent BranchStandardEventSearch             = @"SEARCH";
BranchStandardEvent BranchStandardEventViewContent        = @"VIEW_CONTENT";
BranchStandardEvent BranchStandardEventViewContentList    = @"VIEW_CONTENT_LIST";
BranchStandardEvent BranchStandardEventRate               = @"RATE";
BranchStandardEvent BranchStandardEventShareContent       = @"SHARE_CONTENT";

// User Lifecycle Events

BranchStandardEvent BranchStandardEventCompleteRegistration   = @"COMPLETE_REGISTRATION";
BranchStandardEvent BranchStandardEventCompleteTutorial       = @"COMPLETE_TUTORIAL";
BranchStandardEvent BranchStandardEventAchieveLevel           = @"ACHIEVE_LEVEL";
BranchStandardEvent BranchStandardEventUnlockAchievement      = @"UNLOCK_ACHIEVEMENT";

#pragma mark - BranchEventRequest

@interface BranchEventRequest : BNCServerRequest <NSCoding>

- (instancetype) initWithServerURL:(NSURL*)serverURL
                   eventDictionary:(NSDictionary*)eventDictionary
                        completion:(void (^)(NSDictionary* response, NSError* error))completion;

@property (strong) NSDictionary *eventDictionary;
@property (strong) NSURL *serverURL;
@property (copy)   void (^completion)(NSDictionary* response, NSError* error);
@end

@implementation BranchEventRequest

- (instancetype) initWithServerURL:(NSURL*)serverURL
                   eventDictionary:(NSDictionary*)eventDictionary
                        completion:(void (^)(NSDictionary* response, NSError* error))completion {

	self = [super init];
	if (!self) return self;

	self.serverURL = serverURL;
	self.eventDictionary = eventDictionary;
	self.completion = completion;
	return self;
}

- (void)makeRequest:(BNCServerInterface *)serverInterface
			    key:(NSString *)key
           callback:(BNCServerCallback)callback {
    [serverInterface postRequest:self.eventDictionary
							 url:[self.serverURL absoluteString]
							 key:key
						callback:callback];
}

- (void)processResponse:(BNCServerResponse*)response
				  error:(NSError*)error {
	NSDictionary *dictionary =
		([response.data isKindOfClass:[NSDictionary class]])
		? (NSDictionary*) response.data
		: nil;
		
	if (self.completion)
		self.completion(dictionary, error);
}

#pragma mark BranchEventRequest NSCoding

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
	if (!self) return self;

	self.serverURL = [decoder decodeObjectForKey:@"serverURL"];
	self.eventDictionary = [decoder decodeObjectForKey:@"eventDictionary"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self.serverURL forKey:@"serverURL"];
    [coder encodeObject:self.eventDictionary forKey:@"eventDictionary"];
}

@end

#pragma mark - BranchEvent

@interface BranchEvent () {
    NSMutableDictionary *_userInfo;
}
@property (nonatomic, strong) NSString*  eventName;
@end

@implementation BranchEvent : NSObject

- (instancetype) initWithName:(NSString *)name {
    self = [super init];
    if (!self) return self;
    _eventName = name;
    return self;
}

+ (instancetype) standardEventWithType:(BranchStandardEvent)standardEvent {
    return [[BranchEvent alloc] initWithName:standardEvent];
}

+ (instancetype) standardEventWithType:(BranchStandardEvent)standardEvent
                           contentItem:(BranchUniversalObject*)contentItem {
    BranchEvent *e = [BranchEvent standardEventWithType:standardEvent];
    if (contentItem) {
        e.contentItems = @[ contentItem ];
    }
    return e;
}

+ (instancetype) customEventWithName:(NSString*)name {
    return [[BranchEvent alloc] initWithName:name];
}

+ (instancetype) customEventWithName:(NSString*)name
                         contentItem:(BranchUniversalObject*)contentItem {
    BranchEvent *e = [[BranchEvent alloc] initWithName:name];
    if (contentItem) {
        e.contentItems = @[ contentItem ];
    }
    return e;
}

- (NSMutableDictionary*) userInfo {
    if (!_userInfo) _userInfo = [NSMutableDictionary new];
    return _userInfo;
}

- (void) setUserInfo:(NSMutableDictionary<NSString *,NSString *> *)userInfo {
    if ([userInfo isKindOfClass:[NSMutableDictionary class]]) {
        _userInfo = userInfo;
    } else if ([userInfo isKindOfClass:[NSDictionary class]]) {
        _userInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    }
}

- (NSDictionary*) dictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];

    #define BNCFieldDefinesDictionaryFromSelf
    #include "BNCAddFieldDefines.h"

    addString(transactionID,    transaction_id);
    addString(currency,         currency);
    addDecimal(revenue,         revenue);
    addDecimal(shipping,        shipping);
    addDecimal(tax,             tax);
    addString(coupon,           coupon);
    addString(affiliation,      affiliation);
    addString(eventDescription, description);
    addString(productCondition, $condition);
    addDictionary(userInfo,     custom_data);
    
    #include "BNCAddFieldDefines.h"

    return dictionary;
}

+ (NSArray<BranchStandardEvent>*) standardEvents {
    return @[
        BranchStandardEventAddToCart,
        BranchStandardEventAddToWishlist,
        BranchStandardEventViewCart,
        BranchStandardEventInitiatePurchase,
        BranchStandardEventAddPaymentInfo,
        BranchStandardEventPurchase,
        BranchStandardEventSpendCredits,
        BranchStandardEventSearch,
        BranchStandardEventViewContent,
        BranchStandardEventViewContentList,
        BranchStandardEventRate,
        BranchStandardEventShareContent,
        BranchStandardEventCompleteRegistration,
        BranchStandardEventCompleteTutorial,
        BranchStandardEventAchieveLevel,
        BranchStandardEventUnlockAchievement,
    ];
}

- (void) logEvent {

    if (![_eventName isKindOfClass:[NSString class]] || _eventName.length == 0) {
        BNCLogError(@"Invalid event type '%@' or empty string.", NSStringFromClass(_eventName.class));
        return;
    }

    NSMutableDictionary *eventDictionary = [NSMutableDictionary new];
    eventDictionary[@"name"] = _eventName;

    NSDictionary *propertyDictionary = [self dictionary];
    if (propertyDictionary.count) {
        eventDictionary[@"event_data"] = propertyDictionary;
    }
    eventDictionary[@"custom_data"] = eventDictionary[@"event_data"][@"custom_data"];
    eventDictionary[@"event_data"][@"custom_data"] = nil;

    NSMutableArray *contentItemDictionaries = [NSMutableArray new];
    for (BranchUniversalObject *contentItem in self.contentItems) {
        NSDictionary *dictionary = [contentItem dictionary];
        if (dictionary.count) {
            [contentItemDictionaries addObject:dictionary];
        }
    }

    if (contentItemDictionaries.count) {
        eventDictionary[@"content_items"] = contentItemDictionaries;
    }

    BNCPreferenceHelper *preferenceHelper = [BNCPreferenceHelper preferenceHelper];
    NSString *serverURL =
        ([self.class.standardEvents containsObject:self.eventName])
        ? [NSString stringWithFormat:@"%@/%@", preferenceHelper.branchAPIURL, @"v2/event/standard"]
        : [NSString stringWithFormat:@"%@/%@", preferenceHelper.branchAPIURL, @"v2/event/custom"];

    BranchEventRequest *request =
		[[BranchEventRequest alloc]
			initWithServerURL:[NSURL URLWithString:serverURL]
			eventDictionary:eventDictionary
			completion:nil];

    [[Branch getInstance] sendServerRequestWithoutSession:request];
}

@end
