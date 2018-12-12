// Copyright © 2017 Tellus, Inc. All rights reserved.

#import "ZLConstants.h"

/*******************************************
 * Constants class... just a shell of a class
 *******************************************/
/*******************************************
 * Constant for layout
 *******************************************/
 NSInteger const kZLStandardViewRadius    = 4;
 NSInteger const kZLStandardPadding       = 16;

/*******************************************
 * STORYBOARD_ID
 *******************************************/

 NSString * const kZLMonthPickerStoryboardID      = @"MonthPicker";
 NSString * const kZLDayTermPickerStoryboardID    = @"DayTermPicker";
 NSString * const kZLLateFeeModeStoryboardID      = @"LateFeeMode";

/*******************************************
 * KEY OBJECT
 *******************************************/
// User Role
 NSString * const kZLRoleOwnerKey                 = @"owner";
 NSString * const kZLRoleTenantKey                = @"tenant";
 NSString * const kZLRolePendingTenantKey         = @"pending_tenant";
 NSString * const kZLRoleManagerKey               = @"manager";
 NSString * const kZLRolePendingManagerKey        = @"pending_manager";
 NSString * const kZLRoleRealtorKey               = @"realtor";
 NSString * const kZLRolePendingRealtorKey        = @"pending_realtor";

// User
 NSString * const kZLUserIDKey                    = @"user_id";
 NSString * const kZLUserQRCodeKey                = @"qrcode";
 NSString * const kZLUserKey                      = @"user";

// ERROR Object
 NSString * const kZLErrorKey                     = @"error";
 NSString * const kZLJSONKey                      = @"json";
 NSString * const kZLMetaKey                      = @"meta";

// Files and Photos
 NSString * const kZLPhotosKey                    = @"photos";
 NSString * const kZLFilesKey                     = @"files";
 NSString * const kZLTypeKey                      = @"type";

// Contact
 NSString * const kZLFileKey                      = @"file";

// Address Book
 NSString * const kZLAddressBookContactIdKey        = @"id";
 NSString * const kZLAddressBookContactNameKey      = @"name";
 NSString * const kZLAddressBookContactFirstNameKey = @"firstName";
 NSString * const kZLAddressBookContactLastNameKey  = @"lastName";
 NSString * const kZLAddressBookContactEmailsKey    = @"emails";
 NSString * const kZLAddressBookContactPhonesKey    = @"phones";
 NSString * const kZLAddressBookContactPhonesFlattenedKey = @"phonesFlattened";
 NSString * const kZLAddressBookContactHasPhoneKey  = @"hasPhone";
 NSString * const kZLAddressBookContactHasEmailKey  = @"hasEmail";

/*******************************************
 * HEIGHT OF CELLS
 *******************************************/
 CGFloat const kZLFormEditorCellHeight            = 90;
