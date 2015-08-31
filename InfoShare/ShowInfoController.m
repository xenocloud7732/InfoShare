//
//  ShowInfoController.m
//  InfoShare
//
//  Created by xjw03 on 15/8/7.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import "ShowInfoController.h"
#import "ViewController.h"
#import "UploadManager.h"
#import "UploadInfoController.h"
#import "Tools.h"
#import "Info.h"
#import "SITableViewCell.h"
#import "InfoManager.h"
#import "SDRefresh.h"

const int freshCount = 5;


@interface ShowInfoController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak) SDRefreshHeaderView *refreshHeader;
@property (nonatomic, weak) SDRefreshFooterView *refreshFooter;
@end

@implementation ShowInfoController


- (void)setupHeader
{
    SDRefreshHeaderView *refreshHeader = [SDRefreshHeaderView refreshView];
    [refreshHeader addToScrollView:self.tableView];
    [refreshHeader addTarget:self refreshAction:@selector(headerRefresh)];
    _refreshHeader = refreshHeader;
}

- (void)setupFooter
{
    SDRefreshFooterView *refreshFooter = [SDRefreshFooterView refreshView];
    [refreshFooter addToScrollView:self.tableView];
    [refreshFooter addTarget:self refreshAction:@selector(footerRefresh)];
    _refreshFooter = refreshFooter;
}


-(void)headerRefresh{
    [self reloadTableViewDataHeader];
}
-(void)footerRefresh{
    [self reloadTableViewDataFooter];
}

- (void)viewDidLoad{
    //在子视图中（或者根视图）有一个navigationItem用于访问其导航信息
    self.navigationItem.title=@"浏览列表";//或者直接设置控制器title（例如[self setTitle:@"Friends"]）
    //设置导航栏左侧按钮
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"注销" style:UIBarButtonItemStyleDone target:self action:@selector(GoLogin)];
    //设置导航栏右侧按钮
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"发帖" style:UIBarButtonItemStyleDone target:self action:@selector(GoUpload)];
    
    InfoManager* infoManager = [InfoManager GetInfoManager];
    [infoManager GetInfoByPage:1];
    
    [self setupHeader];
    [self setupFooter];
    //[self.refreshHeader beginRefreshing];
}

- (void)GoLogin{
    [self performSegueWithIdentifier:@"Segue_S2L" sender:self];
}

- (void)GoUpload{
    
    [self openMenu];
}

-(void)openMenu
{
    //在这里呼出下方菜单按钮项
    myActionSheet = [[UIActionSheet alloc]
                     initWithTitle:nil
                     delegate:self
                     cancelButtonTitle:@"取消"
                     destructiveButtonTitle:nil
                     otherButtonTitles: @"打开照相机", @"从手机相册获取",nil];
    
    [myActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    //呼出的菜单按钮点击后的响应
    if (buttonIndex == myActionSheet.cancelButtonIndex)
    {
        NSLog(@"取消");
    }
    
    switch (buttonIndex)
    {
        case 0:  //打开照相机拍照
            [Tools TakePhoto:self];
            break;
            
        case 1:  //打开本地相册
            [Tools LocalPhoto:self andMaxSelect:MaxUploadCount];
            break;
    }
}




- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
}


//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        UploadInfoController* uc = [[UploadInfoController alloc] init];
        [uc.imageArray addObject:image];
        [self.navigationController pushViewController:uc animated:YES];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"您取消了选择图片");
    [picker dismissViewControllerAnimated:YES completion:nil];
  
}


#pragma mark - Assets Picker Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    UploadInfoController* uc = [[UploadInfoController alloc] init];
    [uc.imageArray addObjectsFromArray:assets];
    uc.nav = self.navigationController;
    [self.navigationController pushViewController:uc animated:YES];
}


#pragma mark - Assets Table Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    InfoManager* infoManager = [InfoManager GetInfoManager];
    return infoManager.InfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;{
    
    InfoManager* infoManager = [InfoManager GetInfoManager];
    Info* info = infoManager.InfoArray[indexPath.row];
    NSString *CellIdentifier = [[NSString alloc]initWithFormat:@"SITableViewCell_%d",[info getImgCount]];
    
    SITableViewCell *cell = (SITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setInfo:info];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    InfoManager* infoManager = [InfoManager GetInfoManager];
    Info* info = infoManager.InfoArray[indexPath.row];
    return [SITableViewCell CalCellHeigh:info];
}


-(void)reloadTableViewDataHeader{
    InfoManager* infomanager = [InfoManager GetInfoManager];
    [infomanager AddInfo:YES andCount:freshCount andFinish:^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshHeader endRefreshing];});
    }];
}

-(void)reloadTableViewDataFooter{
    InfoManager* infomanager = [InfoManager GetInfoManager];
    [infomanager AddInfo:NO andCount:freshCount andFinish:^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshFooter endRefreshing];});
    }];
}

/*-(void)doneLoadingTableViewData{
    self.reloading = NO;
    [self.refreshHeadView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    [self.refreshFootView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    [self.tableView reloadData];
}

#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.refreshHeadView egoRefreshScrollViewDidScroll:scrollView];
    [self.refreshFootView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.refreshHeadView egoRefreshScrollViewDidEndDragging:scrollView];
    [self.refreshFootView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark EGORefreshTableHeaderDelegate Methods
-(void)egoRefreshTableDidTriggerRefresh:(EGORefreshTableView *)view triggerTpye:(EGORefreshType)type{
    if(EGORefreshHeader == type){
        [self reloadTableViewDataSrc:YES];
    }
    else
        [self reloadTableViewDataSrc:NO];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1];
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(EGORefreshTableView*)view{
    return self.reloading;
}

-(NSDate *)egoRefreshTableDataSourceLastUpdated:(EGORefreshTableView *)view{
    return [NSDate date];
}*/

@end
