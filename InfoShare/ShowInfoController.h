//
//  ShowInfoController.h
//  InfoShare
//
//  Created by xjw03 on 15/8/7.
//  Copyright (c) 2015年 xjw03. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTAssetsPickerController/CTAssetsPickerController.h"

@interface ShowInfoController : UITableViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate,
UIActionSheetDelegate ,CTAssetsPickerControllerDelegate>
{   //下拉菜单
    UIActionSheet *myActionSheet;
}

-(void)reloadTableViewDataSrc:(BOOL) bforword;
//-(void)doneLoadingTableViewData;
@end
