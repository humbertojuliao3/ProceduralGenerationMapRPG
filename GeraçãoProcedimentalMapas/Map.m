//
//  Map.m
//  GeraçãoProcedimentalMapas
//
//  Created by Humberto  Julião on 10/10/17.
//  Copyright © 2017 Humberto Julião. All rights reserved.
//

#import "Map.h"
#import "MapTiles.h"
#import "MyScene.h"
#import "FloorMaker.h"

@interface Map ()
@property (nonatomic) MapTiles *tiles;
@property (nonatomic) SKTextureAtlas *tileAtlas;
@property (nonatomic) CGFloat tileSize;
@property (nonatomic) NSMutableArray *floorMakers;

@end

@implementation Map

+ (instancetype) mapWithGridSize:(CGSize)gridSize
{
    return [[self alloc] initWithGridSize:gridSize];
}

- (instancetype) initWithGridSize:(CGSize)gridSize
{
    if (( self = [super init] ))
    {
        // Parametros default
        self.gridSize = gridSize;
        self.maxFloorCount = 150;
        self.turnResistance = 10;
        self.floorMakerSpawnProbability = 25;
        self.maxFloorMakerCount = 5;
        self.roomProbability = 20;
        self.roomMinSize = CGSizeMake(2, 2);
        self.roomMaxSize = CGSizeMake(6, 6);
        
        _spawnPoint = CGPointZero;
        self.tileAtlas = [SKTextureAtlas atlasNamed:@"tilesAsset"];
        
        NSArray *textureNames = [self.tileAtlas textureNames];
        SKTexture *tileTexture = [self.tileAtlas textureNamed:(NSString *)[textureNames firstObject]];
        self.tileSize = tileTexture.size.width;
    }
    return self;
}

