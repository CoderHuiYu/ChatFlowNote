// Copyright © 2017 Tellus, Inc. All rights reserved.

#import <Foundation/Foundation.h>

// MARK: Constants
/*******************************************
 * Constants class... just a shell of a class
 *******************************************/
/*******************************************
 * Constant for layout
 *******************************************/
extern NSInteger const kZLStandardViewRadius;
extern NSInteger const kZLContactTagsRadius;
extern NSInteger const kZLStandardPadding;

/*******************************************
 * STORYBOARD_ID
 *******************************************/

extern NSString * const kZLMonthPickerStoryboardID;
extern NSString * const kZLDayTermPickerStoryboardID;
extern NSString * const kZLLateFeeModeStoryboardID;

/*******************************************
 * KEY OBJECT
 *******************************************/
// User Role
extern NSString * const kZLRoleOwnerKey;
extern NSString * const kZLRoleTenantKey;
extern NSString * const kZLRolePendingTenantKey;
extern NSString * const kZLRoleManagerKey;
extern NSString * const kZLRolePendingManagerKey;
extern NSString * const kZLRoleRealtorKey;
extern NSString * const kZLRolePendingRealtorKey;

// User
extern NSString * const kZLUserIDKey;
extern NSString * const kZLUserQRCodeKey;
extern NSString * const kZLUserKey;

// ERROR Object
extern NSString * const kZLErrorKey;
extern NSString * const kZLJSONKey;
extern NSString * const kZLMetaKey;

// Files and Photos
extern NSString * const kZLPhotosKey;
extern NSString * const kZLFilesKey;
extern NSString * const kZLTypeKey;

// Contact
extern NSString * const kZLFileKey;

// Address Book
extern NSString * const kZLAddressBookContactIdKey;
extern NSString * const kZLAddressBookContactNameKey;
extern NSString * const kZLAddressBookContactFirstNameKey;
extern NSString * const kZLAddressBookContactLastNameKey;
extern NSString * const kZLAddressBookContactEmailsKey;
extern NSString * const kZLAddressBookContactPhonesKey;
extern NSString * const kZLAddressBookContactPhonesFlattenedKey;
extern NSString * const kZLAddressBookContactHasPhoneKey;
extern NSString * const kZLAddressBookContactHasEmailKey;

/*******************************************
 * HEIGHT OF CELLS
 *******************************************/
extern CGFloat const kZLFormEditorCellHeight;

// MARK: Typedefs
/*******************************************
 * Typedefs
 *******************************************/
typedef void(^ZLActionBlock)(void);
typedef void(^ZLCompletionBlock)(void);
typedef void(^ZLSaveCompletionBlock)(BOOL success, NSError *error);
typedef void(^ZLObjCCompletionBlock)(id object, NSError *error);
typedef void(^ZLSimpleRequestCompletionBlock)(NSError *error);
typedef void(^ZLContactTagBlock)(NSString *tag);
