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

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UISnapBehavior *snapBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *foregroundDynamicBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;

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

-(void) viewDidAppear:(BOOL)animated {
    
    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.animator = animator;
    
    UIDynamicItemBehavior *foregroundDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.foregroundView]];
    
    foregroundDynamicBehavior.allowsRotation = NO;
    self.foregroundDynamicBehavior = foregroundDynamicBehavior;
    [animator addBehavior:foregroundDynamicBehavior];
    
    CGPoint fgCenterPoint = CGPointMake(self.foregroundView.center.x, self.foregroundView.center.y);
    UIOffset attachmentPoint = UIOffsetMake(0, 0);
    
    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.foregroundView offsetFromCenter:attachmentPoint attachedToAnchor:fgCenterPoint];
    
    attachmentBehavior.damping = .5;
    attachmentBehavior.frequency = 1;
    attachmentBehavior.length = 2;
    [animator addBehavior:attachmentBehavior];
    
    self.attachmentBehavior = attachmentBehavior;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)foregroundDidPan:(UIPanGestureRecognizer *)sender {
    [self.animator addBehavior:self.attachmentBehavior];
    [self.animator removeBehavior:self.snapBehavior];

    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.initialYposition = self.foregroundView.center.y;
        
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint newCenter = self.foregroundView.center;
        newCenter.x = 160;
        newCenter.y = self.initialYposition + [sender translationInView:self.view].y;
        
        [self.attachmentBehavior setAnchorPoint:newCenter];
        
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Release velocity: %f ", self.releaseVelocity);
        self.releaseVelocity = [sender velocityInView:self.view].y;

        [self snapToBoundaries];
    }


}

- (void) snapToBoundaries {
    
    
    CGPoint newOrigin = CGPointMake(160,284);
    NSLog(@"- -- snap release %f", self.releaseVelocity);
    if (self.releaseVelocity > 0) {
        //dragging UP
        
        newOrigin.y = 808;
        self.isForegroundHidden = YES;
        
    } else {
        self.isForegroundHidden = NO;

    }
    
    
    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:self.foregroundView snapToPoint:newOrigin];
    snapBehavior.damping = .9;
    //    [self.animator addBehavior:self.foregroundDynamicBehavior];

//    [self.animator removeBehavior:self.attachmentBehavior];
    [self.animator addBehavior:snapBehavior];

    
    self.snapBehavior = snapBehavior;
    
    
}
@end
