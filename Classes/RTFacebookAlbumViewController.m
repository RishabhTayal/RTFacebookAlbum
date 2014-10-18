//
//  RTFacebookAlbumViewController.m
//  FacebookAlbum
//
//  Created by Rishabh Tayal on 4/10/14.
//
// The MIT License (MIT)
//
// Copyright (c) 2014 Rishabh Tayal
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "RTFacebookAlbumViewController.h"
#import "FacebookPhotoViewController.h"

@interface RTFacebookAlbumViewController ()

@property (strong) NSMutableArray* datasource;
@property (strong) NSMutableArray* albumCoverArray;
@property (weak) id<RTFacebookViewDelegate> delegate;

@end

@implementation RTFacebookAlbumViewController

+(void)showWithDelegate:(id<RTFacebookViewDelegate>)delegate
{
    RTFacebookAlbumViewController* facebook = [[RTFacebookAlbumViewController alloc] initWithStyle:UITableViewStylePlain];
    UIViewController* top = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (top.presentedViewController) {
        top = top.presentedViewController;
    }
    if (delegate) {
        facebook.delegate = delegate;
    }
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:facebook];
    [top presentViewController:navigationController animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSelected:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutFacebook:)];
    
    self.title = @"Albums";
    NSArray* permissions = [NSArray arrayWithObjects:@"user_friends", @"user_photos", nil];
	BOOL hasPermissions = YES;
	for (NSString *permission in permissions) {
		hasPermissions = (hasPermissions && [FBSession.activeSession hasGranted:permission]);
	}
    if (FBSession.activeSession.isOpen && hasPermissions) {
        // login is integrated with the send button -- so if open, we send
        [self sendRequests];
    } else {
        [FBSession openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState status,
                                                          NSError *error) {
                                          // if login fails for any reason, we alert
                                          if (error) {
                                              NSLog(@"%@", error.localizedDescription);
                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not connect to Facebook."
                                                                                              message:@"Please try again."
                                                                                             delegate:self
                                                                                    cancelButtonTitle:@"OK"
                                                                                    otherButtonTitles:nil];
                                              [alert show];
                                              // if otherwise we check to see if the session is open, an alternative to
                                              // to the FB_ISSESSIONOPENWITHSTATE helper-macro would be to check the isOpen
                                              // property of the session object; the macros are useful, however, for more
                                              // detailed state checking for FBSession objects
                                          } else if (FB_ISSESSIONOPENWITHSTATE(status)) {
                                              // send our requests if we successfully logged in
                                              [self sendRequests];
                                          }
                                      }];
    }
    
    
    
    _datasource = [[NSMutableArray alloc] init];
}

- (void)sendRequests {
    // create the connection object
    NSString* graphPath = @"/me/albums";
    [FBRequestConnection startWithGraphPath:graphPath parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSDictionary* resultDict = (NSDictionary*)result;
        _datasource = [NSMutableArray arrayWithArray:[resultDict objectForKey:@"data"]];
        _albumCoverArray = [[NSMutableArray alloc] initWithCapacity:_datasource.count];
        
        __block int count = 0;
        for (int i = 0 ; i < _datasource.count; i++) {
            NSString* graphPath = [NSString stringWithFormat:@"/%@/picture", [[_datasource objectAtIndex:i] objectForKey:@"id"]];
            NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"album", @"type", nil];
            [FBRequestConnection startWithGraphPath:graphPath parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                count++;
                NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:i], @"index" , connection.urlResponse.URL, @"URL", nil];
                [_albumCoverArray addObject:dict];
                if (count ==_datasource.count) {
                    [self.tableView reloadData];
                }
            }];
        }
        
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doneSelected:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)logoutFacebook:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Logout" message:@"Are you sure you want to logout of Facebook and revoke Facebook acces for FilterVilla?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [FBRequestConnection startWithGraphPath:@"/me/permissions" parameters:nil HTTPMethod:@"DELETE" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            NSLog(@"%@", result);
        }];
        [[FBSession activeSession] closeAndClearTokenInformation];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITableView Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datasource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [[_datasource objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    for (NSDictionary* dict in _albumCoverArray) {
        if ([[dict objectForKey:@"index"] intValue] == indexPath.row) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData* imgData = [NSData dataWithContentsOfURL:[dict objectForKey:@"URL"]];
                UIImage* img = [UIImage imageWithData:imgData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell.imageView setImage: img];
                    [cell.imageView setContentMode:UIViewContentModeScaleAspectFill];

                    CGSize itemSize = CGSizeMake(80, 80);
                    UIGraphicsBeginImageContext(itemSize);
                    CGRect imageRect = CGRectMake(0, 0, itemSize.width, itemSize.height);
                    [cell.imageView drawRect:imageRect];
                    [cell.imageView setImage:UIGraphicsGetImageFromCurrentImageContext()];
                    UIGraphicsEndImageContext();
                });
            });
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FacebookPhotoViewController* vc = [[FacebookPhotoViewController alloc] init];
    vc.albumId = [[_datasource objectAtIndex:indexPath.row] objectForKey:@"id"];
    vc.delegate = _delegate;
    vc.title = [[_datasource objectAtIndex:indexPath.row] objectForKey:@"name"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
