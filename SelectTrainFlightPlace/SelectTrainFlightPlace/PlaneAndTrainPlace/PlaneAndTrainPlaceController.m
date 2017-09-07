//
//  PlaneAndTrainPlaceController.m
//  New_YYSl
//
//  Created by gaoming on 17/3/27.
//  Copyright © 2017年 Raising. All rights reserved.
//

#define IPHONE_W ([UIScreen mainScreen].bounds.size.width)
#define IPHONE_H ([UIScreen mainScreen].bounds.size.height)

#define ThemecColor [UIColor colorWithRed:58/255.0 green:150/255.0 blue:253/255.0 alpha:1.0]
//字体
#define FONT_BIG     [UIFont systemFontOfSize:16]
#define FONT_MID     [UIFont systemFontOfSize:14]
#define FONT_SMA     [UIFont systemFontOfSize:12]

#import "PlaneAndTrainPlaceController.h"
#import <FMDB.h>
#import "PlaneAndTrainModel.h"

#define PlaneSectionArr [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil]
#define TrainSectionArr [NSArray arrayWithObjects:@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z", nil]
#define HotPlaceArr [NSMutableArray arrayWithObjects:@"北京",@"上海虹桥",@"广州",@"深圳",@"成都",@"杭州",@"武汉",@"西安",@"重庆", nil]

///////////////hot place  Btn///////////////////
#define MaxColsPerRow 3 // 一行的最大列数

#define EdgLeftMargin 10

#define EdgTopMargin 10

#define HorMargin 10

#define VerMargin 10

@interface PlaneAndTrainPlaceController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    FMDatabase  *_db;
    int _type;
}
/**飞机 从数据库中查询出所有数据转变为model集合*/
@property(nonatomic,strong) NSMutableArray *planeArr;
/**火车 从数据库中查询出所有数据转变为model集合*/
@property(nonatomic,strong) NSMutableArray *trainArr;
/**飞机的 A，B，C，D......地点集合*/
@property(nonatomic,strong) NSMutableArray *planeSortArr;
/**火车的 A，B，C，D......地点集合*/
@property(nonatomic,strong) NSMutableArray *trainSortArr;
/**tableView 数据源 根据设置type而定*/
@property(nonatomic,strong) NSMutableArray *dataArr;
/**飞机 热门城市数据 火车热门用HotPlaceArr */
@property(nonatomic,strong) NSMutableArray *hotArr;
/**模糊查询的数据 */
@property(nonatomic,strong) NSMutableArray *searchArr;

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UITableView *searchTableView;
@property(nonatomic,weak) UISearchBar *searchbar;

@property (nonatomic, strong) UIView *topView;

@end

@implementation PlaneAndTrainPlaceController

/**
 飞机票数据
 */
- (NSMutableArray *)planeArr{
    if (!_planeArr) {
        _planeArr = [NSMutableArray array];
        NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"cities.db" ofType:nil];
        // 实例化FMDataBase对象
        _db = [FMDatabase databaseWithPath:dbPath];
        [_db open];
        FMResultSet *res = [_db executeQuery:@"SELECT * FROM city"];
        while ([res next]) {
            PlaneAndTrainModel *placeModel = [[PlaneAndTrainModel alloc] init];
            placeModel.ID = [res stringForColumn:@"id"];
            placeModel.name = [res stringForColumn:@"name"];
            placeModel.pinyin = [res stringForColumn:@"pinyin"];
            placeModel.code = [res stringForColumn:@"code"];
            [_planeArr addObject:placeModel];
        }
        [_db close];
    }
    return _planeArr;
}

/**
 火车票票数据
 */
- (NSMutableArray *)trainArr{
    if (!_trainArr) {
        _trainArr = [NSMutableArray array];
        NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"china_cities.db" ofType:nil];
        // 实例化FMDataBase对象
        _db = [FMDatabase databaseWithPath:dbPath];
        [_db open];
        FMResultSet *res = [_db executeQuery:@"SELECT * FROM city"];
        while ([res next]) {
            PlaneAndTrainModel *placeModel = [[PlaneAndTrainModel alloc] init];
            placeModel.ID = [res stringForColumn:@"id"];
            placeModel.name = [res stringForColumn:@"name"];
            placeModel.pinyin = [res stringForColumn:@"pinyin"];
            [_trainArr addObject:placeModel];
        }
        [_db close];
    }
    return _trainArr;
}

-(NSMutableArray *)planeSortArr
{
    if (!_planeSortArr) {
        _planeSortArr = [NSMutableArray array];
        for (int i = 0; i<PlaneSectionArr.count; i++) {
            NSString *temStr = PlaneSectionArr[i];
            NSMutableArray *tempArr = [NSMutableArray array];
            for (PlaneAndTrainModel *placeModel in self.planeArr) {
                if ([[placeModel.pinyin substringToIndex:1] isEqualToString:temStr]) {
                    [tempArr addObject:placeModel];
                }
            }
            if (tempArr.count != 0) {
                [_planeSortArr addObject:tempArr];
            }
        }

    }
    return _planeSortArr;
}

