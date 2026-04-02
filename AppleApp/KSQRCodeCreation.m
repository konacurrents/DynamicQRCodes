//
//  KSQRCodeCreation.h
//  KSQRAvatar
//
//  Created by Scott Moody on 2/13/21.
//
///KSQRCodeCreations.m
//  DynamicQRCodes
//
//  Created by Scott Moody on 4/2/26.
//
//!manages creation and recognization of QRCodes (AVM)
@implementation KSQRCodeCreation
{
    NSString *_rootURL;
}
#define ROOTURL @"BobsYourUncle.com";

-(void) setRootURL:(NSString*)rootURL
{
    _rootURL = rootURL;
}

#pragma mark - AlertsForRegisteringAddress

//TODO:  take an http address, and special escape it..
// (1) escape it
// (2) train it..  (this requires getting the NameSpace and UUID)
//  https://ROOTURL/train/category/AVMArch/a/https:||ROOTURL
// the calls now will do the indirection..
//! https://www.werockyourweb.com/url-escape-characters/
//! NEW TEST:
//! seems only needs the ? encoded.. == %3F https://www.ocrolus.com/ocr-vs-intelligent-automation/?utm_source=google&utm_medium=cpc&utm_campaign=Google_Search_NB_OCR_Beta&utm_content=13890951809&utm_term=ocr%20system&hsa_acc=9653658299&hsa_cam=13890951809&hsa_grp=124200948185&hsa_ad=533449811887&hsa_src=g&hsa_tgt=kwd-326350734420&hsa_kw=ocr%20system&hsa_mt=p&hsa_net=adwords&hsa_ver=3&gclid=CjwKCAjwgviIBhBkEiwA10D2jxGMR-KUv5lLDh2-wQRRzhSzm8NEuFZ-ULPKkUB8GqmqxLHmg9wu-BoC9TgQAvD_BwE'
//! replace address to create trainable address
-(NSString*) createKSTrainableAddress:(NSString*)trainableAddress
{
    //NOTE: this is still in-work. The idea is the parts might not need to be encoded, especially if already encoded.
    // replace "/" with "|",  replace # with %23
    // what about ?   and =   ??TODO??
    // YES: ? = %3F
    //NSString *escapedAddress = [trainableAddress stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    //or: [NSCharacterSet URLFragmentAllowedCharacterSet]
    //https://stackoverflow.com/questions/42529509/stringbyaddingpercentescapesusingencoding-deprecated
    //https://stackoverflow.com/questions/32242712/replacement-for-stringbyaddingpercentescapesusingencoding-in-ios9
    NSString *newAddress = [trainableAddress stringByReplacingOccurrencesOfString:@"/" withString:@"%7C"];
    newAddress = [newAddress stringByReplacingOccurrencesOfString:@"#" withString:@"%23"];
    newAddress = [newAddress stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
    
    return newAddress;
}

/**
 This is a few asynchronous calls, since at least 1 is a HTTP call to see if the address exists
 Basically a QRaddress made up of the category/namespace/uuid are the result, but it must
 register the special escaped QRaddress (which might be a cut-n-past from the web). But the resulting QR is the
 ROOTURL/ks/CATEGORY/NAMESPACE/UUID
 (1) registerStuffAlert will use defaults for category and namespace, and a unique UUID ..
 (2) existsQRAddress is called to see if the address is already used.. if so then confirm overwrite (maybe TODO with password)
 if (exists)
 (2a) askToOverwriteQRMapping:(NSString*) address  called if the QR already exists..
 if (overwrite)
 (2a.a) calls register  (train/ks/category/namespace/uuid/mapping)   createAndRegisterFullTrainedAddress
 sets the QR of the new name (ks/category/namespace/uuid)
 
 else
 (2b) confirmRegisterStuffAlert:(NSString*)qrAddress  ..  (THIS doesn't know if the QR exists or not..)
 (2b.a) calls register  (train/ks/category/namespace/uuid/mapping)   createAndRegisterFullTrainedAddress
 sets the QR of the new name (ks/category/namespace/uuid)
 
 //Then sets the QR to be the short name (not the mapping name)
 */

//@see https://stackoverflow.com/questions/21403323/url-encoding-a-string/21404487#21404487
-(NSString*) stripSpaces:(NSString*)string
{
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    return string;
}

/* need to support:
 A URL can be also be divided into pieces based on its structure. For example, the URL https://johnny:p4ssw0rd@www.example.com:443/script.ext;param=value?query=value#ref contains the following URL components:
 
 Seems the | is not a valid URL in their eyes...
 */
//!new 8.2.21
//!creates Alert for QR Code for editing
// Step 1
//! @param address the html address to eventually call
//! @param category the Genre
//! @param namespace the namespace of the users request
//! @param uuid the users unique id
-(void) registerQRMappingAlert:(NSString*)address category:(NSString*)category namespace:(NSString*)namespace uuid:(NSString*)uuid viewController:(UIViewController*)viewController
{
    
    
    NSString *message = [NSString stringWithFormat:@"Enter Category/Namespace for Address:\n %@", address];
    // use UIAlertController
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Semantic Marker(R)"
                               message:message
                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Register..." style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        
        //Do Some action here
        UITextField *category = alert.textFields[0];
        NSLog(@"confirmRegisterStuffAlert= %@", category.text);
        [self stripSpaces:category.text];
        // [self setCurrentQRCodeText:textField1.text];
        
        UITextField *namespace = alert.textFields[1];
        [self stripSpaces:namespace.text];
        
        NSLog(@"namespace= %@", namespace.text);
        
        
        UITextField *uuid = alert.textFields[2];
        [self stripSpaces:uuid.text];
        
        NSLog(@"uuid= %@", uuid.text);
        
        
        //    [self confirmRegisterStuffAlert:qrAddress category:category.text namespace:namespace.text uuid:uuid.text viewController:viewController];
        
        // dispatch_sync(dispatch_get_main_queue(), ^{
        //!!! Call to see if this name already exists... This is Async so it will call the createAndRegisterFull ... if supported..
        [self existsTrainedAddress:address category:category.text namespace:namespace.text uuid:uuid.text viewController:viewController];
        
        //!basically this method is asynchronous .. so needs to call something here.. (a protocol) and if it exists, then ask to overright (maybe with a personal password?)
        //Syntax:
        //  <base>/train/ks/CATEGORY/NAMESPACE/UUID/<escaped URL>
        
        // });
        
    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
        
        NSLog(@"cancel btn");
        [alert dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    /**
     addTextFieldWithConfigurationHandler: Calling this method adds an editable text field to the alert. You can call this method more than once to add additional text fields. The text fields are stacked in the resulting alert.
     You can add a text field only if the preferredStyle property is set to UIAlertControllerStyleAlert.
     
     NOTE: these need to stay in this order, and the above 'textField[0]' is category, etc..
     */
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = category;
        textField.text = category;
        textField.keyboardType = UIKeyboardTypeDefault;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = namespace;
        textField.text = namespace;
        textField.keyboardType = UIKeyboardTypeDefault;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = uuid;
        textField.text = uuid;
        textField.keyboardType = UIKeyboardTypeDefault;
        //don't let them edit this..
        textField.enabled = false;
    }];
    
    ///show it.. and get a double confirmation..
    [viewController presentViewController:alert animated:YES completion:^{
        NSLog(@"viewController done..");
    }];
    
}

