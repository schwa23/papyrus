

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
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIScrollView *cardScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *cardView;



@property (nonatomic) CGFloat initialYposition;
@property (nonatomic) CGFloat releaseVelocity;
@property (nonatomic) BOOL isForegroundHidden;

- (IBAction)foregroundDidPan:(UIPanGestureRecognizer *)sender;

- (IBAction)handleForegroundTap:(UITapGestureRecognizer *)sender;


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
    
    self.cardScrollView.contentInset = UIEdgeInsetsMake(0, -8, 0, -4);
//    self.cardScrollView.contentSize = self.cardView.frame.size;
    self.cardScrollView.contentSize = CGSizeMake(1605, 262);
    
    
    NSLog(@"Content size: %@", NSStringFromCGSize(self.cardScrollView.contentSize) );
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)foregroundDidPan:(UIPanGestureRecognizer *)sender {
    
    NSLog(@"Foreground did pan");
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.initialYposition = self.mainView.frame.origin.y;
        
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGRect newFrame = self.mainView.frame;
//        NSLog(@"translation in view: %f", [sender translationInView:self.view].y);
        
        newFrame.origin.y = self.initialYposition + [sender translationInView:self.view].y;
        NSLog(@"NEW Y position in view: %f",  newFrame.origin.y);
        
        self.releaseVelocity = [sender velocityInView:self.view].y;

        if(newFrame.origin.y < 0) {
            newFrame.origin.y = newFrame.origin.y / 4;
            self.releaseVelocity = self.releaseVelocity / 4;
        }
        
        self.mainView.frame=newFrame;
        
    } else if (sender.state == UIGestureRecognizerStateEnded) {

        [self snapToBoundaries];
    }

}

- (IBAction)handleForegroundTap:(UITapGestureRecognizer *)sender {
    
    if (self.isForegroundHidden ){
        
        //pretend like I just quickly swiped up:
        self.releaseVelocity = -2000;
        [self snapToBoundaries];
    }
}

- (void) snapToBoundaries {
    CGRect currentFrame = self.mainView.frame;
    CGRect newFrame =currentFrame;
    CGFloat distanceRemaining;
    if (self.releaseVelocity > 0) {
        NSLog(@"Release Velocity > 0");
        
        newFrame.origin.y = 528;
        distanceRemaining =  528 - currentFrame.origin.y;
        self.isForegroundHidden = YES;
        
    } else {

        newFrame.origin.y = 0;

        distanceRemaining =  currentFrame.origin.y;
        self.isForegroundHidden = NO;

    }
    

    CGFloat springVelocity = abs(self.releaseVelocity) / 500;
    CGFloat duration = MAX(abs(distanceRemaining) * (1.2/528), .35);
//    CGFloat duration = .35;


    
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:springVelocity options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.mainView.frame = newFrame;
    } completion:nil];
    
    
}
@end
