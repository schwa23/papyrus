//
//  MainViewController.m
//  papyrus
//
//  Created by Joshua Dickens on 2/25/14.
//  Copyright (c) 2014 Joshua Dickens. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *foregroundView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;

@property (nonatomic) CGFloat initialYposition;
@property (nonatomic) CGFloat releaseVelocity;
@property (nonatomic) BOOL isForegroundHidden;

- (IBAction)foregroundDidPan:(UIPanGestureRecognizer *)sender;

-(void)snapToBoundaries;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isForegroundHidden = NO;
    self.initialYposition = 0;
    self.releaseVelocity = 0;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)foregroundDidPan:(UIPanGestureRecognizer *)sender {
    NSLog(@"Foreground did pan");
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.initialYposition = self.foregroundView.frame.origin.y;
        
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGRect newFrame = self.foregroundView.frame;
        NSLog(@"translation in view: %f", [sender translationInView:self.view].y);
        newFrame.origin.y = self.initialYposition + [sender translationInView:self.view].y;
        self.foregroundView.frame=newFrame;
        
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Release velocity: %f ", self.releaseVelocity);

        [self snapToBoundaries];
    }
    self.releaseVelocity = [sender velocityInView:self.view].y;

}

- (void) snapToBoundaries {
    CGRect currentFrame = self.foregroundView.frame;
    CGRect newFrame =currentFrame;
    CGFloat distanceRemaining;
    if (self.releaseVelocity > 0) {
        //dragging UP
        
        newFrame.origin.y = 528;
        distanceRemaining =  528 - currentFrame.origin.y;
        self.isForegroundHidden = YES;
        
    } else {
        
        newFrame.origin.y = 0;
        distanceRemaining =  currentFrame.origin.y;
        self.isForegroundHidden = NO;

    }
    CGFloat duration = distanceRemaining * (1.1/528);
    CGFloat springVelocity = abs(self.releaseVelocity) / 1000;
    
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:1 initialSpringVelocity:springVelocity options:0 animations:^{
        self.foregroundView.frame = newFrame;
    } completion:nil];
    
    
}
@end
