//
//  HomeBannerViewCell.m
//  Buyer
//
//  Created by bfme on 2017/4/12.
//  Copyright © 2017年 baifumei. All rights reserved.
//

#import "HomeBannerViewCell.h"
#import "UIImageView+WebCache.h"

#define  kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define CH_CYCLEINDEX_CALCULATE(x, y) (x+y)%y  //计算循环索引
#define CH_DEFAULT_DURATION_TIME 3.0f         //默认持续时间

@interface HomeBannerViewCell () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftWidth;
@property (weak, nonatomic) IBOutlet UIImageView *midImageVIew;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backViewWidth;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (nonatomic, assign) NSInteger curIndex;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation HomeBannerViewCell

- (void)setDataArray:(NSArray *)dataArray
{
    _dataArray = dataArray;
    if ([dataArray count] == 0) {
        NSLog(@"cycleImageViewConfig:images is empty!");
        return;
    }
    if (dataArray.count == 1) {
        self.scrollView.scrollEnabled = NO;
    }
    
    [self changeImageViewWithIndex:self.curIndex];
    
    self.pageControl.numberOfPages = dataArray.count;
    
    [self timeSetter];
}

- (void)click
{
    NSLog(@"点我干啥 %lu", self.curIndex);
    if (self.bannerBlock) {
        self.bannerBlock(self.curIndex);
    }
}

//这个方法会在子视图添加到父视图或者离开父视图时调用
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    //解决当父View释放时，当前视图因为被Timer强引用而不能释放的问题
    if (!newSuperview) {
        [self.timer invalidate];
        self.timer = nil;
    } else {
        [self timeSetter];
    }
}

#pragma mark - timer configure
//设置定时器
- (void)timeSetter
{
    //将定时器放入主进程的RunLoop中
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:CH_DEFAULT_DURATION_TIME target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)timerAction{
    if (self.dataArray.count <= 1) {
        return ;
    }
    [self.scrollView setContentOffset:CGPointMake(kScreenWidth*2, 0) animated:YES];
    [self performSelector:@selector(reloadImage) withObject:nil afterDelay:.35];
}

- (void)reloadImage
{
    if (self.dataArray.count == 0) {
        return;
    }
    CGPoint offset = [_scrollView contentOffset];
    
    if (offset.x > kScreenWidth) { //  向右滑动
        self.curIndex = CH_CYCLEINDEX_CALCULATE(self.curIndex+1, self.dataArray.count);
    } else if(offset.x < self.frame.size.width) {
        //  向左滑动
        self.curIndex = CH_CYCLEINDEX_CALCULATE(self.curIndex-1, self.dataArray.count);
    }
    
    [self changeImageViewWithIndex:self.curIndex];
    
    [self.scrollView setContentOffset:CGPointMake(kScreenWidth, 0) animated:NO];
    self.pageControl.currentPage = self.curIndex;
}


#pragma mark - ScrollView  Delegate
//当用户手动个轮播时 关闭定时器
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.timer invalidate];
    self.timer = nil;
}

//当用户手指停止滑动图片时 启动定时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self timeSetter];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self reloadImage];
}

#pragma mark - iamgeView cycle changed
/**
 *  改变轮播的图片
 *
 *  @param index 设置当前，前，后的图片
 */
- (void)changeImageViewWithIndex:(NSInteger)index
{
    NSString *midString = self.dataArray[CH_CYCLEINDEX_CALCULATE(index, self.dataArray.count)];
    NSString *leftString = self.dataArray[CH_CYCLEINDEX_CALCULATE(index-1, self.dataArray.count)];
    NSString *rightString = self.dataArray[CH_CYCLEINDEX_CALCULATE(index+1, self.dataArray.count)];
    
    [self.leftImageView sd_setImageWithURL:[NSURL URLWithString:leftString] placeholderImage:[UIImage imageNamed:@"place_2"]];
    [self.midImageVIew sd_setImageWithURL:[NSURL URLWithString:midString] placeholderImage:[UIImage imageNamed:@"place_2"]];
    [self.rightImageView sd_setImageWithURL:[NSURL URLWithString:rightString] placeholderImage:[UIImage imageNamed:@"place_2"]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.scrollView.delegate = self;
    self.backViewWidth.constant = kScreenWidth *3;
    self.leftWidth.constant = kScreenWidth;
    self.scrollView.contentSize = CGSizeMake(kScreenWidth*3, 145);
    [self.scrollView setContentOffset:CGPointMake(kScreenWidth, 0) animated:NO];
    self.curIndex = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
    [self.midImageVIew addGestureRecognizer:tap];
}

- (void)dealloc
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
