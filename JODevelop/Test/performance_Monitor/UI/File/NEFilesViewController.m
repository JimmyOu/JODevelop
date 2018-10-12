//
//  NEFilesViewController.m
//  JODevelop
//
//  Created by JimmyOu on 2018/8/9.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "NEFilesViewController.h"
#import "NEFilePreviewViewController.h"
#import "NEFileData.h"
#import "NEAppMonitor.h"

@interface NEFilesViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NEFileData *fileData;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation NEFilesViewController

- (instancetype)initWithDir:(NSString *)dir {
    if (self = [super init]) {
        BOOL isDir = NO;
        if (dir.length <= 0) {
            dir = NSHomeDirectory();
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDir] || !isDir) {
                        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _fileData = [[NEFileData alloc] init];
        _fileData.currentDir = dir;
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yy-MM-dd HH:mm:ss";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [_fileData.currentDir lastPathComponent];
    [self setupUI];
}
- (void)setupUI {

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(close)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(back)];
    
    _tableView = [[UITableView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tableView.frame = self.view.bounds;
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [_fileData numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_fileData itemCountAtSecion:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"FileCellId";
    
    NEFileItem *item = [_fileData itemAtIndex:indexPath.row section:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellID];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    }
    cell.textLabel.text = item.name;
    NSString *dateString = [_dateFormatter stringFromDate:item.modifyDate];
    if (item.isDir) {
        cell.detailTextLabel.text = dateString;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor colorWithRed:240/255.0f green:248/255.0f blue:255/255.0f alpha:1.0];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ -- %ld条记录",item.name,item.subPathCount];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  %@", dateString, [self readableSize:item.size]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}
- (NSString *)readableSize:(unsigned long long)size {
    if (size < 1024) {
        return [NSString stringWithFormat:@"%lluB", size];
    } else if (size < 1024 * 1024) {
        return [NSString stringWithFormat:@"%.2fKB", (size / 1024.0)];
    } else {
        return [NSString stringWithFormat:@"%.2fMB", (size / 1024.0 / 1024)];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NEFileItem *item = [_fileData itemAtIndex:indexPath.row section:indexPath.section];
    if (item.isDir) {
        NEFilesViewController *vc = [[NEFilesViewController alloc] initWithDir:item.path];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NEFilePreviewViewController *vc = [[NEFilePreviewViewController alloc] initWithFilePath:item.path];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
         NEFileItem *item = [_fileData itemAtIndex:indexPath.row section:indexPath.section];
        if (item.path) {
            [[NSFileManager defaultManager] removeItemAtPath:item.path error:nil];
            [_fileData reloadData];
            [tableView reloadData];
        }
        
    }
}


@end
