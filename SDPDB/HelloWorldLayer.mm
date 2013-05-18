//
//  HelloWorldLayer.mm
//  SDPDB
//
//  Created by Siddharth Shekar on 31/01/13.
//  Copyright Siddharth Shekar 2013. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"



#pragma mark - HelloWorldLayer


@implementation HelloWorldLayer

@synthesize hero = _hero;
@synthesize cloud = _cloud;
@synthesize flyAction = _flyAction;
@synthesize finishline = _finishline;

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
		
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
		// enable events
        self.touchEnabled = YES;
		self.accelerometerEnabled = YES;
        screenSize = [CCDirector sharedDirector].winSize;      
        
        map = [[CCTMXTiledMap alloc] initWithTMXFile:@"level1.tmx"];       
        mapWidth = map.mapSize.width * map.tileSize.width;
        mapHeight = map.mapSize.height * map.tileSize.height;
        [self addChild:map z:1];
        map.scale= 2.0;
        
        CCLayerColor *blueSky=[[CCLayerColor alloc]initWithColor:ccc4(100, 100, 250, 255) width:mapWidth height:mapHeight];
        [self addChild:blueSky z:0];
        
        
        b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
        _world = new b2World(gravity);
        // Enable debug draw
        _debugDraw = new GLESDebugDraw( PTM_RATIO );
        _world->SetDebugDraw(_debugDraw);
        
        uint32 flags = 0;
        flags += b2Draw::e_shapeBit;
        flags += b2Draw::e_jointBit;
        flags += b2Draw::e_centerOfMassBit;
        flags += b2Draw::e_aabbBit;
        flags += b2Draw::e_pairBit;
        _debugDraw->SetFlags(flags);
        
        // Create contact listener
        _contactListener = new MyContactListener();
        _world->SetContactListener(_contactListener);
        
        
        //CCSprite* bg = [CCSprite spriteWithFile:@"bg_960x640_2.jpg"];
        //bg.position =ccp(screenSize.width/2,screenSize.height/2);
        //[self addChild:bg];
        
        float tempWidth = mapWidth/10;
        
        [self CreateBoundary];
        [self InitHero];
        [self CreateFinish];
        [self InitClouds:ccp(tempWidth*2, mapHeight*3/4)];
        [self InitClouds:ccp(tempWidth*4, mapHeight/2)];
        [self InitClouds:ccp(tempWidth*5, mapHeight*3/4)];
        
        [self InitClouds:ccp(tempWidth*7, mapHeight/2)];
        [self InitClouds:ccp(tempWidth*8, mapHeight/2)];
        [self InitClouds:ccp(tempWidth*9, mapHeight*3/4)];
        
       
        //[self CreateBuilding:ccp(mapWidth/4,0) :1];
        [self CreateBuilding:ccp(mapWidth/2,0) :2];
        //[self CreateBuilding:ccp(mapWidth*3/4,0) :1];
        
		[self scheduleUpdate];
	}
	return self;
}

-(void)InitHero
{
    //1.cache the plist
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"hero_fly.plist"];
    
    //2.load the sprite sheet
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode  batchNodeWithFile:@"hero_fly.png"];
    [self addChild:spriteSheet z:2];
    
    //3.store frames in array
    NSMutableArray *walkAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 20; ++i)
    {
        if(i<=9)
        {
        [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"fly_000%d.png", i]]];
        }
        else
        {
            [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                       [NSString stringWithFormat:@"fly_00%d.png", i]]];
        }
    }
    
    //4.create anim action    
    CCAnimation *flyAnim = [CCAnimation animationWithSpriteFrames:walkAnimFrames delay:0.1f];
    
    self.hero = [CCSprite spriteWithSpriteFrameName:@"fly_0001.png"];
    _hero.position = ccp(_hero.contentSize.width*2, screenSize.height/2);
    
    self.flyAction = [CCRepeatForever actionWithAction:
                       [CCAnimate actionWithAnimation:flyAnim]];
    
    [_hero runAction:_flyAction];
    
    //box2d defnition
    b2BodyDef heroBodydef;
    
    heroBodydef.type = b2_dynamicBody;
    heroBodydef.position.Set(_hero.position.x/PTM_RATIO,_hero.position.y/PTM_RATIO);
    heroBodydef.userData = _hero;
    heroBody = _world->CreateBody(&heroBodydef);
    
    b2PolygonShape heroShape;
    
    //row 1, col 1
    int num = 5;
    b2Vec2 verts[] = {
        b2Vec2(4.7f / PTM_RATIO*0.5, -37.0f / PTM_RATIO*0.5),
        b2Vec2(74.1f / PTM_RATIO*0.5, -16.5f / PTM_RATIO*0.5),
        b2Vec2(49.6f / PTM_RATIO*0.5, 21.9f / PTM_RATIO*0.5),
        b2Vec2(-50.8f / PTM_RATIO*0.5, 16.9f / PTM_RATIO*0.5),
        b2Vec2(-72.1f / PTM_RATIO*0.5, -17.8f / PTM_RATIO*0.5)
    };
    
    heroShape.Set(verts, num);
    
    b2FixtureDef heroShapeDef;
    heroShapeDef.shape = &heroShape;
    heroShapeDef.density = 0.0;
    //heroShapeDef.isSensor = true;
    heroFixture=heroBody->CreateFixture(&heroShapeDef);
    
    
    [self addChild:_hero z:2];
    _hero.tag =1;
    _hero.scale = 1.0;
    
    
    //_hero = [CCSprite spriteWithFile:@"fly_0001.png" ];
    //_hero.position = ccp(_hero.contentSize.width,screenSize.height/2);
    //[self addChild:_hero];
    
}