#pragma mark Web calls on node-red


//! calls special :/exists/ks/category/namespace/uuid  -- and gets back a result of a web page:
//! UnknownQRCode.jpeg  or
//! issue is the Asynchronous nature ...  so only in the session handler..
//! see https://developer.apple.com/forums/thread/11519
//!
//! NOTE: this is Asynchronous .. to next step is required on callback ... TODO
//! for now, this knows to call the next step..
//!     if exists .. then ask to overwrite [self askToOverwriteQRMapping]
//!  otherwise, doesn't exist, so just go for it..
//! @param address the html address to eventually call
//! @param category the Genre
//! @param namespace the namespace of the users request
//! @param uuid the users unique id
-(void) existsTrainedAddress:(NSString*)address category:(NSString*)category namespace:(NSString*)namespace uuid:(NSString*)uuid viewController:(UIViewController*)viewController
{
    NSLog(@"existsTrainedAddress (%@, %@/%@/%@)", address,category,namespace,uuid);
    //Right now the category isn't used in the mapping (well it could be in the future..)
    NSString *rootAddress = @"https://ROOTURL/red";
    
    NSString *fullExistsTrainingString = [NSString stringWithFormat:@"%@/exists/ks/%@/%@/%@", rootAddress,category,namespace, uuid];
    // call this in...
    // then result ==
    // call web: with the fullTrainingString..
    NSURL *url = [[NSURL alloc]initWithString:fullExistsTrainingString];
    NSURLSessionTask *sessionTask =
    [NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"finished exists.. %@ response = %@, error = %@", uuid, response, error);
        if ([[response.URL lastPathComponent] isEqualToString:@"UnknownQRCode.jpeg"])
        {
            NSLog(@" ** QR Code is not defined yet... TODO register..");
            //NOTE: this assumes this is the address to register.. no take backs..
            //  [self qrAddressSelectedFullAddress:trainedAddress];
            //how does the alert get back here?
            //NOTE: this actually calls someones "qrAddressSelected" HERE
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self createAndRegisterFullTrainedAddress:address category:category namespace:namespace uuid:uuid viewController:viewController];
                
            });
        }
        else if ([[response.URL lastPathComponent] isEqualToString:@"QRExists.jpeg"])
        {
            NSLog(@" ** QR Code is already defined .. overwrite?");
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self askToOverwriteQRMapping:address category:category namespace:namespace uuid:uuid viewController:viewController];
                
            });
        }
        else
        {
            //  NSLog(@"finished exists.. %@ response = %@, error = %@", uuid, response, error);
            
            NSLog(@" *** Unknown Error ... cancelling operation.. %@", error);
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSString *errorString = [NSString stringWithFormat:@"%@", error];
                [self displayAlertMessage:@"Failed SemanticMarker Registration" message:errorString viewController:viewController];
            });
        }
    }];
    [sessionTask resume];
    //
    //    NSString *trainedAddress = [NSString stringWithFormat:@"%@/ks/%@/%@/%@", rootAddress, category, namespace, uuid];
    //    //NOTE: in future, could probably use just the UUID  ..
    //    NSLog(@"trainiedAddress = %@", trainedAddress);
    //    return trainedAddress;
}


