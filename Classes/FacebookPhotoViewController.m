//
//  FacebookPhotoViewController.m
//  FilterVilla
//
//  Created by Rishabh Tayal on 4/10/14.
//  Copyright (c) 2014 Appikon. All rights reserved.
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

#import "FacebookPhotoViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FacebookPhotoViewController ()

@property (strong) NSMutableArray* datasource;

@property (strong) UICollectionView* collectionView;

@end

@implementation FacebookPhotoViewController

-(id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _datasource = [[NSMutableArray alloc] init];
    
    [self sendRequest];
    
    UICollectionViewFlowLayout* flow = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flow];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.collectionView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)sendRequest {
    NSString* graphPath = [NSString stringWithFormat:@"/%@?fields=photos", _albumId];
    
    [FBRequestConnection startWithGraphPath:graphPath parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSDictionary* resultDict = (NSDictionary*)result;
        
        NSDictionary* dict  = [resultDict objectForKey:@"photos"];
        NSArray* array = [dict objectForKey:@"data"];
        for (NSDictionary* innerDict in array) {
            NSString* source = [innerDict objectForKey:@"source"];
            [_datasource addObject:source];
        }
        [self.collectionView reloadData];
    }];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _datasource.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"cell";
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height)];
    imageView.tag = 100;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [cell.contentView addSubview:imageView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData* imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_datasource[indexPath.row]]];
        UIImage* img = [UIImage imageWithData:imgData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [imageView setImage:img];
        });
    });
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate) {
        UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
        UIImageView* imageView = (UIImageView*)[cell viewWithTag:100];
        [_delegate faceBookViewController:self didSelectPhoto:imageView.image];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
