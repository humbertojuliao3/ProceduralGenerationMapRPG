//
//  DPad.h
//  GeraçãoProcedimentalMapas
//
//  Created by Humberto  Julião on 10/10/17.
//  Copyright © 2017 Humberto Julião. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface DPad : SKNode

@property (nonatomic, readonly) CGPoint stickPosition;
@property (nonatomic, readonly) CGFloat degrees;
@property (nonatomic, readonly) CGPoint velocity;
@property (nonatomic, assign) BOOL autoCenter;
@property (nonatomic, assign) BOOL isDPad;
@property (nonatomic, assign) BOOL hasDeadzone;
@property (nonatomic, assign) NSUInteger numberOfDirections;

@property (nonatomic, assign) CGFloat joystickRadius;
@property (nonatomic, assign) CGFloat thumbRadius;
@property (nonatomic, assign) CGFloat deadRadius;  

- (instancetype) initWithRect:(CGRect)rect;

@end
