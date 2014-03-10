//
//  SectionEditorViewController.m
//  papyrus
//
//  Created by Joshua Dickens on 3/5/14.
//  Copyright (c) 2014 Joshua Dickens. All rights reserved.
//

#import "SectionEditorViewController.h"

@interface SectionEditorViewController ()
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
- (IBAction)handleDoneButton:(id)sender;

@property (nonatomic, strong) UIView *snapshot;
@property (nonatomic,assign)BOOL pauseAnimations;

@property (nonatomic, assign) CGPoint dragCenter;
@property(nonatomic,assign) CGPoint centerViewCenter;
@property(nonatomic, assign) CGPoint bottomViewCenter;

@property (nonatomic, strong) NSMutableArray *viewsOnLeftSideOfUserSection;

-(void) handleCardPan:(UIPanGestureRecognizer *)sender;

-(void) startWiggleAnimationOnView:(UIView *)view;
-(void) stopWiggleAnimationOnView:(UIView *)view;




@end

@implementation SectionEditorViewController

static int kViewIsInBottom = 1;
static int kViewIsInTop = 0;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.viewsOnLeftSideOfUserSection = [[NSMutableArray alloc] init];
        
    }
    return self;
}


- (id) initWithSnapshotView:(UIView *)snapShotView {
    self= [super init];
    if(self) {
        self.snapshot = snapShotView;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.snapshot];
    
    
    
    // Do any additional setup after loading the view from its nib.
}

-(void) viewDidAppear:(BOOL)animated {
    CGRect snapShotFrame = CGRectMake(86, 73, 130, 230);
    UIImageView *cardBG =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overview_card"]];
    
    cardBG.alpha = 0;
    

    
    cardBG.frame = CGRectMake(self.snapshot.frame.origin.x - 33.17, self.snapshot.frame.origin.y-33.17, self.snapshot.frame.size.width + 66.34, self.snapshot.frame.size.height + 66.34);
    
    [self.snapshot insertSubview:cardBG atIndex:0];
    [self.viewsOnLeftSideOfUserSection addObject:self.snapshot];


    [UIView animateWithDuration:.3 delay:0 options:0 animations:^{
        self.snapshot.frame = snapShotFrame;
        cardBG.frame = CGRectMake(-8.5, -8.5, snapShotFrame.size.width + 17, snapShotFrame.size.height +17);
        self.snapshot.transform = CGAffineTransformMakeRotation(-5 * M_1_PI/ 180);
        

    }  completion:^(BOOL finished) {
        //
        self.centerViewCenter = self.snapshot.center;
       cardBG.alpha=1.0;
        [self startWiggleAnimationOnView:self.snapshot];
    }];
    
    
    UIImageView *newCard =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overview_card"]];
    newCard.userInteractionEnabled = YES;
    newCard.frame = CGRectMake(0,0,147,247);
    newCard.center = CGPointMake(160, 555);
    newCard.alpha = 1.0;
    newCard.tag = kViewIsInBottom;
    self.bottomViewCenter = newCard.center;
    [self.view insertSubview:newCard atIndex:1];
    
    UIPanGestureRecognizer *panCardGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
    
    [panCardGestureRecognizer addTarget:self action:@selector(handleCardPan:)];
    [newCard addGestureRecognizer:panCardGestureRecognizer];
    
   
    
}

