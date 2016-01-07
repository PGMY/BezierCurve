//
//  ViewController.m
//  BezierCurve
//
//  Created by Mika Yamamoto on 2015/02/19.
//  Copyright (c) 2015年 PGMY. All rights reserved.
//

#import "ViewController.h"
#import "BezierCurveView.h"

@interface ViewController () {
    BezierCurveView *bcView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    bcView = [[BezierCurveView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:bcView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [bcView startAnimation];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
