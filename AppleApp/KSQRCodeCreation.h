//
//  KSQRCodeCreations.h
//  DynamicQRCodes
//
//  Created by Scott Moody on 4/2/26.
//
//
//  KSQRCodeCreation.h
//  KSQRAvatar
//
//  Created by Scott Moody on 2/13/21.
//

#import <Foundation/Foundation.h>
@import PhotosUI;
#import <UIKit/UIKit.h>


//! the caller creates this object once, and then if they want to edit the QR address, then can use the displayAlert method, which will update the address in the object.
//! Then to create an object, the createQRAvatar is called. So the image is passed in, but the address should be set by the displayAlert UI??
//! NOTE: start with mode where display alert called, then createQRAvatar called..
@interface KSQRCodeCreation : NSObject

#define ROOTURL @"yourURL_where_node-red_runs"

#pragma mark - AlertsForRegisteringAddress

//!new 8.2.21
//!creates Alert for QR Code for editing
// Step 1
//! invokes the ROOTURL/train/ks with these parameters
//! @param address the html address to eventually call
//! @param category the Genre
//! @param namespace the namespace of the users request
//! @param uuid the users unique id
//! @param viewController the viewController if any alerts are needed
-(void) registerQRMappingAlert:(NSString*)address category:(NSString*)category namespace:(NSString*)namespace uuid:(NSString*)uuid viewController:(UIViewController*)viewController;

//! calls special :/isregistered/ks/category/namespace/uuid  -- and gets back a result
//! issue is the Asynchronous nature ...  so only in the session handler..
//! see https://developer.apple.com/forums/thread/11519
//! ! THis will call the createAndRegisterFullTrainedAddress...
//! @param address the html address to eventually call
//! @param category the Genre
//! @param namespace the namespace of the users request
//! @param uuid the users unique id
//! @param viewController the viewController if any alerts are needed
-(void) existsTrainedAddress:(NSString*) address category:(NSString*)category namespace:(NSString*)namespace uuid:(NSString*)uuid viewController:(UIViewController*)viewController;

//!if the user want to overwrite, then they can enter a password??
//! NOTE: the address is normal address, not special escaped yet..
//! @param address the html address to eventually call
//! @param category the Genre
//! @param namespace the namespace of the users request
//! @param uuid the users unique id
-(void) askToOverwriteQRMapping:(NSString*) address category:(NSString*)category namespace:(NSString*)namespace uuid:(NSString*)uuid viewController:(UIViewController*)viewController;

//!full address =  https://KnowledgeShark.me/red/ks/category/namespace/uuid
//! invokes the NODE_RED_URL/train/ks with these parameters
//! @param address the html address to eventually call, this will be escaped inside this method
//! @param category the Genre
//! @param namespace the namespace of the users request
//! @param uuid the users unique id
//! @param viewController the viewController if any alerts are needed
-(void) createAndRegisterFullTrainedAddress:(NSString*) address category:(NSString*)category namespace:(NSString*)namespace uuid:(NSString*)uuid viewController:(UIViewController*)viewController;

@end




