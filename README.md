# PlaneTrainPlace
通过FMDB读取数据库文件中火车飞机地点的name和code，选择地点通过Block会调。

/**
飞机票（回调地点和编码）
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