- (void) generateTileGrid
{
    // Ponto inicial do algoritmo. Por defaut, utiliza-se o meio do grid
    CGPoint startPoint = CGPointMake(self.tiles.gridSize.width/2 , self.tiles.gridSize.height/2 );
    _spawnPoint = [self convertMapCoordinateToWorldCoordinate:startPoint];
    
    [self.tiles setTileType:MapTileTypeFloor at:startPoint];
    
    // Contador de tiles já criados
    __block NSUInteger currentFloorCount = 1;
    
    // cria o array a ser utilizado pelo floormaker inicial
    self.floorMakers = [NSMutableArray array];
    [self.floorMakers addObject:[[FloorMaker alloc] initWithCurrentPosition:startPoint andDirection:0]];
    
    // Variáveis de validação
    __block NSInteger validator = 1;
    int counterValid = 0;
    
    while ( currentFloorCount < self.maxFloorCount )
    {
        
        // Esses dois if`s a frente são uma medida de segurança para impedir possiveis situações de loop.
        // Validator recebe o último valor de currentFloorCount, e caso ele se repita por mais de dez vezes,
        // ele quebra o loop e continua do jeito que o mapa estiver.
        if(currentFloorCount == validator){
            counterValid++;
        }else{
            counterValid = 0;
        }
        if (counterValid>100) {
            counterValid = 0;
            break;
        }
        validator = currentFloorCount;
        
        // Log que mostra qual a atual situação da geração
        NSLog(@"%d > %d", currentFloorCount , self.maxFloorCount );
        
        [self.floorMakers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            FloorMaker *floorMaker = (FloorMaker *)obj;
            NSInteger direction = [self randomNumberBetweenMin:1 andMax:4];
            
            if ( floorMaker.direction == 0 ||
                [self randomNumberBetweenMin:0 andMax:100] <= self.turnResistance ){
                if(floorMaker.direction == 0){
                    NSInteger newDirection;
                    switch (direction) {
                        case 1:
                            newDirection = 2;
                            break;
                        case 2:
                            newDirection = 1;
                            break;
                        case 3:
                            newDirection = 4;
                            break;
                        case 4:
                            newDirection = 3;
                            break;
                    }
                    FloorMaker *newFloorMaker = [[FloorMaker alloc] initWithCurrentPosition:floorMaker.currentPosition andDirection: newDirection];
                    
                    [self.floorMakers addObject:newFloorMaker];
                }
                floorMaker.direction = direction;
            }
            CGPoint newPosition;
            // Log que mostra a direção que será testada
            NSLog(@"%d", floorMaker.direction);
            
            switch ( floorMaker.direction )
            {
                case 1: // Cima
                    newPosition = CGPointMake(floorMaker.currentPosition.x, floorMaker.currentPosition.y - 1);
                    break;
                case 2: // Baixo
                    newPosition = CGPointMake(floorMaker.currentPosition.x, floorMaker.currentPosition.y + 1);
                    break;
                case 3: // Esquerda
                    newPosition = CGPointMake(floorMaker.currentPosition.x - 1, floorMaker.currentPosition.y);
                    break;
                case 4: // Direita
                    newPosition = CGPointMake(floorMaker.currentPosition.x + 1, floorMaker.currentPosition.y);
                    break;
                    
            }
            // Log que mostra se uma direção é válida (0 == false, 1 == true)
//            NSLog(@"valid? %d",([self.tiles isValidTileCoordinateAt:newPosition] &&
//                  ![self.tiles isEdgeTileAt:newPosition] &&
//                  [self.tiles tileTypeAt:newPosition] == MapTileTypeNone &&
//                         currentFloorCount < self.maxFloorCount));
            
            // Valida a direção escolida
            if([self.tiles isValidTileCoordinateAt:newPosition] &&
               ![self.tiles isEdgeTileAt:newPosition] &&
               [self.tiles tileTypeAt:newPosition] == MapTileTypeNone &&
               currentFloorCount < self.maxFloorCount)
            {
                //define a nova posição como a atual
                floorMaker.currentPosition = newPosition;
                [self.tiles setTileType:MapTileTypeFloor at:floorMaker.currentPosition];
                currentFloorCount++;
                
                // Decide se uma sala será criada
                if ( [self randomNumberBetweenMin:0 andMax:100] <= self.roomProbability )
                {
                    //gera as dimenções da sala
                    NSUInteger roomSizeX = [self randomNumberBetweenMin:self.roomMinSize.width
                                                                 andMax:self.roomMaxSize.width];
                    NSUInteger roomSizeY = [self randomNumberBetweenMin:self.roomMinSize.height
                                                                 andMax:self.roomMaxSize.height];
                    
                    //e adiciona a mesma no grid
                    currentFloorCount += [self generateRoomAt:floorMaker.currentPosition
                                                     withSize:CGSizeMake(roomSizeX, roomSizeY)];
                }
            }
            
            // Decide se um novo maker de geração deve iniciar no ponto
            if ( [self randomNumberBetweenMin:0 andMax:100] <= self.floorMakerSpawnProbability &&
                self.floorMakers.count < self.maxFloorMakerCount )
            {
                // Gera o novo maker
                FloorMaker *newFloorMaker = [[FloorMaker alloc] initWithCurrentPosition:floorMaker.currentPosition andDirection:[self randomNumberBetweenMin:1 andMax:4]];
                
                [self.floorMakers addObject:newFloorMaker];
            }
        }];
    }
    
    // Log do mapa final
    NSLog(@"%@", [self.tiles description]);
}

- (void) generate
{
    // Inicia os tiles
    self.tiles = [[MapTiles alloc] initWithGridSize:self.gridSize];
    // Gera o grid
    [self generateTileGrid];
    // Gera as paredes
    [self generateWalls];
    // Aloca sprites para os devidos tiles
    [self generateTiles];
}

// Gerador de número aleatório que retorna um número entre um mínimo (incluso) e um máximo (não incluso)
- (NSInteger) randomNumberBetweenMin:(NSInteger)min andMax:(NSInteger)max
{
    return min + arc4random_uniform((uint32_t) (max - min + 1));
}

