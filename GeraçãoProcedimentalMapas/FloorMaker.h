//
//  FloorMaker.h
//  GeraçãoProcedimentalMapas
//
//  Created by Humberto  Julião on 10/10/17.
//  Copyright © 2017 Humberto Julião. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface FloorMaker : NSObject

@property (nonatomic) CGPoint currentPosition;
@property (nonatomic) NSUInteger direction;

- (instancetype) initWithCurrentPosition:(CGPoint)currentPosition andDirection:(NSUInteger)direction;

@end
