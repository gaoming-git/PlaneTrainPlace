# PlaneTrainPlace
通过FMDB读取数据库文件中火车飞机地点的name和code，选择地点通过Block会调。

/**
飞机票（回调地点和编码）
*/
PlaneAndTrainPlaceController *vc = [[PlaneAndTrainPlaceController alloc]init];

[vc setPlaceType:0];

vc.planeBlock = ^(NSString *name,NSString *code){

};

[self presentViewController:vc animated:YES completion:nil];

/**
火车票（只回调地点）
*/

PlaneAndTrainPlaceController *vc = [[PlaneAndTrainPlaceController alloc]init];

[vc setPlaceType:1];

vc.trainBlock = ^(NSString *name){


};

[self presentViewController:vc animated:YES completion:nil];
