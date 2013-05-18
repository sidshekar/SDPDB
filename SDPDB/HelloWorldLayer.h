//
//  HelloWorldLayer.h
//  SDPDB
//
//  Created by Siddharth Shekar on 31/01/13.
//  Copyright Siddharth Shekar 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "MyContactListener.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    b2World *_world;
    GLESDebugDraw *_debugDraw;
    
    b2Body *heroBody;
    b2Body *cloudBody;
    b2Body * buildingBody, *finishBody;
    
    b2Fixture *heroFixture;
    b2Fixture *buildingFixture, *finishFixture;
      
    CGSize screenSize;
    CCSprite *_hero,*_cloud,*_finishline ;
    CCSprite* building;
    CCAction *_flyAction;
    
    CCTMXTiledMap* map;
    CCTMXLayer   *_mapBg;
    
    CCParticleSystem *xplodeParticle;
    CGPoint menuPos;
    
    float heroPointsPerSecY,heroPointsPerSecX;    
    float accelX,accelY,accelZ;
    float newX,newY;
    float mapWidth,mapHeight;
    
    // Add inside @interface
    MyContactListener *_contactListener;    
    

}
// Add after the HelloWorld interface
@property (nonatomic, retain) CCSprite *hero;
@property (nonatomic, retain) CCSprite *cloud;
@property (nonatomic, retain) CCSprite *finishline;
@property (nonatomic, retain) CCAction *flyAction;


// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end