-(void) handleCardPan:(UIPanGestureRecognizer *)sender {
    UIView *dragView = sender.view;
    CGPoint offset = [sender translationInView:self.view];
    
    
    if(sender.state == UIGestureRecognizerStateBegan) {
        //when we start dragging the view:
        //store the current center, then move the view
        [self stopWiggleAnimationOnView:dragView];

        self.dragCenter = dragView.center;
        dragView.center = CGPointMake(self.dragCenter.x + offset.x, self.dragCenter.y+offset.y);
        [self.view bringSubviewToFront:dragView];
        //scale up the view
        [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:1 options:0 animations:^{
            dragView.transform=CGAffineTransformMakeScale(1.1, 1.1);
        } completion:nil];
        
        if(dragView.tag == kViewIsInBottom){
            //shift the views over to the left to make room
            for (int i = 0; i<self.viewsOnLeftSideOfUserSection.count; i++) {
                UIView *view = self.viewsOnLeftSideOfUserSection[i];
               
                CGRect newFrame = view.frame;
                newFrame.origin.x -= (newFrame.size.width + 10) * (i + 1);
                [UIView animateWithDuration:.2 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:1.0 options:0 animations:^{
                    view.frame = newFrame;
                } completion:^(BOOL finished) {
                    [self startWiggleAnimationOnView:view];

                }];
                
                
            }
        }
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        
        //track the finger
        dragView.center = CGPointMake(self.dragCenter.x + offset.x, self.dragCenter.y+offset.y);
        
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        
        
        dragView.center = CGPointMake(self.dragCenter.x + offset.x, self.dragCenter.y+offset.y);
        
        
        //are we dragging a view from the top downwards,  dragging from the bottom up?
        BOOL shouldMoveToOtherSection = NO;
        
        if(dragView.tag == kViewIsInBottom) {
            //
            shouldMoveToOtherSection = dragView.center.y <= 284;
        } else if(dragView.tag == kViewIsInTop){
            shouldMoveToOtherSection = dragView.center.y > 284;
        }
        
        
        //TODO get velocity to trigger the flip also/
//        NSLog(@"Velocity %d",  abs([sender velocityInView:self.view].y));
        
        
        if(shouldMoveToOtherSection){
            
            NSLog(@"Should move to other section was true!");
            //move it back to it's original spot
            [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:.4 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                dragView.center = dragView.tag == kViewIsInBottom ? self.centerViewCenter :  self.bottomViewCenter;
                dragView.transform = CGAffineTransformMakeScale(1, 1);
                dragView.tag = dragView.tag == kViewIsInBottom? kViewIsInTop: kViewIsInBottom;
            } completion:^(BOOL finished) {
                if(dragView.tag == kViewIsInTop){
                    [self startWiggleAnimationOnView:dragView];
                }
            }];
            

            
        } else {
            [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:.3 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                dragView.center =self.dragCenter;
                dragView.transform = CGAffineTransformIdentity;
                
            } completion:^(BOOL finished) {
            }];
            
            
            

            
        }
        
        //if the dragView was in the bottom, then shift the top view sections back over
        // or if it was in the top and it made it crossed the threshold

        if(dragView.tag == kViewIsInBottom || ( shouldMoveToOtherSection && kViewIsInTop)){
            for (int i = 0; i<self.viewsOnLeftSideOfUserSection.count; i++) {
                UIView *view = self.viewsOnLeftSideOfUserSection[i];
                
                CGRect newFrame = view.frame;
                newFrame.origin.x += (newFrame.size.width + 10) * (i + 1);
                newFrame.size.width = 130;
                [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:.5 options:0 animations:^{
                    view.frame = newFrame;
                } completion:^(BOOL finished){
                    [self startWiggleAnimationOnView:view];
                }];
                
                
            }
        }
    }
    
}

-(void) startWiggleAnimationOnView:(UIView *)view {
    NSLog(@"wiggling commence!");
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionAllowUserInteraction| UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        view.transform = CGAffineTransformMakeRotation(5 * M_1_PI/ 180);
    } completion:^(BOOL finished) {
        //do something
    }];

}

-(void)stopWiggleAnimationOnView:(UIView *)view {
    
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.snapshot.transform = CGAffineTransformMakeRotation(0);
    } completion:^(BOOL finished) {
        //do something
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleDoneButton:(id)sender {
    [UIView animateWithDuration:.3 animations:^{
//        self.doneButton.alpha =0;
        [self.view bringSubviewToFront:self.snapshot];
        self.snapshot.transform = CGAffineTransformIdentity;
        self.snapshot.frame = CGRectMake(0, 0, 320, 568);
    } completion:^(BOOL finished) {
        if(finished){
        [self dismissViewControllerAnimated:NO completion:^{
            //
        }];
           }
         } ];
    
   
}
@end
