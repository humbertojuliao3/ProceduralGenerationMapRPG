//
//  MyScene.m
//  GeraçãoProcedimentalMapas
//
//  Created by Humberto  Julião on 10/10/17.
//  Copyright © 2017 Humberto Julião. All rights reserved.
//

#import "MyScene.h"
#import "DPad.h"
#import "Map.h"

static const CGFloat kPlayerMovementSpeed = 100.0f;

@interface MyScene() <SKPhysicsContactDelegate>
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) SKNode *world;
@property (nonatomic) SKNode *hud;
@property (nonatomic) DPad *dPad;
@property (nonatomic) Map *map;
@property (nonatomic) SKTextureAtlas *spriteAtlas;
@property (nonatomic) SKSpriteNode *player;
@end


@implementation MyScene

- (id)initWithSize:(CGSize)size
{
    if (( self = [super initWithSize:size] ))
    {
        self.backgroundColor = [SKColor colorWithRed:175.0f/255.0f green:143.0f/255.0f blue:106.0f/255.0f alpha:1.0f];
        
        // parametros: escala de 1 a 3
        // P.S.: Valores maiores ou menores que isto, podem quebrar a geração
        // P.S.#2: Valor 0 com certeza quebrará a aplicação, já que todos são multiplicadores
        const int sizeMultiplier = 3;
        const int turnMultiplier = 1;
        const int floorCounterMultiplier = 3;
        
        
        // Criando nó do mundo
        self.world = [SKNode node];
        
        // Carregando Sprites
        self.spriteAtlas = [SKTextureAtlas atlasNamed:@"spritesAsset"];
        
        // Criando mapa
        self.map = [[Map alloc] initWithGridSize:CGSizeMake((30 * sizeMultiplier), (30 * sizeMultiplier))];
        self.map.maxFloorCount = 100*floorCounterMultiplier*sizeMultiplier;
        self.map.turnResistance = 10*turnMultiplier;
        self.map.floorMakerSpawnProbability = 30;
        self.map.maxFloorMakerCount = 5;
        self.map.roomProbability = 15;
        self.map.roomMinSize = CGSizeMake(2, 2);
        self.map.roomMaxSize = CGSizeMake(6, 6);
        [self.map generate];
        
        // Criando "Jogador"
        // P.S.: este "Jogador" só existe para permitir a movimentação pelo mapa
        
        self.player = [SKSpriteNode spriteNodeWithTexture:[self.spriteAtlas textureNamed:@"idle_0"]];
        self.player.position = self.map.spawnPoint;
        self.player.physicsBody.allowsRotation = NO;
        self.player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.player.texture.size];
        
        [self.world addChild:self.map];
        [self.world addChild:self.player];
        
        // Criando o Hud para conter o JoyStick
        self.hud = [SKNode node];
        
        // Criando o JoyStick para controlar o "Jogador"
        self.dPad = [[DPad alloc] initWithRect:CGRectMake(0, 0, self.size.height/10, self.size.height/10)];
        self.dPad.position = CGPointMake(self.size.width/9, self.size.height/9);
        self.dPad.numberOfDirections = 24;
        self.dPad.deadRadius = 8.0f;
        
        [self.hud addChild:self.dPad];
        
        // Adicionando ambos mapa e hud na cena
        [self addChild:self.world];
        [self addChild:self.hud];
        
        // inicializando a física na aplicação, para manter tudo no seu devido lugar
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}


- (void) update:(CFTimeInterval)currentTime
{
    // Cálculo de tempo desde o ultimo update
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    
    self.lastUpdateTimeInterval = currentTime;
    
    if ( timeSinceLast > 1 )
    {
        timeSinceLast = 1.0f / 60.0f;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    // Recebe os dados vindos do JoyStick
    CGPoint playerVelocity = self.dPad.velocity;
    
    // Atualiza o jogador segundo os dados do JoyStick
    self.player.position = CGPointMake(self.player.position.x + playerVelocity.x * timeSinceLast * kPlayerMovementSpeed,
                                       self.player.position.y + playerVelocity.y * timeSinceLast * kPlayerMovementSpeed);
    
    if ( playerVelocity.x != 0.0f )
    {
        self.player.xScale = (playerVelocity.x > 0.0f) ? -1.0f : 1.0f;
    }
    
    // Atualiza a câmera para a posição do jogador
    self.world.position = CGPointMake(-self.player.position.x + CGRectGetMidX(self.frame),
                                      -self.player.position.y + CGRectGetMidY(self.frame));
}

@end