//!if the user want to overwrite, then they can enter a password??
//! NOTE: the address is normal address, not special escaped yet..
//! @param address the html address to eventually call
//! @param category the Genre
//! @param namespace the namespace of the users request
//! @param uuid the users unique id
-(void) askToOverwriteQRMapping:(NSString*) address category:(NSString*)category namespace:(NSString*)namespace uuid:(NSString*)uuid viewController:(UIViewController*)viewController
{
    // use UIAlertController
    NSString *qrExists = [NSString stringWithFormat:@"%@/%@/%@ -> %@",category, namespace, uuid, address];
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"QRAddress mapping exists"
                               message:qrExists
                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Overwrite?" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        //Do Some action here
        NSLog(@" ** overwrite TODO");
        //TODO: perform register..
        //      NSString *trainedAddress = [self createAndRegisterFullTrainedAddress:address category:category namespace:namespace uuid:uuid viewController:viewController];
        //NOTE: this assumes this is the address to register.. no take backs..
        //      [self qrAddressSelectedFullAddress:trainedAddress];
        //how does the alert get back here?
        //NOTE: this actually calls someones "qrAddressSelected" HERE
        
        //Syntax:
        //  <base>/train/ks/CATEGORY/NAMESPACE/UUID/<escaped URL>
        
        //  dispatch_sync(dispatch_get_main_queue(), ^{
        [self createAndRegisterFullTrainedAddress:address category:category namespace:namespace uuid:uuid viewController:viewController];
        
        //
        
        
    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        NSLog(@"cancel btn");
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    ///show it.. and get a double confirmation..
    [viewController presentViewController:alert animated:YES completion:^{
        NSLog(@"viewController done..");
    }];
}

//! 12.4.24 nice day, skiied monday, above fog finally
//! testing
-(void) testKSQRCodeCreation
{
    
    NSString *testAddress = @"https:%7C%7Cwww.instagram.com%7Cmenotti2468%3Figsh=MWNsY2g5aHptenB2ZQ==";
    
    //!address the html address to eventually call, this will be escaped inside this method
    NSString *address = testAddress;
    
    NSString *category = @"lisa";
    NSString *namespace = @"instagram%20"; //?? how done
    NSString *uuid = @"QHmwUUrxC3";
    
    NSString *rootAddress = @"https://ROOTURL";
    
    // this is passed as URL to the web
    NSString *trainableAddressSpecialEscaped = [self createKSTrainableAddress:address];
    NSString *trainedAddress = [NSString stringWithFormat:@"%@/ks/%@/%@/%@", rootAddress, category, namespace, uuid];
    NSLog(@"trainedAddress = %@", trainedAddress);
    NSLog(@"escapedAddress = %@", trainableAddressSpecialEscaped);
    NSString *fullTrainingString = [NSString stringWithFormat:@"%@/train/ks/%@/%@/%@/%@", rootAddress,category,namespace, uuid,  trainableAddressSpecialEscaped];
    
    //set the address
    //    [self qrAddressSelectedFullAddress:trainedAddress];
    
    //node-red sees the "train" and is uses the rest of the parameters to create an entry in the JSON DB (file)
    // returning a new address which is the
    
    //Syntax:
    //  <base>/train/ks/CATEGORY/NAMESPACE/UUID/<escaped URL>
    // call this in...
    // then result ==
    // call web: with the fullTrainingString..
    NSURL *url = [[NSURL alloc]initWithString:fullTrainingString];
    NSLog(@"FullTrainingString = %@", url);
    
    
}