- (void) generateTiles
{
    // Duplo for para passar por toda a matriz
    for ( NSInteger y = 0; y < self.tiles.gridSize.height; y++ )
    {
        for ( NSInteger x = 0; x < self.tiles.gridSize.width; x++ )
        {
            // gera a cordenada do ponto onde será gerado um tile
            CGPoint tileCoordinate = CGPointMake(x, y);
            // determina o tipo de tile naquele quadrado
            MapTileType tileType = [self.tiles tileTypeAt:tileCoordinate];
            // Log do tile a ser preenchido
            //NSLog(@"%i", tileType);
            
            // If para decidir que tipo de sprite por no dado nó
            // Utilizando o mesmo número que se encontra na matriz, é decidido qual tipo de sprite utilizar
            if ( tileType != MapTileTypeNone )
            {
                // Caso não seja nulo, será inserido um sprite de chão no exato tile analizado
                SKTexture *tileTexture = [self.tileAtlas textureNamed:[NSString stringWithFormat:@"%i", tileType]];
                SKSpriteNode *tile = [SKSpriteNode spriteNodeWithTexture:tileTexture];
                tile.position = [self convertMapCoordinateToWorldCoordinate:CGPointMake(tileCoordinate.x, tileCoordinate.y)];
                [self addChild:tile];
            }else{
                // Caso seja nulo, seu valor será igual a zero, e o sprite para este tipo será alocado
                SKTexture *tileTexture = [self.tileAtlas textureNamed:[NSString stringWithFormat:@"%i", tileType]];
                SKSpriteNode *tile = [SKSpriteNode spriteNodeWithTexture:tileTexture];
                tile.position = [self convertMapCoordinateToWorldCoordinate:CGPointMake(tileCoordinate.x, tileCoordinate.y)];
                [self addChild:tile];
            }
        }
    }
}

// Conversor de posição Virtual para Real
- (CGPoint) convertMapCoordinateToWorldCoordinate:(CGPoint)mapCoordinate
{
    return CGPointMake(mapCoordinate.x * self.tileSize,  (self.tiles.gridSize.height - mapCoordinate.y) * self.tileSize);
}

// Gera as paredes externas ao caminho gerado
- (void) generateWalls
{
    // Começa com um duplo loop para varrer todo o grid
    for ( NSInteger y = 0; y < self.tiles.gridSize.height; y++ )
    {
        for ( NSInteger x = 0; x < self.tiles.gridSize.width; x++ )
        {
            CGPoint coordenadaTile = CGPointMake(x, y);
            
            // verifica se o tipo de tile é Floor
            if ( [self.tiles tileTypeAt:coordenadaTile] == MapTileTypeFloor )
            {
                // Verifica as regiões vizinhas
                for ( NSInteger vizinhoY = -1; vizinhoY < 2; vizinhoY++ )
                {
                    for ( NSInteger vizinhoX = -1; vizinhoX < 2; vizinhoX++ )
                    {
                        // Verifica se os valores dos vizinhos náo apontam para o próprio elemento
                        if ( !(vizinhoX == 0 && vizinhoY == 0) )
                        {
                            CGPoint coordinate = CGPointMake(x + vizinhoX, y + vizinhoY);
                            
                            // Verifica se o ponto na coordenada é um tile de tipo None
                            if ( [self.tiles tileTypeAt:coordinate] == MapTileTypeNone )
                            {
                                // Cria um tile do tipo Wall naquela posição
                                [self.tiles setTileType:MapTileTypeWall at:coordinate];
                            }
                        }
                    }
                }
            }
        }
    }
}

// Gerador de sala
- (NSUInteger) generateRoomAt:(CGPoint)position withSize:(CGSize)size
{
    NSUInteger numberOfFloorsGenerated = 0;
    // A partir do Size recebido, ele ativa um loop para os valores de altura e largura
    for ( NSUInteger y = 0; y < size.height; y++)
    {
        for ( NSUInteger x = 0; x < size.width; x++ )
        {
            // e a partir desses pontos, verifica se é uma área válida
            CGPoint tilePosition = CGPointMake(position.x + x, position.y + y);
            
            if ( [self.tiles tileTypeAt:tilePosition] == MapTileTypeInvalid )
            {
                continue;
            }
            
            if ( ![self.tiles isEdgeTileAt:tilePosition] )
            {
                if ( [self.tiles tileTypeAt:tilePosition] == MapTileTypeNone )
                {
                    // e caso seja, ele gera o tile na possição, e incrementa o contador de novos tiles
                    [self.tiles setTileType:MapTileTypeFloor at:tilePosition];
                    
                    numberOfFloorsGenerated++;
                }
            }
        }
    }
    return numberOfFloorsGenerated;
}

@end
