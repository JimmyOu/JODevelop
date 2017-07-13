//
//  UIDevice+Extention.m
//  JODevelop
//
//  Created by JimmyOu on 2017/7/4.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "UIDevice+Extention.h"
#import <AddressBook/AddressBook.h>

@implementation UIDevice (Extention)

- (void)requestAuthorizationAddressBook {
    // 判断是否授权
    ABAuthorizationStatus authorizationStatus = ABAddressBookGetAuthorizationStatus();
    if (authorizationStatus == kABAuthorizationStatusNotDetermined) {
        // 请求授权
        ABAddressBookRef addressBookRef = ABAddressBookCreate();
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) { // 授权成功
                [self getAddressBook];
            } else {  // 授权失败
                NSLog(@"授权失败！");
            }
        });
    } else if (authorizationStatus == kABAuthorizationStatusAuthorized) {
        [self getAddressBook];
    }
}

- (void)getAddressBook {
    // 2. 获取所有联系人
    ABAddressBookRef addressBookRef = ABAddressBookCreate();
    CFArrayRef arrayRef = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    long count = CFArrayGetCount(arrayRef);
    for (int i = 0; i < count; i++) {
        //获取联系人对象的引用
        ABRecordRef people = CFArrayGetValueAtIndex(arrayRef, i);
        
        //获取当前联系人名字
        NSString *firstName=(__bridge NSString *)(ABRecordCopyValue(people, kABPersonFirstNameProperty));
        
        //获取当前联系人姓氏
        NSString *lastName=(__bridge NSString *)(ABRecordCopyValue(people, kABPersonLastNameProperty));
        NSLog(@"--------------------------------------------------");
        NSLog(@"firstName=%@, lastName=%@", firstName, lastName);
        
        //获取当前联系人的电话 数组
        NSMutableArray *phoneArray = [[NSMutableArray alloc]init];
        ABMultiValueRef phones = ABRecordCopyValue(people, kABPersonPhoneProperty);
        for (NSInteger j=0; j<ABMultiValueGetCount(phones); j++) {
            NSString *phone = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phones, j));
            NSLog(@"phone=%@", phone);
            [phoneArray addObject:phone];
        }
        
        //获取当前联系人的邮箱 注意是数组
        NSMutableArray *emailArray = [[NSMutableArray alloc]init];
        ABMultiValueRef emails= ABRecordCopyValue(people, kABPersonEmailProperty);
        for (NSInteger j=0; j<ABMultiValueGetCount(emails); j++) {
            NSString *email = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(emails, j));
            NSLog(@"email=%@", email);
            [emailArray addObject:email];
        }
        //获取当前联系人中间名
        NSString *middleName=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonMiddleNameProperty));
        //获取当前联系人的名字前缀
        NSString *prefix=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonPrefixProperty));
        
        //获取当前联系人的名字后缀
        NSString *suffix=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonSuffixProperty));
        
        //获取当前联系人的昵称
        NSString *nickName=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonNicknameProperty));
        
        //获取当前联系人的名字拼音
        NSString *firstNamePhoneic=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonFirstNamePhoneticProperty));
        
        //获取当前联系人的姓氏拼音
        NSString *lastNamePhoneic=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonLastNamePhoneticProperty));
        
        //获取当前联系人的中间名拼音
        NSString *middleNamePhoneic=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonMiddleNamePhoneticProperty));
        
        //获取当前联系人的公司
        NSString *organization=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonOrganizationProperty));
        
        //获取当前联系人的职位
        NSString *job=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonJobTitleProperty));
        
        //获取当前联系人的部门
        NSString *department=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonDepartmentProperty));
        
        //获取当前联系人的生日
        NSDate *birthday=(__bridge NSDate*)(ABRecordCopyValue(people, kABPersonBirthdayProperty));
        
        //获取当前联系人的备注
        NSString *notes=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonNoteProperty));
        
        //获取创建当前联系人的时间 注意是NSDate
        NSDate *creatTime=(__bridge NSDate*)(ABRecordCopyValue(people, kABPersonCreationDateProperty));
        
        //获取最近修改当前联系人的时间
        NSDate *alterTime=(__bridge NSDate*)(ABRecordCopyValue(people, kABPersonModificationDateProperty));
        
        //获取地址
        ABMultiValueRef address = ABRecordCopyValue(people, kABPersonAddressProperty);
        for (int j=0; j<ABMultiValueGetCount(address); j++) {
            //地址类型
            NSString *type = (__bridge NSString *)(ABMultiValueCopyLabelAtIndex(address, j));
            NSDictionary * tempDic = (__bridge NSDictionary *)(ABMultiValueCopyValueAtIndex(address, j));
            //地址字符串，可以按需求格式化
            NSString *adress = [NSString stringWithFormat:@"国家:%@\n省:%@\n市:%@\n街道:%@\n邮编:%@",[tempDic valueForKey:(NSString*)kABPersonAddressCountryKey],[tempDic valueForKey:(NSString*)kABPersonAddressStateKey],[tempDic valueForKey:(NSString*)kABPersonAddressCityKey],[tempDic valueForKey:(NSString*)kABPersonAddressStreetKey],[tempDic valueForKey:(NSString*)kABPersonAddressZIPKey]];
        }
        
        //获取当前联系人头像图片
        NSData *userImage=(__bridge NSData*)(ABPersonCopyImageData(people));
        
        //获取当前联系人纪念日
        NSMutableArray *dateArr = [[NSMutableArray alloc]init];
        ABMultiValueRef dates= ABRecordCopyValue(people, kABPersonDateProperty);
        for (NSInteger j=0; j<ABMultiValueGetCount(dates); j++) {
            //获取纪念日日期
            NSDate *data =(__bridge NSDate*)(ABMultiValueCopyValueAtIndex(dates, j));
            //获取纪念日名称
            NSString *str =(__bridge NSString*)(ABMultiValueCopyLabelAtIndex(dates, j));
            NSDictionary *tempDic = [NSDictionary dictionaryWithObject:data forKey:str];
            [dateArr addObject:tempDic];
        }
    }
}


@end