//! THIS IS THE LAST STEP..
//!full address =  https://ROOTURL/red/train/ks/category/namespace/uuid
//! invokes the ROOTURL/red with these parameters
//! @param address the html address to eventually call, this will be escaped inside this method
//! @param category the Genre
//! @param namespace the namespace of the users request
//! @param uuid the users unique id
-(void) createAndRegisterFullTrainedAddress:(NSString*) address category:(NSString*)category namespace:(NSString*)namespace uuid:(NSString*)uuid viewController:(UIViewController*)viewController
{
    //Right now the category isn't used in the mapping (well it could be in the future..)
    //NSString *rootAddress = @"https://ROOTURL/red";
    //! 1.21.23 After EU and soon US Registered Trademarks for SemanticMarker
    //! Change ROOTURL/red -> ROOTURL
    NSString *rootAddress = @"https://ROOTURL";
    
    //! 12.4.24 nice day
    //! strip the spaces again, somehow "instragram " crept in..
    
    // this is passed as URL to the web
    NSString *trainableAddressSpecialEscaped = [self createKSTrainableAddress:address];
    NSString *trainedAddress = [NSString stringWithFormat:@"%@/ks/%@/%@/%@", rootAddress, category, namespace, uuid];
    NSLog(@"trainedAddress = %@", trainedAddress);
    NSLog(@"escapedAddress = %@", trainableAddressSpecialEscaped);
    NSString *fullTrainingString = [NSString stringWithFormat:@"%@/train/ks/%@/%@/%@/%@", rootAddress,category,namespace, uuid,  trainableAddressSpecialEscaped];
    
    //set the address
    //    [self qrAddressSelectedFullAddress:trainedAddress];
    
    //node-red sees the "train" and is uses the rest of the parameters to create an entry in the JSON DB (file)
    // returning a new address which is the
    
    //Syntax:
    //  <base>/train/ks/CATEGORY/NAMESPACE/UUID/<escaped URL>
    // call this in...
    // then result ==
    // call web: with the fullTrainingString..
    NSURL *url = [[NSURL alloc]initWithString:fullTrainingString];
    NSLog(@"FullTrainingString = %@", url);
    
    //now call the web (which is processed by node-red)
    NSURLSessionTask *sessionTask =
    [NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"finished dataTask %@ response = %@, error = %@", uuid, response, error);
        
        //TODO .. set the qraddress..
        NSLog(@"*** TODO set the trainedAddress.. as the QRAvatar address NOT the mapping");
        
        //    [self confirmRegisterStuffAlert:qrAddress category:category.text namespace:namespace.text uuid:uuid.text viewController:viewController];
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self showQRMappingResultsAlert:(NSString*)trainedAddress viewController:(UIViewController*)viewController];
            
        });
        
    }];
    [sessionTask resume];
    
}

//!shows that the process was completed..
-(void) showQRMappingResultsAlert:(NSString*)trainedAddress viewController:(UIViewController*)viewController
{
    //NOTE: the setting of the current address is here .. before the 'ok'
    // since this could let others know it's registered (via the linkFollow command)
    //This will set the current address..
    [self setCurrentQRCodeText:trainedAddress];
    
    // use UIAlertController
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"QRAddress mapping success"
                               message:trainedAddress
                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        
        //!final (a copy so it can be modified)
        NSString *finalSemanticMarkerAddress = trainedAddress;
        
        //! 1.21.23 After EU and soon US Registered Trademarks for SemanticMarker
        //! Change ROOTURL/red -> ROOTURL
        if ([trainedAddress containsString:@"ROOTURL/red"])
        {
            NSLog(@"Replacing with ROOTURL");
            finalSemanticMarkerAddress = [finalSemanticMarkerAddress stringByReplacingOccurrencesOfString:@"ROOTURL/red" withString:@"ROOTURL"];
        }
        else if ([trainedAddress containsString:@"ROOTURL/red"])
        {
            NSLog(@"Replacing with ROOTURL");
            finalSemanticMarkerAddress = [finalSemanticMarkerAddress stringByReplacingOccurrencesOfString:@"ROOTURL/red" withString:@"ROOTURL"];
        }
        //set the trained address and created a QRAvatar with that address, showing to the user
        // assuming the delegate does it that way (which it does)
        //        [self.delegate qrAddressSelected:trainedAddress];
        for (id <KSQRCodeCreationDelegate> codeCreationDelegate in self->_codeCreationDelegates)
        {
            if ([codeCreationDelegate respondsToSelector:@selector(qrAddressSelected:)]) {
                [codeCreationDelegate qrAddressSelected:finalSemanticMarkerAddress];
            }
        }
        
    }];
    //NOTE: if this last "ok" is removed, or has a timeout .. then the above 2 calls must be done somewhere..
    
    [alert addAction:ok];
    
    ///show it.. and get a double confirmation..
    [viewController presentViewController:alert animated:YES completion:^{
        NSLog(@"viewController done..");
    }];
}
@end
