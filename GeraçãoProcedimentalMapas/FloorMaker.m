//
//  FloorMaker.m
//  GeraçãoProcedimentalMapas
//
//  Created by Humberto  Julião on 10/10/17.
//  Copyright © 2017 Humberto Julião. All rights reserved.
//

#import "FloorMaker.h"

@implementation FloorMaker

- (instancetype) initWithCurrentPosition:(CGPoint)currentPosition andDirection:(NSUInteger)direction
{
  if (( self = [super init] ))
  {
    self.currentPosition = currentPosition;
    self.direction = direction;
  }
  return self;
}

@end
