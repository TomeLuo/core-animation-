//
//  ViewController.m
//  core animation动画
//
//  Created by 童川 on 16/1/10.
//  Copyright © 2016年 童川. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic)UIImageView *imageView;
@property (assign,nonatomic)NSInteger currerntIndex;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@end

@implementation ViewController
- (NSArray *)imagesNamesArray
{
    return @[@"pp",@"bg_start"];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
#pragma mark - 贝塞尔曲线作图
- (IBAction)setUpBezierPath:(id)sender {
    
  
}
#pragma mark - 使用shapeLayer 画线
- (IBAction)useShapeLayerAnimation:(id)sender {
    
    //贝塞尔画圆
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(100, 100) radius:100 startAngle:0 endAngle:M_PI clockwise:NO];
    
    //初始化shapeLayer
    CAShapeLayer *myShapeLayer = [CAShapeLayer layer];
    myShapeLayer.frame = CGRectMake(100, 100, 200, 200);
    
    myShapeLayer.strokeColor = [UIColor greenColor].CGColor;//边沿线色
    myShapeLayer.fillColor = [UIColor grayColor].CGColor;//填充色
    
    myShapeLayer.lineJoin = kCALineJoinMiter;//线拐点的类型
    myShapeLayer.lineCap = kCALineCapSquare;//线终点
    
    //从贝塞尔曲线获得形状
    myShapeLayer.path = path.CGPath;
    
    //线条宽度
    myShapeLayer.lineWidth = 10;
    
    //起始和终止
    myShapeLayer.strokeStart = 0.0;
    myShapeLayer.strokeEnd = 1.0;
    
    //将layer添加进图层
    [self.backgroundView.layer addSublayer:myShapeLayer];
    
}
#pragma mark - 关键帧动画
- (IBAction)setupFramAnimation:(id)sender {
    
    //创建一条贝塞尔
    UIBezierPath* path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(0, 100)];
    [path addLineToPoint:CGPointMake(375, 100)];
    [path addLineToPoint:CGPointMake(375, 200)];
    [path addLineToPoint:CGPointMake(0, 200)];
    [path addLineToPoint:CGPointMake(100, 250)];
  
    //几个固定点
    NSValue *orginalValue = [NSValue valueWithCGPoint:self.backgroundView.layer.position];
    NSValue *value_1 = [NSValue valueWithCGPoint:CGPointMake(300, 300)];
    NSValue *value_2 = [NSValue valueWithCGPoint:CGPointMake(400, 300)];
    NSValue *value_3 = [NSValue valueWithCGPoint:CGPointMake(400, 400)];
    
    //变动的属性,keyPath后面跟的属性是CALayer的属性
    CAKeyframeAnimation *keyFA = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    //value数组，放所有位置信息，如果设置path，此项会被忽略
    keyFA.values = @[orginalValue,value_1,value_2,value_3];
    //动画路径
        keyFA.path = path.CGPath;
    //该属性是一个数组，用以指定每个子路径(AB,BC,CD)的时间。如果你没有显式地对keyTimes进行设置，则系统会默认每条子路径的时间为：ti=duration/(帧数)，即每条子路径的duration相等
    keyFA.keyTimes = @[@(0.0),@(0.5),@(0.9),@(2)];
    //动画总时间
    keyFA.duration = 5.0f;
    //重复次数，小于0无限重复
    keyFA.repeatCount = 1;
    
    /*
     这个属性用以指定时间函数，类似于运动的加速度
     kCAMediaTimingFunctionLinear//线性
     kCAMediaTimingFunctionEaseIn//淡入
     kCAMediaTimingFunctionEaseOut//淡出
     kCAMediaTimingFunctionEaseInEaseOut//淡入淡出
     kCAMediaTimingFunctionDefault//默认
     */
    keyFA.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    /*
     fillMode的作用就是决定当前对象过了非active时间段的行为. 比如动画开始之前,动画结束之后。如果是一个动画CAAnimation,则需要将其removedOnCompletion设置为NO,要不然fillMode不起作用.
     
     下面来讲各个fillMode的意义
     kCAFillModeRemoved 这个是默认值,也就是说当动画开始前和动画结束后,动画对layer都没有影响,动画结束后,layer会恢复到之前的状态
     kCAFillModeForwards 当动画结束后,layer会一直保持着动画最后的状态
     kCAFillModeBackwards 这个和kCAFillModeForwards是相对的,就是在动画开始前,你只要将动画加入了一个layer,layer便立即进入动画的初始状态并等待动画开始.你可以这样设定测试代码,将一个动画加入一个layer的时候延迟5秒执行.然后就会发现在动画没有开始的时候,只要动画被加入了layer,layer便处于动画初始状态
     kCAFillModeBoth 理解了上面两个,这个就很好理解了,这个其实就是上面两个的合成.动画加入后开始之前,layer便处于动画初始状态,动画结束后layer保持动画最后的状态.
     //添加动画
     */
    keyFA.fillMode = kCAFillModeForwards;
    
    /*
     在关键帧动画中还有一个非常重要的参数,那便是calculationMode,计算模式.该属性决定了物体在每个子路径下是跳着走还是匀速走，跟timeFunctions属性有点类似
     其主要针对的是每一帧的内容为一个座标点的情况,也就是对anchorPoint 和 position 进行的动画.当在平面座标系中有多个离散的点的时候,可以是离散的,也可以直线相连后进行插值计算,也可以使用圆滑的曲线将他们相连后进行插值计算. calculationMode目前提供如下几种模式
     
     kCAAnimationLinear calculationMode的默认值,表示当关键帧为座标点的时候,关键帧之间直接直线相连进行插值计算;
     kCAAnimationDiscrete 离散的,就是不进行插值计算,所有关键帧直接逐个进行显示;
     kCAAnimationPaced 使得动画均匀进行,而不是按keyTimes设置的或者按关键帧平分时间,此时keyTimes和timingFunctions无效;
     kCAAnimationCubic 对关键帧为座标点的关键帧进行圆滑曲线相连后插值计算,对于曲线的形状还可以通过tensionValues,continuityValues,biasValues来进行调整自定义,这里的数学原理是Kochanek–Bartels spline,这里的主要目的是使得运行的轨迹变得圆滑;
     kCAAnimationCubicPaced 看这个名字就知道和kCAAnimationCubic有一定联系,其实就是在kCAAnimationCubic的基础上使得动画运行变得均匀,就是系统时间内运动的距离相同,此时keyTimes以及timingFunctions也是无效的.
     */
    keyFA.calculationMode = kCAAnimationPaced;
    
    //旋转的模式,auto就是沿着切线方向动，autoReverse就是转180度沿着切线动
    keyFA.rotationMode = kCAAnimationRotateAuto;
    
    //结束后是否移除动画
    keyFA.removedOnCompletion = NO;
    
    //添加动画
    [self.imageView.layer addAnimation:keyFA forKey:@"movingAnimation"];
    
}
- (IBAction)blowUpImage:(id)sender {
    
    self.imageView.center = self.backgroundView.center;
    CGPoint oldCenter = self.imageView.center;
    CGAffineTransform oldtransform = self.imageView.transform;
    CGFloat oldAlpha = self.imageView.alpha;
    
    [UIView animateWithDuration:2.0 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        
        self.imageView.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(M_PI), CGAffineTransformMakeScale(2.0, 2.0));
        self.imageView.alpha = 0.5;
        
    } completion:^(BOOL finished) {
        
        self.imageView.center = oldCenter;
        self.imageView.transform = oldtransform;
        self.imageView.alpha = oldAlpha;
    }];
    
}
- (void)changeToNextImage
{
    self.currerntIndex = (self.currerntIndex +1)%2;
    NSString *imageName = [[self imagesNamesArray] objectAtIndex:self.currerntIndex];
    UIImage *nextImage =[UIImage imageNamed:imageName];
    
    
    
    //    CATransition * transition = [CATransition animation];
    //     transition.type = kCATransitionFade;
    //    transition.duration = 1.0;
    //    [self.imageView.layer addAnimation:transition forKey:@"ToNext"];    self.imageView.image = nextImage;
    
    CATransition * transition = [CATransition animation];
    transition.duration = 1.0;//动画间隔
    transition.type = kCATransitionMoveIn;//主要种类，决定动画效果
    /*
     主要种类有四种
     NSString * const kCATransitionFade; //消退NSString * const kCATransitionMoveIn;//移入NSString * const kCATransitionPush;//pushNSString * const kCATransitionReveal;
     */
    transition.startProgress = 0.0;//开始
    transition.endProgress = 1.0;//结束
    transition.subtype = kCATransitionFromRight;//次要种类，决定动画方向
    /*
     次要种类也有四种
     NSString * const kCATransitionFromRight;NSString * const kCATransitionFromLeft;NSString * const kCATransitionFromTop;NSString * const kCATransitionFromBottom;
     */
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];//时间函数
    [self.imageView.layer addAnimation:transition forKey:@"ToNext"];     self.imageView.image = nextImage;
    
}

- (UIImageView *)imageView{
    
    if (!_imageView) {
        
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        _imageView.image = [UIImage imageNamed:@"pp"];
        [self.backgroundView addSubview:_imageView];
        
        //添加点击手势
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeToNextImage)];
        _imageView.userInteractionEnabled = YES;
        [_imageView addGestureRecognizer:tap];
        self.currerntIndex = 0;
    }
    return _imageView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
