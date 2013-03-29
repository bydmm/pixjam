//
//  VerticallyAlignedLabel.h
//  微问答
//
//  Created by 程南 on 13-1-23.
//  Copyright (c) 2013年 evebit. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum VerticalAlignment {
    VerticalAlignmentTop,
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;
@interface VerticallyAlignedLabel : UILabel
{
@private
    VerticalAlignment verticalAlignment_;
}
@property (nonatomic, assign) VerticalAlignment verticalAlignment;
@end