-(void)InitClouds:(CGPoint) position
{
    _cloud = [CCSprite spriteWithFile:@"clouds1.png"];
    _cloud.position= ccp(position.x,position.y);
    [self addChild:_cloud z:3];
    _cloud.scale = 1.0;
    
}

-(void)CreateFinish
{
    _finishline = [CCSprite spriteWithFile:@"NoFinishLine2.jpg"];
    _finishline.position=ccp(mapWidth-_finishline.contentSize.width,mapHeight/2);
    _finishline.scale=0.5;
    [self addChild:_finishline];
    
    b2BodyDef finishBodydef;
    
    finishBodydef.type = b2_staticBody;
    finishBodydef.position.Set((mapWidth-_finishline.contentSize.width)/PTM_RATIO,(mapHeight/2)/PTM_RATIO);
    finishBodydef.userData = _finishline;
    finishBody = _world->CreateBody(&finishBodydef);
    
    b2CircleShape finishShape;
    finishShape.m_radius = 40.0/PTM_RATIO;
    
    b2FixtureDef finShapeDef;
    finShapeDef.shape = &finishShape;
    finShapeDef.density = 0.0;
    //heroShapeDef.isSensor = true;
    finishFixture=finishBody->CreateFixture(&finShapeDef);
    

}



-(void)CreateBuilding:(CGPoint)position :(int)numType
{
   //1: empire
   //2: Twin
   //3: burj
   //4: bank
    
    
    if(numType==1)
    building = [CCSprite spriteWithFile:@"empire.png"];
    else if(numType==2)
    building = [CCSprite spriteWithFile:@"twin.png"];
    else if(numType==3)
    building = [CCSprite spriteWithFile:@"burj.png"];
    else if(numType==4)
    building = [CCSprite spriteWithFile:@"bank.png"];
    
    
    building.position= ccp(position.x,building.contentSize.height);
    building.tag =2;
    [self addChild:building z:1];
    building.scale = 2.0;
    
     b2BodyDef buildingBodydef;
     buildingBodydef.type = b2_staticBody;
     buildingBodydef.position.Set(position.x/PTM_RATIO,(building.contentSize.height)/PTM_RATIO);
     //NSLog(@"cloudx %f",_cloud.position.x);
     buildingBodydef.userData = _cloud;
     buildingBody = _world->CreateBody(&buildingBodydef);
     
     b2PolygonShape buildingShape;
     
   if(numType==1)
   {
       //row 1, col 1
       int num = 6;
       b2Vec2 verts[] = {
           b2Vec2(35.4f / PTM_RATIO, -206.0f / PTM_RATIO),//1
           b2Vec2(24.8f / PTM_RATIO, -77.9f / PTM_RATIO),//3
           b2Vec2(9.9f / PTM_RATIO, 10.3f / PTM_RATIO),//4
           b2Vec2(0.1f / PTM_RATIO, 10.3f / PTM_RATIO),//5
           b2Vec2(-18.0f / PTM_RATIO, -74.3f / PTM_RATIO),//6
           b2Vec2(-25.7f / PTM_RATIO, -206.0f / PTM_RATIO)//7
       };
       
       buildingShape.Set(verts, num);
   }
    
    if(numType==2)
    {
        //row 1, col 1
        int num = 6;
        b2Vec2 verts[] = {
            b2Vec2(44.3f / PTM_RATIO, -208.7f / PTM_RATIO),
            b2Vec2(43.2f / PTM_RATIO, -63.9f / PTM_RATIO),
            b2Vec2(30.7f / PTM_RATIO, 16.9f / PTM_RATIO),
            b2Vec2(-28.5f / PTM_RATIO, 16.3f / PTM_RATIO),
            b2Vec2(-43.3f / PTM_RATIO, -89.3f / PTM_RATIO),
            b2Vec2(-43.8f / PTM_RATIO, -209.5f / PTM_RATIO)
        };    

        
        buildingShape.Set(verts, num);
    }
     
     
     
     b2FixtureDef buildingShapeDef;
     buildingShapeDef.shape = &buildingShape;
     buildingShapeDef.density = 0.0;
     //heroShapeDef.isSensor = true;
     buildingFixture=buildingBody->CreateFixture(&buildingShapeDef);
}

            

