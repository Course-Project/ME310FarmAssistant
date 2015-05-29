//
//  FAMenuHeaderViewController.m
//  ME310FarmAssistant
//
//  Created by Nathan on 5/29/15.
//  Copyright (c) 2015 Tom Hu. All rights reserved.
//

#import "FAMenuHeaderViewController.h"
#import "FMMenuTableViewController.h"
#import "MenuHeader.h"

@interface FAMenuHeaderViewController()

@property (nonatomic,strong) MenuHeader *headerView;

@end

@implementation FAMenuHeaderViewController

void *CusomHeaderInsetObserver = &CusomHeaderInsetObserver;

-(instancetype)init
{
    FMMenuTableViewController *tableVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"menuController"];
    
    self = [super initWithControllers:tableVC, nil];
    if (self) {
        // your code
        self.segmentMiniTopInset = 64;
        self.segmentHeight = 0;
        self.freezenHeaderWhenReachMaxHeaderHeight = YES;
    }
    
    return self;
}

#pragma mark - override

-(UIView<ARSegmentPageControllerHeaderProtocol> *)customHeaderView
{
    self.headerView = [[[NSBundle mainBundle] loadNibNamed:@"MenuHeader" owner:nil options:nil] lastObject];
    return self.headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self addObserver:self forKeyPath:@"segmentToInset" options:NSKeyValueObservingOptionNew context:CusomHeaderInsetObserver];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    if (context == CusomHeaderInsetObserver) {
        CGFloat inset = [change[NSKeyValueChangeNewKey] floatValue];
        NSLog(@"inset is %f",inset);
        if (inset < 120) {
            if (!self.headerView.contentView.hidden) {
                self.headerView.contentView.hidden = YES;
//                self.headerView.settingLabel.hidden = NO;
            }
        }
        else{
            if (self.headerView.contentView.hidden) {
                self.headerView.contentView.hidden = NO;
//                self.headerView.settingLabel.hidden = YES;
            }
        }
    }
}


@end
