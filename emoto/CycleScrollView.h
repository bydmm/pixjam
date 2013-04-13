#import <UIKit/UIKit.h>

@protocol CycleScrollViewDelegate

-(void)pageViewClicked:(NSInteger)pageIndex;

@end

@interface CycleScrollView : UIView <UIScrollViewDelegate>{
    
    UIScrollView *photosScrollView;
    
    NSArray *imagesArray;   // 存放所有需要滚动的图片
    
    int curPageIndex;//当前图片的索引
    
    CGRect scrollFrame;
    
    id <CycleScrollViewDelegate> __unsafe_unretained delegate;
    
}

@property (nonatomic,assign)id <CycleScrollViewDelegate> delegate;

-(UIScrollView *)getScrollView;

-(void)setCurPageIndex:(int)index;

-(int)getCurPageIndex;

- (id)initWithFrame:(CGRect)frame pictures:(NSArray*)pictureArray;


@end