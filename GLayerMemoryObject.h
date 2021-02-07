//
//  GLayerMemoryObject.h
//  BraveRocket
//
//  Created by Alexander Lowe on 4/29/17.
//  Copyright © 2017 Alexander Lowe. See Licence.
//


/*
 
Here's the connondrum that we find ourselves in. For better or for worse, we're dealing with a system of layers in this game engine.
We have a layer to handle rendering, a layer to handle animation. Why layers? Well, see a) because it's convenient from a programming 
perspectvie and b) because we run into the following kind of problems without layers: See, we SHOULD have a behavior layer for all of the 
little physics and collision detection stuff that these sprites are supposed to do. We DON'T, and so we mix the collision-evaluation and also
frame-behaviors i.e. "self.x += speed" right into the render functions, and what we end up with is a bunch of nasty issues where we're not 
really sure if the render is supposed to be evalutated BEFORE or AFTER all of the pseudo-physics gets evaluated. We end up with nasty 
 "intraframe" issues where some object was destroyed earlier in the loop, but it hasn't ACTUALLY been destroyed YET because that happens at the 
 end of the loop and meanwhile some other object needs to know about it. The state of the render loop is unsettled.
 
So to get around this, we have layers. ALL of the objects get their animations evaluated, then ALL of the objects get their renders, and yes 
 soon there will be another layer so that ALL of the object will get their collisions and pseudo-physics evaluated. So that's what we have.
 
Now, there's one accomodation we have to make here, which is for memory. What will happen is that an object will get destroyed on one layer, but then the other layers have to know not to interact with it, because otherwise we'll get nasty run-time errors. So what happens is this: Whenever a layer has to do something with an object, it's going to retain it. When it's done it's going to release it. Whenever isObjectDestroyed = YES, that means that the object is to be considered non-existent. It has released all of its resources and is gone for good. The only thing that remains is its memory shadow and the isObjectDestroyed property. So when a layer encounters such an object, it will release the object. IT MIGHT STILL EXIST AFTER THAT POINT if another layer is still using it, OR IF ANOTHER PART OF THE SAME LAYER is still using it. It won't ACTUALLY disappear until ALL layeres are done with it.

 */

@protocol GLayerMemoryObject

@property (nonatomic, assign) BOOL isObjectDestroyed;

- (void) performSelector:(SEL)callback withObject:(id)object;

- (BOOL) respondsToSelector:(SEL)selector;

- (void) retain;
- (void) release;

@end
