

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

@property (nonatomic) CGFloat initialCardYposition;
@property (nonatomic) BOOL isCardViewExpanded;
@property (nonatomic) BOOL isDraggingCardView;
@property (nonatomic) CGFloat cardsReleaseVelocity;


- (IBAction)foregroundDidPan:(UIPanGestureRecognizer *)sender;
- (IBAction)handleCardsPanGesture:(UIPanGestureRecognizer *)sender;

- (IBAction)handleForegroundTap:(UITapGestureRecognizer *)sender;


-(void)snapToBoundaries;
-(void)snapCardsToBoundaries;
-(CGFloat) scaleFromYPosition:(CGFloat)yPosition;

- (NSDictionary *) resizedCardViewAndContentViewWithYPosition:(CGFloat)yPosition;


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
    
    self.cardScrollView.contentInset = UIEdgeInsetsMake(0, -6, 0, -4);
    self.cardScrollView.contentSize = self.cardView.frame.size;
    
    
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
        
        newFrame.origin.y = [sender translationInView:self.view].y;
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

- (IBAction)handleCardsPanGesture:(UIPanGestureRecognizer *)sender {
    CGPoint hitPoint = [sender locationInView:self.view];
    
    UIView *targetView = [sender.view hitTest:hitPoint withEvent:nil];
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.isDraggingCardView = ([targetView isEqual:self.cardView]);
        
//        NSLog(@"Card frame original? %@", NSStringFromCGRect(self.cardView.frame));

    }

    if(self.isDraggingCardView) {
        if (sender.state == UIGestureRecognizerStateBegan) {
            self.initialCardYposition = self.cardScrollView.frame.origin.y;
            
            
        } else if (sender.state == UIGestureRecognizerStateChanged) {
           
            NSDictionary *frameData = [self resizedCardViewAndContentViewWithYPosition:[sender translationInView:self.view].y];
//            NSLog(@"OutputY %f", [sender translationInView:self.view].y);
            
                  CGRect sFrame;
            [frameData[@"cardScrollViewFrame"] getValue:&sFrame];
            self.cardScrollView.frame = sFrame;
            
            CGRect cFrame;
            [frameData[@"cardViewFrame"] getValue:&cFrame];
            self.cardView.frame = cFrame;

            
            self.cardsReleaseVelocity = [sender velocityInView:self.view].y;
            
        } else if (sender.state == UIGestureRecognizerStateEnded) {
            
            self.cardScrollView.pagingEnabled = (self.cardScrollView.frame.size.height > 520);
            [self snapCardsToBoundaries];

        }
        
    }
    
    if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        
        self.isDraggingCardView = NO;
    }
    
}

- (NSDictionary *) resizedCardViewAndContentViewWithYPosition:(CGFloat)yPosition {
   
    
    CGRect newFrame = self.cardScrollView.frame;
    
    newFrame.origin.y = self.initialCardYposition + yPosition;
    newFrame.size.height = self.view.frame.size.height - newFrame.origin.y;
    self.cardScrollView.frame = newFrame;
    
    
    CGRect cardFrame = self.cardView.frame;
    CGFloat scale = [self scaleFromYPosition:newFrame.origin.y];
    
    
    self.cardScrollView.backgroundColor = [UIColor colorWithHue:.8 saturation:.8 brightness:.9 alpha:.5];
    
    
//    NSLog(@"Card frame? %@", NSStringFromCGRect(self.cardView.frame));
    
    cardFrame.size.width = 1605*scale;
    cardFrame.size.height = newFrame.size.height;
    

    
    return @{@"cardViewFrame": [NSValue valueWithCGRect:cardFrame], @"cardScrollViewFrame": [NSValue valueWithCGRect:newFrame]};
    
//    self.cardScrollView.contentSize = cardFrame.size;
//    self.cardScrollView.contentInset = UIEdgeInsetsMake(0, -6 * scale, 0, -4 * scale);
    
    
    
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


    
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:springVelocity options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.mainView.frame = newFrame;
    } completion:nil];
    
    
}

- (void) snapCardsToBoundaries {
    CGFloat newY =0;
    NSLog(@"card release velocity: %f", self.cardsReleaseVelocity);


    if (self.cardsReleaseVelocity > 0) {
        newY = 0;
        
//        distanceRemaining =  528 - currentFrame.origin.y;
        
        
        self.isCardViewExpanded = NO;
        
    } else if (self.cardsReleaseVelocity < 0 ){
        
        newY = -310;

        self.isCardViewExpanded = YES;
        
    }
    
    
    
    NSDictionary *frameData = [self resizedCardViewAndContentViewWithYPosition:newY];
    
    CGRect sFrame;
    [frameData[@"cardScrollViewFrame"] getValue:&sFrame];
    
    
    CGRect cFrame;
    [frameData[@"cardViewFrame"] getValue:&cFrame];
    
    
    
    
    [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:.9 initialSpringVelocity:.5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.cardScrollView.frame = sFrame;
        self.cardView.frame = cFrame;
    } completion:^(BOOL finished) {
        self.cardScrollView.contentSize=cFrame.size;
    }
];
   
    
    
}

- (CGFloat) scaleFromYPosition:(CGFloat) yPosition {
    
    CGFloat const inMin = 306;
    CGFloat const inMax = 0;
    CGFloat const outMin = 1.0;
    CGFloat const outMax = 1.8562091503;
    CGFloat in = yPosition;
    CGFloat out = outMin + (outMax - outMin) * (in - inMin) / (inMax - inMin);
    
    return out;
    
}
@end