-(NSMutableArray *)trainSortArr
{
    if (!_trainSortArr) {
        _trainSortArr = [NSMutableArray array];
        for (int i = 0; i<TrainSectionArr.count; i++) {
            NSString *temStr = TrainSectionArr[i];
            NSMutableArray *tempArr = [NSMutableArray array];
            for (PlaneAndTrainModel *placeModel in self.trainArr) {
                if ([[placeModel.pinyin substringToIndex:1] isEqualToString:temStr]) {
                    [tempArr addObject:placeModel];
                }
            }
            if (tempArr.count != 0) {
                [_trainSortArr addObject:tempArr];
            }
        }
    }
    return _trainSortArr;
}

/**
 查询热门城市,飞机票热门model ,火车票热门用HotPlaceArr
 */
- (NSMutableArray *)hotArr{
    if (!_hotArr) {
        _hotArr = [NSMutableArray array];
        NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"cities.db" ofType:nil];
        // 实例化FMDataBase对象
        _db = [FMDatabase databaseWithPath:dbPath];
        [_db open];
        for (NSString *hotStr in HotPlaceArr) {
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM city where name = '%@'",hotStr];
            FMResultSet *res = [_db executeQuery:sql];
            while ([res next]) {
                PlaneAndTrainModel *placeModel = [[PlaneAndTrainModel alloc] init];
                placeModel.ID = [res stringForColumn:@"id"];
                placeModel.name = [res stringForColumn:@"name"];
                placeModel.pinyin = [res stringForColumn:@"pinyin"];
                placeModel.code = [res stringForColumn:@"code"];
                [_hotArr addObject:placeModel];
            }
        }
        [_db close];
    }
    return _hotArr;
}

-(NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

-(NSMutableArray *)searchArr
{
    if (!_searchArr) {
        _searchArr = [NSMutableArray array];
    }
    return _searchArr;
}

-(void)setPlaceType:(int)type
{
    _type = type;
    if (type == 0) {  //飞机票
        self.dataArr = [self.planeSortArr mutableCopy];
    }
    if (type == 1) {
        self.dataArr = [self.trainSortArr mutableCopy];
    }
    [self.tableView reloadData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self searchBarUI];
    [self setTableViewUI];
    [self setNavUI];
    
}

-(void)setNavUI
{
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 64)];
    self.topView.backgroundColor = ThemecColor;
    [self.view addSubview:self.topView];
    
    // 自定义导航栏返回按钮
    UIImageView *backBtn = [[UIImageView alloc]init];
    backBtn.frame = CGRectMake(10, 32, 35,20);
    backBtn.image = [UIImage imageNamed:@"cancel"];
    backBtn.contentMode = UIViewContentModeScaleAspectFit;
    backBtn.userInteractionEnabled = YES;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backBtnClick)];
    [backBtn addGestureRecognizer:recognizer];
    [self.topView addSubview:backBtn];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(IPHONE_W/2-50, 27, 100, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"选择地点";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:17];
    [self.topView addSubview:label];
    
}

