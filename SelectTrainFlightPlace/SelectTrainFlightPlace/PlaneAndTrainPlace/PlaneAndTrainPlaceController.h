//
//  PlaneAndTrainPlaceController.h
//  New_YYSl
//
//  Created by gaoming on 17/3/27.
//  Copyright © 2017年 Raising. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PlaneBlock)(NSString *name,NSString *code);

typedef void(^TrainBlock)(NSString *name);

@interface PlaneAndTrainPlaceController : UIViewController

@property(nonatomic,copy) PlaneBlock planeBlock;

@property(nonatomic,copy) TrainBlock trainBlock;

/**
 设置飞机票或者火车票

 @param type 0 为飞机票 1为火车票
 */
-(void)setPlaceType:(int)type;

@end
