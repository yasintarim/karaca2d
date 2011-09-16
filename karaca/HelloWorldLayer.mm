//
//  Hellom_worldLayer.mm
//  karaca
//
//  Created by yasin on 9/7/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 100.0

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};


// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// enable touches
		self.isTouchEnabled = YES;
		[self setupWorld];
        [self setupDebugDraw];
        [self createGround];
        [self schedule: @selector(tick:)];
	}
	return self;
}

-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	m_world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

}

-(void) tick: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	m_world->Step(dt, velocityIterations, positionIterations);

	
	//Iterate over the bodies in the physics world
	for (b2Body* b = m_world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
}

-(void)createGround
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    b2BodyDef groundBodyDef;
    groundBodyDef.type = b2_staticBody;
    groundBodyDef.position.Set(0, 0);
    b2Body* groundBody = m_world->CreateBody(&groundBodyDef);
    
    float margin = 30.0f;
    float m = margin / PTM_RATIO;
    float w = (winSize.width - margin )/PTM_RATIO;
    float h = (winSize.height - margin )/PTM_RATIO;
    
    b2Vec2 lowerLeft = b2Vec2(m,m);
    b2Vec2 lowerRight = b2Vec2(w, m);
    b2Vec2 upperLeft = b2Vec2(m, h);
    b2Vec2 upperRight = b2Vec2(w, h);
    
    
    b2PolygonShape groundShape;
    
    b2FixtureDef groundFixtureDef;
    groundFixtureDef.shape = &groundShape;
    groundFixtureDef.density = 1;
    
    groundShape.SetAsEdge(lowerLeft, lowerRight);
    groundBody->CreateFixture(&groundFixtureDef);
    
    groundShape.SetAsEdge(upperLeft, upperRight);
    groundBody->CreateFixture(&groundFixtureDef);

    groundShape.SetAsEdge(upperLeft, lowerLeft);
    groundBody->CreateFixture(&groundFixtureDef);
    
    groundShape.SetAsEdge(upperRight, lowerRight);
    groundBody->CreateFixture(&groundFixtureDef);


}

-(void)createBoxAtLocation:(CGPoint)location withSize:(CGSize)size
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(location.x / PTM_RATIO, location.y / PTM_RATIO);
    b2Body* body = m_world->CreateBody(&bodyDef);
    
    b2PolygonShape boxShape;
    boxShape.SetAsBox(size.width / 2 / PTM_RATIO, size.height / 2 / PTM_RATIO);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = 1;
    fixtureDef.restitution = 0.3;
    fixtureDef.shape = &boxShape;
    
    body->CreateFixture(&fixtureDef);
}

-(void)setupDebugDraw
{
    
    // Debug Draw functions
    m_debugDraw = new GLESDebugDraw( PTM_RATIO * [[CCDirector sharedDirector]contentScaleFactor]);
    m_world->SetDebugDraw(m_debugDraw);
    
    uint32 flags = 0;
    flags += b2DebugDraw::e_shapeBit;
    
    //		flags += b2DebugDraw::e_jointBit;
    //		flags += b2DebugDraw::e_aabbBit;
    //		flags += b2DebugDraw::e_pairBit;
    //		flags += b2DebugDraw::e_centerOfMassBit;
    m_debugDraw->SetFlags(flags);

}
-(void) setupWorld
{
    // Define the gravity vect or.
    b2Vec2 gravity;
    gravity.Set(0.0f, -10.0f);
    
    // Do we want to let bodies sleep?
    // This will speed up the physics simulation
    bool doSleep = true;
    
    // Construct a world object, which will hold and simulate the rigid bodies.
    m_world = new b2World(gravity, doSleep);
    
    m_world->SetContinuousPhysics(true);
}
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    b2Vec2 locationWorld = b2Vec2(touchLocation.x / PTM_RATIO, touchLocation.y / PTM_RATIO);
    
    [self createBoxAtLocation:touchLocation withSize:CGSizeMake(25, 25)];
    return TRUE;
}

- (void)registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self
                                                     priority:0 swallowsTouches:YES];
}
// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	delete m_world;
	m_world = NULL;
	
	delete m_debugDraw;

	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