-(void)backBtnClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)setTableViewUI
{
    
    self.searchTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 104, IPHONE_W, IPHONE_H-104) style:UITableViewStylePlain];
    self.searchTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchTableView.hidden = YES;
    self.searchTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.searchTableView];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 104, IPHONE_W, IPHONE_H-104) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    
    UIView *headerView = [[UIView alloc]init];
    headerView.backgroundColor = [UIColor whiteColor];
    
    //计算高度
    int lastRow = (int)(HotPlaceArr.count-1)/MaxColsPerRow;//最后一行的行号
    // 纵向按钮的个数＊按钮的高度＋上下边距＋按钮之间的间距
    CGFloat height = (lastRow+1)*35+2*EdgTopMargin+lastRow*VerMargin;
    headerView.frame = CGRectMake(0, 0, IPHONE_W, height+40);
    self.tableView.tableHeaderView = headerView;
    
    UIView *labelView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 40)];
    labelView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [headerView addSubview:labelView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, IPHONE_W-20, 40)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"热门城市";
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = FONT_BIG;
    [labelView addSubview:label];
    
    for (int i = 0; i< HotPlaceArr.count; i++) {
        
        // 行号
        int row = i / MaxColsPerRow;
        // 列号
        int col = i % MaxColsPerRow;
        
        CGFloat btnW = (IPHONE_W-EdgLeftMargin*2-HorMargin*(MaxColsPerRow-1))/MaxColsPerRow;
        CGFloat btnH = 35;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor groupTableViewBackgroundColor];
        btn.frame = CGRectMake(col * (btnW + HorMargin) + EdgLeftMargin, row * (btnH + VerMargin)+EdgTopMargin+40, btnW, btnH);
        [btn addTarget:self action:@selector(hotPlaceBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [btn setTitle:HotPlaceArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = FONT_BIG;
        [headerView addSubview:btn];
        
    }
    
}

-(void)hotPlaceBtnClicked:(UIButton *)button
{
    if (_type == 0) {
        PlaneAndTrainModel *model = self.hotArr[button.tag];
        if (self.planeBlock) {
            self.planeBlock(model.name,model.code);
        }
    }else if (_type == 1)
    {
        if (self.trainBlock) {
            self.trainBlock(HotPlaceArr[button.tag]);
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark --- tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return self.dataArr.count;
    }else
    {
        return 1;
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        NSArray *array = self.dataArr[section];
        return array.count;
    }else
    {
        return self.searchArr.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"PlanePlaceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    if (tableView == self.tableView) {
        NSArray *array = self.dataArr[indexPath.section];
        PlaneAndTrainModel *placeModel = array[indexPath.row];
        cell.textLabel.text = placeModel.name;
    }else
    {
        PlaneAndTrainModel *placeModel = self.searchArr[indexPath.row];
        cell.textLabel.text = placeModel.name;
    }
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 40)];
        view.backgroundColor = [UIColor groupTableViewBackgroundColor];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, IPHONE_W-30, 30)];
        label.backgroundColor = [UIColor clearColor];
        NSArray *array = self.dataArr[section];
        PlaneAndTrainModel *placeModel = [array firstObject];
        label.text = [placeModel.pinyin substringToIndex:1];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.font = FONT_BIG;
        [view addSubview:label];
        return view;
    }else
    {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 0.0001)];
        view.backgroundColor = [UIColor whiteColor];
        return view;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return 40;
    }
    return 0.0001;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 0.0001)];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0001;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        NSMutableArray *indexArr = [NSMutableArray array];
        for (NSArray *array in self.dataArr) {
            PlaneAndTrainModel *model = [array firstObject];
            [indexArr addObject:[model.pinyin substringToIndex:1]];
        }
        return indexArr;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaneAndTrainModel *placeModel;
    if (tableView == self.tableView) {
        NSArray *array = self.dataArr[indexPath.section];
        placeModel = array[indexPath.row];
    }else
    {
        placeModel = self.searchArr[indexPath.row];
    }
    
    if (_type == 0) {
        if (self.planeBlock) {
            self.planeBlock(placeModel.name,placeModel.code);
        }
    }
    if (_type == 1) {
        if (self.trainBlock) {
            self.trainBlock(placeModel.name);
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)searchBarUI
{
    UISearchBar *searchbar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 64, IPHONE_W, 40)];
    searchbar.backgroundColor = [UIColor whiteColor];
    searchbar.placeholder = @"请输入城市名和拼音";
    searchbar.delegate = self;
    searchbar.showsScopeBar = YES; // 设置显示范围框
    [self.view addSubview:searchbar];
    self.searchbar = searchbar;
}
#pragma mark  --- UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString *sql = [NSString stringWithFormat:@"select * from city t where t.name like '%%%@%%' or t.pinyin like '%%%@%%'",searchText,searchText];
    
    NSLog(@"%@",sql);
    
    if (_type == 0) {  //模糊查飞机
        if (searchText.length>0) {
            self.searchTableView.hidden = NO;
            self.tableView.hidden = YES;
            [self.searchArr removeAllObjects];
            NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"cities.db" ofType:nil];
            // 实例化FMDataBase对象
            _db = [FMDatabase databaseWithPath:dbPath];
            [_db open];
            FMResultSet *res = [_db executeQuery:sql];
            while ([res next]) {
                PlaneAndTrainModel *placeModel = [[PlaneAndTrainModel alloc] init];
                placeModel.ID = [res stringForColumn:@"id"];
                placeModel.name = [res stringForColumn:@"name"];
                placeModel.pinyin = [res stringForColumn:@"pinyin"];
                placeModel.code = [res stringForColumn:@"code"];
                [self.searchArr addObject:placeModel];
            }
            [_db close];
            [self.searchTableView reloadData];
        }else
        {
            self.searchTableView.hidden = YES;
            self.tableView.hidden = NO;
        }
    }
    
    if (_type == 1) {  ////模糊查火车
        if (searchText.length>0) {
            self.searchTableView.hidden = NO;
            self.tableView.hidden = YES;
            [self.searchArr removeAllObjects];
            NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"china_cities.db" ofType:nil];
            // 实例化FMDataBase对象
            _db = [FMDatabase databaseWithPath:dbPath];
            [_db open];
            FMResultSet *res = [_db executeQuery:sql];
            while ([res next]) {
                PlaneAndTrainModel *placeModel = [[PlaneAndTrainModel alloc] init];
                placeModel.ID = [res stringForColumn:@"id"];
                placeModel.name = [res stringForColumn:@"name"];
                placeModel.pinyin = [res stringForColumn:@"pinyin"];
                [self.searchArr addObject:placeModel];
            }
            [_db close];
            [self.searchTableView reloadData];
        }else
        {
            self.searchTableView.hidden = YES;
            self.tableView.hidden = NO;
        }
    }
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchbar resignFirstResponder];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchbar resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
