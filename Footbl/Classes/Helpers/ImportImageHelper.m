//
//  ImportImageHelper.m
//  Footbl
//
//  Created by Fernando Saragoça on 5/15/14.
//  Copyright (c) 2014 made@sampa. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <SDWebImage/SDWebImageManager.h>
#import "ImportImageHelper.h"

@interface ImportImageHelper () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (copy, nonatomic) void (^cameraCompletionBlock)(UIImage *image, NSError *error);

- (UIViewController *)rootViewController;

@end

#pragma mark ImportImageHelper

@implementation ImportImageHelper

#pragma mark - Class Methods

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

#pragma mark - Instance Methods

- (UIViewController *)rootViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        rootViewController = [(UINavigationController *)rootViewController viewControllers].lastObject;
    }
    return rootViewController;
}

- (void)importImageFromFacebookWithCompletionBlock:(void (^)(UIImage *image, NSError *error))completionBlock {
    [[FBRequest requestForGraphPath:@"me?fields=picture.type(large)"] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            if (completionBlock) completionBlock(nil, error);
            return;
        }
        
        if ([result[@"picture"][@"data"][@"is_silhouette"] boolValue]) {
            if (completionBlock) completionBlock(nil, nil);
            return;
        }
        
        NSString *picturePath = result[@"picture"][@"data"][@"url"];
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:picturePath] options:SDWebImageCacheMemoryOnly | SDWebImageHighPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (error) {
                if (completionBlock) completionBlock(nil, error);
                return;
            }
            if (completionBlock) completionBlock(image, nil);
        }];
    }];
}

- (void)importFromGalleryWithCompletionBlock:(void (^)(UIImage *image, NSError *error))completionBlock {
    self.cameraCompletionBlock = completionBlock;
    
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.allowsEditing = YES;
    imagePickerController.delegate = self;
    
    
    [self.rootViewController presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)importFromCameraWithCompletionBlock:(void (^)(UIImage *image, NSError *error))completionBlock {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ops", @"") message:NSLocalizedString(@"Camera is not available on your device, sorry!", @"") delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
        [alert show];
        if (completionBlock) completionBlock(nil, nil);
        return;
    }
    
    self.cameraCompletionBlock = completionBlock;
    
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.showsCameraControls = YES;
    imagePickerController.allowsEditing = YES;
    imagePickerController.delegate = self;

    [self.rootViewController presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)importImageFromSources:(NSArray *)sources completionBlock:(void (^)(UIImage *image, NSError *error))completionBlock {
    if (sources.count == 1 || (sources.count == 2 && [sources containsObject:@(ImportImageHelperSourceCamera)] && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])) {
        ImportImageHelperSource source = [sources.firstObject integerValue];
        if (source == ImportImageHelperSourceCamera) {
            source = [sources.lastObject integerValue];
        }
        switch (source) {
            case ImportImageHelperSourceCamera:
                [self importFromCameraWithCompletionBlock:completionBlock];
                return;
            case ImportImageHelperSourceFacebook:
                [self importImageFromFacebookWithCompletionBlock:completionBlock];
                return;
            case ImportImageHelperSourceLibrary:
                [self importFromGalleryWithCompletionBlock:completionBlock];
                return;
        }
    }
    
    self.cameraCompletionBlock = completionBlock;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if ([sources containsObject:@(ImportImageHelperSourceCamera)] && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Take photo", @"")];
    }
    if ([sources containsObject:@(ImportImageHelperSourceLibrary)]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Import from Library", @"")];
    }
    if ([sources containsObject:@(ImportImageHelperSourceFacebook)]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Import from Facebook", @"")];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons - 1];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}

#pragma mark - Delegate

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Take photo", @"")]) {
        [self importFromCameraWithCompletionBlock:self.cameraCompletionBlock];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Import from Library", @"")]) {
        [self importFromGalleryWithCompletionBlock:self.cameraCompletionBlock];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Import from Facebook", @"")]) {
        [self importImageFromFacebookWithCompletionBlock:self.cameraCompletionBlock];
    } else {
        self.cameraCompletionBlock(nil, nil);
    }
}

#pragma mark - UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (self.cameraCompletionBlock) self.cameraCompletionBlock(info[UIImagePickerControllerEditedImage], nil);
    self.cameraCompletionBlock = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (self.cameraCompletionBlock) self.cameraCompletionBlock(nil, nil);
    self.cameraCompletionBlock = nil;
}

@end
