//
//  RTViewController.m
//  RTFacebookAlbumDemo
//
//  Created by Rishabh Tayal on 4/16/14.
//  Copyright (c) 2014 Rishabh Tayal. All rights reserved.
//

#import "RTViewController.h"
#import "RTFacebookAlbumViewController.h"

@interface RTViewController ()

@property (strong) IBOutlet UIImageView* selectedImage;

@end

@implementation RTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)showFacebookAlbums:(id)sender
{
    [RTFacebookAlbumViewController showWithDelegate:self];
}

-(void)faceBookViewController:(id)controller didSelectPhoto:(UIImage *)image
{
    _selectedImage.image = image;
}

@end
