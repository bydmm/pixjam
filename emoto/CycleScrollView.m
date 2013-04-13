#import "CycleScrollView.h"


@implementation CycleScrollView

@synthesize delegate;

-(UIScrollView *)getScrollView
{
    return photosScrollView;
}
-(void)setCurPageIndex:(int)index;
{
    curPageIndex=index;
}

-(int)getCurPageIndex
{
    return curPageIndex;
}

- (id)initWithFrame:(CGRect)frame pictures:(NSArray*)pictureArray
{
    self = [super initWithFrame:frame];
    if (self) {
        curPageIndex = 0;
        scrollFrame=frame;
        imagesArray=[[NSArray  alloc]initWithArray:pictureArray];
        photosScrollView=[[UIScrollView alloc] initWithFrame:frame];
        photosScrollView.backgroundColor=[UIColor blackColor];
        photosScrollView.showsVerticalScrollIndicator=NO;
        photosScrollView.showsHorizontalScrollIndicator=NO;
        photosScrollView.pagingEnabled=YES;
        photosScrollView.delegate=self;
        [self  addSubview:photosScrollView];
        [self loadimages];

    }
    return self;
}

-(void)loadimages
{
    CGSize contentSize = scrollFrame.size;
    contentSize.width = contentSize.width * [imagesArray count];
    photosScrollView.contentSize = contentSize;
    for (int i = 0 ; i < [imagesArray count];  i++) {
        UIImageView *image = [[UIImageView alloc] initWithImage:[imagesArray objectAtIndex:i]];
        image.contentMode = UIViewContentModeScaleAspectFit;
        image.backgroundColor = [UIColor blackColor];
        float feedWidth = scrollFrame.size.width;
        float feedHeight = scrollFrame.size.height;
        image.frame=CGRectOffset(CGRectMake(0, 0,feedWidth,feedHeight),(feedWidth+0)*i,0);
        [photosScrollView addSubview:image];
    }
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    curPageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
}



@end