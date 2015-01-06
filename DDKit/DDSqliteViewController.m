//
//  DDSqliteViewController.m
//  DDKit
//
//  Created by Diaoshu on 14-12-21.
//  Copyright (c) 2014年 Dejohn Dong. All rights reserved.
//

#import "DDSqliteViewController.h"
#import "Post.h"
#import "UISegmentedControl+Flatten.h"
#import "SQLiteInstanceManager.h"
#import <FMDB/FMDB.h>

#import <LocalAuthentication/LocalAuthentication.h>

#define number 10

#define isUseFMDB 0

@interface DDSqliteViewController (){
    NSTimer *timer;
    NSInteger time;
    
    FMDatabase *db;
}

@property (nonatomic, weak) IBOutlet UILabel *lblTimer;
@property (nonatomic, weak) IBOutlet UILabel *lblResult;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation DDSqliteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"SQLiteSave";
    
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //处理UISegmentedControl 在iOS6及以下的扁平化效果
    if (!VERSION_GREATER(6.9)) {
        [self.segmentedControl flattenIniOS6];
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"◁返回" style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清除" style:UIBarButtonItemStyleBordered target:self action:@selector(clearDB)];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [paths objectAtIndex: 0];  // 获取document目录
    
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent: @"tmpKit.sqlite"];
    
    db = [FMDatabase databaseWithPath:dbPath];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self saveDB];
    //iOS 8.0以上 指纹识别代码
    if (VERSION_GREATER(7.9)) {
        LAContext *localLAContext = [[LAContext alloc] init];
        if([localLAContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]){
            [localLAContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                           localizedReason:@"请输入指纹"
                                     reply:^(BOOL success, NSError *error) {
                                         if(success){
                                             NSLog(@"指纹验证成功");
                                         }else{
                                             NSLog(@"指纹验证失败");
                                         }
                                     }];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)segmentControlChanged:(id)sender{
    if(self.segmentedControl.selectedSegmentIndex == 0){
        [self saveDB];
    }else if(self.segmentedControl.selectedSegmentIndex == 3){
        [self queryDB];
    }
}

#pragma mark - Custom Methods

- (void)refreshTimer{
    self.lblTimer.text = [NSString stringWithFormat:@"计时:%.2fs",time/100.0];
    time++;
}

- (void)saveDB{
    [self timerStart];
#if isUseFMDB
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        [FMDatabase isSQLiteThreadSafe];
        if(![db open]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self timerEnd];
            });
            return;
        }
        [db setShouldCacheStatements:YES];
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS Post ([text] TEXT, id INTEGER, pk INTEGER PRIMARY KEY AUTOINCREMENT)"];
        
        [db beginTransaction];
        int i = 0;
        while (i++ < number) {
            [db executeUpdate:@"INSERT INTO Post ([text], id) VALUES (?, ?)" ,
             [NSString stringWithFormat:@"text%d",i],
             @(i)];
        }
        [db commit];
        FMResultSet *rs  = [db executeQuery:@"SELECT * from Post"];
        while ([rs next]) {
            NSLog(@"pk = %d, text = %@ id = %d",[rs intForColumn:@"pk"],[rs objectForColumnName:@"text"],[rs intForColumn:@"id"]);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self timerEnd];
        });
    });
#else
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        for (int i = 0 ; i < number; i++) {
            Post *p = [[Post alloc] init];
            p.id = @(i);
            p.text = [NSString stringWithFormat:@"text%d",i];
            [p save];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self timerEnd];
            self.lblResult.text = [NSString stringWithFormat:@"成功插入了%d条数据",number];
        });
    });
#endif
}

- (void)queryDB{
    [self timerStart];
    NSDictionary *params = @{@"type":@(DBDataTypeFirstItem),@"criteria":[NSString stringWithFormat:@"WHERE pk = %d", rand()%10000]};
//    NSDictionary *params = nil;
    [Post getDataFromDBWithParameters:params success:^(id data) {
        if([data isKindOfClass:[NSArray class]]){
            NSArray *list = data;
            [self timerEnd];
            self.lblResult.text = [NSString stringWithFormat:@"成功查询了%lu条数据",[list count]];
        }else{
            [self timerEnd];
            Post *p = data;
            NSLog(@"post's name = %@ & text = %@ pk＝%d",p.id,p.text,p.pk);
        }
    }];
}

- (void)clearDB{
    [[SQLiteInstanceManager sharedManager] deleteDatabase];
    
    if([db open]){
        [db executeUpdate:@"DELETE FROM Post"];
        [db executeUpdate:@"VACCUM"];
    }
}

- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)timerStart{
    [self timerEnd];
    time = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:1/100.0f target:self selector:@selector(refreshTimer) userInfo:nil repeats:YES];
}

- (void)timerEnd{
    if(timer){
        [timer invalidate];
        timer = nil;
    }
}

@end
