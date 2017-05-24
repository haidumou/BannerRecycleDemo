//
//  HomeBannerViewCell.h
//  Buyer
//
//  Created by bfme on 2017/4/12.
//  Copyright © 2017年 baifumei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BannerCellBlock)(NSInteger index);
@interface HomeBannerViewCell : UICollectionViewCell

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, copy) BannerCellBlock bannerBlock;

@end
