//
//  HelloWorldLayer.h
//  karaca
//
//  Created by yasin on 9/7/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
	b2World* m_world;
	GLESDebugDraw *m_debugDraw;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
-(void) createGround;
-(void) createBoxAtLocation:(CGPoint)location withSize:(CGSize)size;
-(void) setupDebugDraw;
-(void) setupWorld;


@end
