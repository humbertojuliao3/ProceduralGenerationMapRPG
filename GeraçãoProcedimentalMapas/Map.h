//
//  Map.h
//  GeraçãoProcedimentalMapas
//
//  Created by Humberto  Julião on 10/10/17.
//  Copyright © 2017 Humberto Julião. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Map : SKNode

@property (nonatomic) CGSize gridSize;
@property (nonatomic, readonly) CGPoint spawnPoint;
@property (nonatomic) NSUInteger maxFloorCount;

@property (nonatomic) NSUInteger turnResistance;
@property (nonatomic) NSUInteger floorMakerSpawnProbability;
@property (nonatomic) NSUInteger maxFloorMakerCount;

@property (nonatomic) NSUInteger roomProbability;
@property (nonatomic) CGSize roomMinSize;
@property (nonatomic) CGSize roomMaxSize;

+ (instancetype) mapWithGridSize:(CGSize)gridSize;
- (instancetype) initWithGridSize:(CGSize)gridSize;
- (void) generate;

@end