-(void) update: (ccTime) dt
{
    
    _world->Step(dt, 10, 10);
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext())
    {
        if (b->GetUserData() != NULL)
        {
            CCSprite *ballData = (CCSprite *)b->GetUserData();
            ballData.position = ccp(b->GetPosition().x * PTM_RATIO,
                                    b->GetPosition().y * PTM_RATIO);
            ballData.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }
    }
    
    float maxY = mapHeight- _hero.contentSize.height/2;
    float minY = _hero.contentSize.height/2;
    
    float maxX = mapWidth- _hero.contentSize.width/2;
    float minX = _hero.contentSize.width/2;
    
    newY = _hero.position.y + (heroPointsPerSecY * dt);
    newY = MIN(MAX(newY, minY), maxY);
    
    newX = _hero.position.x + (heroPointsPerSecX * dt);
    newX = MIN(MAX(newX, minX), maxX);
    
    //_hero.position = ccp(newX,newY);
    
    [self setViewpointCenter:_hero.position];
    
       
    if (accelY>0)
    {
        _hero.flipX = YES;
    } else
    {
        _hero.flipX = NO;
    }
    
    //check contacts
    std::vector<b2Body *>toDestroy;
    std::vector<MyContact>::iterator pos;
    for (pos=_contactListener->_contacts.begin();pos != _contactListener->_contacts.end(); ++pos)
    {
        MyContact contact = *pos;
        
        if ((contact.fixtureA == heroFixture && contact.fixtureB == buildingFixture) ||
            (contact.fixtureA == buildingFixture && contact.fixtureB == heroFixture))
        {
            //NSLog(@"Ball hit bottom!");
            NSLog(@"contact");
            
             menuPos = ccp(_hero.position.x-screenSize.width/2,_hero.position.y-screenSize.height/2);        
            
            [self Xplosion:_hero.position];
            [self ResetMenu:menuPos :1];
            
            toDestroy.push_back(contact.fixtureA->GetBody());
            
            
        }
        
        else if ((contact.fixtureA == heroFixture && contact.fixtureB == finishFixture) ||
            (contact.fixtureA == finishFixture && contact.fixtureB == heroFixture))
        {
            //NSLog(@"Ball hit bottom!");
            NSLog(@"end");
            
            menuPos = ccp(_hero.position.x-screenSize.width/2,_hero.position.y-screenSize.height/2);            
            
            //[self Xplosion:_hero.position];
            [self ResetMenu:menuPos:2];
            
            toDestroy.push_back(contact.fixtureA->GetBody());
            
        }
        
    }
    
    std::vector<b2Body *>::iterator pos2;
    for (pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2)
    {
        b2Body *body = *pos2;
        if (body->GetUserData() != NULL)
        {
            CCSprite *sprite = (CCSprite *) body->GetUserData();
            //sprite.visible = false;
            [self removeChild:sprite cleanup:YES];
        }
        _world->DestroyBody(body);
    }
}
-(void)Xplosion:(CGPoint)position
{
    xplodeParticle = [CCParticleSystemQuad particleWithFile:@"explosion.plist"];
    xplodeParticle.position=position;
    [self addChild:xplodeParticle z:4];
    
}

-(void)ResetMenu:(CGPoint)position :(int)num
{
    CCLabelBMFont  *congradsLabel;
    if(num==2)
    congradsLabel = [CCLabelBMFont labelWithString:@"Very Good"fntFile:@"FruitFont.fnt"];
    if(num==1)
    congradsLabel = [CCLabelBMFont labelWithString:@"Try Again"fntFile:@"FruitFont.fnt"];
    
    congradsLabel.position = ccp(_hero.position.x,_hero.position.y+50);
    [self addChild:congradsLabel z:5];
    
    CCMenuItemImage *resetButton = [CCMenuItemImage itemWithNormalImage:@"reset_Button.png" selectedImage:@"reset_Button.png" target:self selector:@selector(StartReset:)];
    resetButton.position = ccp(position.x,position.y);
    
    CCMenu *menu = [CCMenu menuWithItems: resetButton, nil];
    [self addChild: menu z:5];


}

- (void) StartReset: (id) sender
{
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}



