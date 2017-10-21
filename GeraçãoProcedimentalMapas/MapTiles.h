//
//  MapTiles.h
//  GeraçãoProcedimentalMapas
//
//  Created by Humberto  Julião on 10/10/17.
//  Copyright © 2017 Humberto Julião. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSInteger, MapTileType)
{
  MapTileTypeInvalid = -1,
  MapTileTypeNone = 0,
  MapTileTypeFloor = 1,
  MapTileTypeWall = 2,
};

@interface MapTiles : NSObject

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) CGSize gridSize;

- (instancetype) initWithGridSize:(CGSize)size;
- (MapTileType) tileTypeAt:(CGPoint)tileCoordinate;
- (void) setTileType:(MapTileType)type at:(CGPoint)tileCoordinate;
- (BOOL) isEdgeTileAt:(CGPoint)tileCoordinate;
- (BOOL) isValidTileCoordinateAt:(CGPoint)tileCoordinate;

@end
