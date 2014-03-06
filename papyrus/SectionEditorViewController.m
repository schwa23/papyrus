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


@end

@implementation SectionEditorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
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
    
    
    [UIView animateWithDuration:.3 animations:^{
        self.snapshot.frame = snapShotFrame;
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
