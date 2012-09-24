/*
 * Copyright 2012 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "FBNativeDialogs.h"
#import "FBSession.h"
#import "Social/Social.h"

@implementation FBNativeDialogs

+ (BOOL)presentShareDialogModallyFrom:(UIViewController*)viewController
                          initialText:(NSString*)initialText
                                image:(UIImage*)image
                                  url:(NSURL*)url
                              handler:(FBShareDialogHandler)handler {
    NSArray *images = image ? [NSArray arrayWithObject:image] : nil;
    NSArray *urls = url ? [NSArray arrayWithObject:url] : nil;
    
    return [self presentShareDialogModallyFrom:viewController
                                       session:nil
                                   initialText:initialText
                                        images:images
                                          urls:urls
                                       handler:handler];
}

+ (BOOL)presentShareDialogModallyFrom:(UIViewController*)viewController
                          initialText:(NSString*)initialText
                               images:(NSArray*)images
                                 urls:(NSArray*)urls
                              handler:(FBShareDialogHandler)handler {
    
    return [self presentShareDialogModallyFrom:viewController
                                       session:nil
                                   initialText:initialText
                                        images:images
                                          urls:urls
                                       handler:handler];
}

+ (BOOL)presentShareDialogModallyFrom:(UIViewController*)viewController
                              session:(FBSession*)session
                          initialText:(NSString*)initialText
                               images:(NSArray*)images
                                 urls:(NSArray*)urls
                              handler:(FBShareDialogHandler)handler {

    // Can we even call the iOS API?
    Class composeViewControllerClass = NSClassFromString(@"SLComposeViewController");
    if (composeViewControllerClass == nil ||
        [composeViewControllerClass isAvailableForServiceType:SLServiceTypeFacebook] == NO) {
        // TODO call handler with error
        return NO;
    }
    
    if (session != nil) {
        // No session provided -- do we have an activeSession? We must either have a session that
        // was authenticated with native auth, or no session at all (in which case the app is
        // running unTOSed and we will rely on the OS to authenticate/TOS the user).
        session = [FBSession activeSession];
    }
    if (session != nil) {
        // TODO: check that session is integrated auth and open, return NO otherwise
        if (!session.isOpen) {
            // TODO call handler with error
            return NO;
        }
    }
    
    SLComposeViewController *composeViewController = [composeViewControllerClass composeViewControllerForServiceType:SLServiceTypeFacebook];
    if (composeViewController == nil) {
        // TODO call handler with error
        return NO;
    }
    
    if (initialText) {
        [composeViewController setInitialText:initialText];
    }
    if (images && images.count > 0) {
        for (UIImage *image in images) {
            [composeViewController addImage:image];
        }
    }
    if (urls && urls.count > 0) {
        for (NSURL *url in urls) {
            [composeViewController addURL:url];
        }
    }
    
    [composeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
        if (handler) {
            handler((result == SLComposeViewControllerResultDone) ?FBNativeDialogResultSucceeded : FBNativeDialogResultCancelled, nil);
        }
    }];
    
    [viewController presentModalViewController:composeViewController animated:YES];
    return YES;
}

@end
