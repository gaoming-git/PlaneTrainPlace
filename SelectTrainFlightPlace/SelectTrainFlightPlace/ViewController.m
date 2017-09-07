//
//  ViewController.m
//  SelectTrainFlightPlace
//
//  Created by gaoming on 2017/9/6.
//  Copyright © 2017年 Raising. All rights reserved.
//

#import "ViewController.h"
#import "PlaneAndTrainPlaceController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *code;

@property (weak, nonatomic) IBOutlet UILabel *trainName;

- (IBAction)selectPlace:(UIButton *)sender;
- (IBAction)selectTrainPlace:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 飞机票（回调地点和编码）

 @param sender <#sender description#>
 */
- (IBAction)selectPlace:(UIButton *)sender {
    PlaneAndTrainPlaceController *vc = [[PlaneAndTrainPlaceController alloc]init];
    [vc setPlaceType:0];
    __weak typeof(self) weakSelf = self;
    vc.planeBlock = ^(NSString *name,NSString *code){
        weakSelf.name.text = [NSString stringWithFormat:@"飞机票地点：%@",name];
        weakSelf.code.text = [NSString stringWithFormat:@"地点编码：%@",code];
    };
    [self presentViewController:vc animated:YES completion:nil];
}

/**
 火车票（只回调地点）

 @param sender <#sender description#>
 */
- (IBAction)selectTrainPlace:(UIButton *)sender {
    PlaneAndTrainPlaceController *vc = [[PlaneAndTrainPlaceController alloc]init];
    [vc setPlaceType:1];
    __weak typeof(self) weakSelf = self;
    vc.trainBlock = ^(NSString *name){
        weakSelf.trainName.text = [NSString stringWithFormat:@"火车票地点：%@",name];
    };
    [self presentViewController:vc animated:YES completion:nil];
}
@end