//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-(void)setViewpointCenter:(CGPoint) position
{  
    int x = MAX(position.x, screenSize.width / 2);
    int y = MAX(position.y, screenSize.height / 2);
    x = MIN(x, (mapWidth)- screenSize.width / 2);
    y = MIN(y, (mapHeight)- screenSize.height/2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(screenSize.width/2, screenSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    self.position = viewPoint;    
}



-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    
#define kFilteringFactor 0.1//how much it is tilted

#define kRestAccelX -0.6 //is considered baseline along x-axis
#define kShipMaxPointsPerSecX (screenSize.height*0.5)
#define kMaxDiffX 0.15  //the closer it comes to this the ship moves faster
    
#define kRestAccelY 0.0 //is considered baseline along x-axis
#define kShipMaxPointsPerSecY (screenSize.height*0.5)
#define kMaxDiffY 0.15  //the closer it comes to this the ship moves faster
    
    UIAccelerationValue rollingX=0, rollingY=0, rollingZ=0;
    
    rollingX = (acceleration.x * kFilteringFactor) + (rollingX * (1.0 - kFilteringFactor));
    rollingY = (acceleration.y * kFilteringFactor) + (rollingY * (1.0 - kFilteringFactor));
    rollingZ = (acceleration.z * kFilteringFactor) + (rollingZ * (1.0 - kFilteringFactor));
    
    accelX = acceleration.x - rollingX;//@ -0.2 obj is at top and @-0.8 is at bottom
    accelY = acceleration.y - rollingY;
    accelZ = acceleration.z - rollingZ;
    
    //NSLog(@"accelx %f",accelX);
    //NSLog(@"accely %f",accelY);
    
    
    float accelDiffX = accelX - kRestAccelX;
    float accelFractionX= accelDiffX / kMaxDiffX;
    float pointsPerSecX = kShipMaxPointsPerSecX * accelFractionX;
    
    //heroPointsPerSecY = pointsPerSecX;
    
    float accelDiffY = accelY - kRestAccelY;
    float accelFractionY = accelDiffY / kMaxDiffY;
    float pointsPerSecY = kShipMaxPointsPerSecY * accelFractionY;
    
   //heroPointsPerSecX = -pointsPerSecY ;
    
    float sensitivityX= 15;
    float sensitivityY= 10;
    
    float velocityX = sensitivityX * (powf((-fabsf(acceleration.x) + 0.5), 2.0) - 1.25) * acceleration.y;
    float velocityY = sensitivityY * (powf((-fabsf(acceleration.y) + 0.5), 2.0) - 1.25) * -acceleration.x;
    
    //float velocityX = sensitivity * acceleration.y;
    //float velocityY = -sensitivity * acceleration.x;
    
   // NSLog(@"velx %f",velocityX );
   // NSLog(@"vely %f",velocityY );
    
    
    b2Vec2 playerVelocity;
    playerVelocity.x = velocityX;
    playerVelocity.y=velocityY; // The 1 is the speed the the player moves at full velocity
    
    //if (playerVelocity.x != 0 && playerVelocity.y != 0)
    {
        
        //b2Vec2 pos = heroBody->GetWorldCenter();
        //b2Vec2 force = b2Vec2(playerVelocity.x, playerVelocity.y);
        //b2Vec2 point = heroBody->GetWorldCenter();
        //heroBody->ApplyLinearImpulse(force, point);        
        //b2Vec2 velocity = heroBody->GetLinearVelocity();
        
        heroBody->SetLinearVelocity(playerVelocity);
    }
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
	}
}


-(void) dealloc
{
    //delete _contactListener;

	[super dealloc];
}


-(void) draw
{
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color );
	//glDisable(GL_TEXTURE_2D);
	//glDisableClientState(GL_COLOR_ARRAY);
	//glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    //kmGLPushMatrix();
	_world->DrawDebugData();
    //kmGLPopMatrix();
    
	//glEnable(GL_TEXTURE_2D);
	//glEnableClientState(GL_COLOR_ARRAY);
	//glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

-(void)CreateBoundary
{
    b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0,0);
    
	b2Body *groundBody = _world->CreateBody(&groundBodyDef);
	b2EdgeShape groundEdge;
	b2FixtureDef boxShapeDef;
	boxShapeDef.shape = &groundEdge;
    
	//wall definitions
	groundEdge.Set(b2Vec2(0,50/PTM_RATIO), b2Vec2(mapWidth/PTM_RATIO,50/PTM_RATIO));
	groundBody->CreateFixture(&boxShapeDef);
    
    groundEdge.Set(b2Vec2(0,0), b2Vec2(0,screenSize.height/PTM_RATIO));
    groundBody->CreateFixture(&boxShapeDef);
    
    groundEdge.Set(b2Vec2(0, mapHeight/PTM_RATIO),b2Vec2(mapWidth/PTM_RATIO, mapHeight/PTM_RATIO));
    groundBody->CreateFixture(&boxShapeDef);
    
    groundEdge.Set(b2Vec2(mapWidth/PTM_RATIO, mapHeight/PTM_RATIO), b2Vec2(mapWidth/PTM_RATIO, 0));
    groundBody->CreateFixture(&boxShapeDef);
}


@end
