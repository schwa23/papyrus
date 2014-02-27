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
@property (nonatomic) CGFloat distanceTraveled;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UISnapBehavior *snapBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *foregroundDynamicBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;

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
    self.distanceTraveled = 0;

    // Do any additional setup after loading the view from its nib.
}

-(void) viewDidAppear:(BOOL)animated {
    
    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.animator = animator;
    
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[self.foregroundView]];
    [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, 0, -522, 0)];
    [self.animator addBehavior:collisionBehaviour];
    
    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.foregroundView]];
    self.gravityBehavior.gravityDirection = CGVectorMake(0.0f, -1.0f);
    self.gravityBehavior.magnitude = .1f;
    
    [self.animator addBehavior:self.gravityBehavior];
    
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.foregroundView] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.magnitude = 0.0f;
    self.pushBehavior.angle = 0.0f;
    [self.animator addBehavior:self.pushBehavior];
    
    self.foregroundDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.foregroundView]];
    self.foregroundDynamicBehavior.elasticity = .01f;
    self.foregroundDynamicBehavior.resistance = 2.0f;
//    self.foregroundDynamicBehavior.density = 1.0f;
    [self.animator addBehavior:self.foregroundDynamicBehavior];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)foregroundDidPan:(UIPanGestureRecognizer *)sender {
        CGPoint location = [sender locationInView:self.view];
        location.x = self.foregroundView.center.x;

    
    if (sender.state == UIGestureRecognizerStateBegan) {
        //remove the gravity (since our finger is the new force affeting this
        [self.animator removeBehavior:self.gravityBehavior];
        self.initialYposition = location.y;
        
        //anchor to the view's current x center & the fingter's y position
        self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.foregroundView attachedToAnchor:location];
        [self.animator addBehavior:self.attachmentBehavior];
        
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        //and then move it around
        [self.attachmentBehavior setAnchorPoint:location];
        NSLog(@"Location : %f", location.y);
        self.distanceTraveled = location.y - self.initialYposition;
        
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Release velocity: %f ", self.releaseVelocity);
        self.releaseVelocity = [sender velocityInView:self.view].y;

        [self snapToBoundaries];
    }


}

- (IBAction)handleForegroundTap:(UITapGestureRecognizer *)sender {
    if(self.isForegroundHidden){
        self.releaseVelocity = -5200.f;
        self.distanceTraveled = -500.0f;
//        self.pushBehavior.magnitude = 100;
        [self snapToBoundaries];
        [self.animator addBehavior:self.gravityBehavior];
    
    }
}

- (void) snapToBoundaries {
    
    [self.animator removeBehavior:self.attachmentBehavior];
    self.attachmentBehavior = nil;

    NSLog(@"- -- snap release %f", self.releaseVelocity);
    if (self.releaseVelocity > 200 || self.distanceTraveled > 100) {
        //dragging UP
        
        self.gravityBehavior.gravityDirection = CGVectorMake(0.0f, 1.0f);
        self.isForegroundHidden = YES;
        
    } else if (self.releaseVelocity < -200 || self.distanceTraveled < -100 ){
        
        self.gravityBehavior.gravityDirection = CGVectorMake(0.0f, -1.0f);
        self.isForegroundHidden = NO;

    }
    
    
//  add back in the gravity
    [self.animator addBehavior:self.gravityBehavior];
    
    self.pushBehavior.pushDirection =  self.gravityBehavior.gravityDirection;
    self.pushBehavior.magnitude = abs(self.releaseVelocity) / 10.0f;
    self.pushBehavior.active = YES;
}
@end
