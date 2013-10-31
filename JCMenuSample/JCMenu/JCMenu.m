//
//  JCMenu.m
//  JC UI Composant
//

/*
 *
 * Copyright (c) 2013 Jean-Baptiste Castro
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "JCMenu.h"
#import "JCMenuItem.h"

#import <QuartzCore/QuartzCore.h>

@interface JCMenu (/* Private */)

@property(nonatomic, assign) BOOL            expand;

@property(nonatomic, copy)   NSMutableArray *layerArray;        // Contain layer items. Use for rect management.

@property(nonatomic)         CGFloat         originX;
@property(nonatomic)         CGFloat         originY;
@property(nonatomic)         CGFloat         segmentWidth;
@property(nonatomic)         CGFloat         menuHeight;

@property(nonatomic, assign) NSInteger       index;

- (void)__setupMenu;

/*
 Rect management (menu expand/shrink)
 */
- (CGRect)__updateFrame;                                                    // Menu frame.
- (CGRect)__updateItemRectFromFrame:(CGRect)frame index:(NSInteger)index;   // Item frame.

@end

@implementation JCMenu

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setFrame:frame];
        
        self.items = [items copy];
        [self __setupMenu];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setFrame:frame];
        [self __setupMenu];
    }
    
    return self;
}

- (void)__setupMenu
{
    self.originX = self.frame.origin.x;
    self.originY = self.frame.origin.y;
    
    self.expand = NO;
    
    self.menuTintColor = [UIColor blackColor];
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect
{
    // Update unselected layer
    
    [self.items enumerateObjectsUsingBlock:^(id item, NSUInteger index, BOOL *stop) {
        CALayer *layer = [self.layerArray objectAtIndex:index];
        
        if (index != self.index) {
            _expand ? [layer setOpacity:0.5] : [layer setOpacity:0];
        }
        
    }];
    
    // Update selected layer + menu frame
    
    [UIView animateWithDuration:0.2 animations:^{
        CALayer *selectedLayer = [self.layerArray objectAtIndex:self.index];
        [selectedLayer setFrame:[self __updateItemRectFromFrame:selectedLayer.frame index:self.index]];
        [selectedLayer setOpacity:1];
        
        [self setFrame:[self __updateFrame]];
    }];
}

/*
 TODO: Work on unselected item
 */

#pragma mark - Rect Management

- (CGRect)__updateFrame
{
    if (_expand) {
        return CGRectMake(self.originX, self.originY, self.frame.size.width * [self.items count], self.menuHeight);
    } else {
        return CGRectMake(self.originX, self.originY, self.frame.size.width / [self.items count], self.frame.size.height);
    }
    
    return CGRectZero;
}

- (CGRect)__updateItemRectFromFrame:(CGRect)frame index:(NSInteger)index
{
    if (_expand) {
        CGFloat imageWidth = frame.size.width;
        CGFloat imageHeight = frame.size.height;
        
        CGFloat x = self.segmentWidth * index + (self.segmentWidth - imageWidth)/2.0f;
        CGFloat y = (self.menuHeight / 2) - (imageHeight / 2);
        
        CGRect rect = CGRectMake(x, y, imageWidth, imageHeight);
        
        return rect;
    } else {
        CGFloat imageWidth = frame.size.width;
        CGFloat imageHeight = frame.size.height;
        
        CGFloat x = (self.segmentWidth - imageWidth)/2.0f;
        CGFloat y = (self.menuHeight / 2) - (imageHeight / 2);
        
        CGRect rect = CGRectMake(x, y, imageWidth, imageHeight);
        
        return rect;
    }
    
    return CGRectZero;
}

#pragma mark - Touch method

/*
 TODO: Highlight work !
 */

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.bounds, touchLocation)) {
        if (self.expand) {
            self.index = touchLocation.x / (self.frame.size.width / [self.items count]);
            
            [self setSelectedItem:[self.items objectAtIndex:self.index]];
        } else {
            [self setExpand:YES];
        }
    }
}

#pragma mark - Setter

- (void)setItems:(NSArray *)items
{
    if (_items != items) {
        _items = items;
        
        self.segmentWidth = self.frame.size.width / [self.items count];
        self.menuHeight = self.frame.size.height;
        
        [self __updateFrame];
        
        NSMutableArray *layerA = [[NSMutableArray alloc] initWithCapacity:[self.items count]];
        
        [self.items enumerateObjectsUsingBlock:^(id item, NSUInteger index, BOOL *stop) {
            JCMenuItem *menuItem = item;
            UIImage *icon = menuItem.image;
            CGFloat imageWidth = icon.size.width;
            CGFloat imageHeight = icon.size.height;
            
            CGFloat x = self.segmentWidth * index + (self.segmentWidth - imageWidth)/2.0f;
            CGFloat y = (self.menuHeight / 2) - (imageHeight / 2);
            
            CGRect rect = CGRectMake(x, y, imageWidth, imageHeight);
            
            CALayer *imageLayer = [CALayer layer];
            imageLayer.contents = (id)icon.CGImage;
            [imageLayer setFrame:rect];
            [imageLayer setOpacity:0];
            [self.layer addSublayer:imageLayer];
            
            [layerA addObject:imageLayer];
        }];
        
        self.layerArray = layerA;
        
        [self setNeedsDisplay];
    }
}

- (void)setSelectedItem:(JCMenuItem *)selectedItem
{
    _selectedItem = selectedItem;
    
    // Item action
    
    if (_selectedItem.action) {
        _selectedItem.action(_selectedItem);
    }
    
    [self setExpand:NO];
}

- (void)setExpand:(BOOL)expand
{
    if (_expand != expand) {
        _expand = expand;
        
        [self setNeedsDisplay];
    }
}

- (void)setMenuTintColor:(UIColor *)menuTintColor
{
    if (_menuTintColor != menuTintColor) {
        _menuTintColor = menuTintColor;
        
        [self setBackgroundColor:_menuTintColor];
    }
}

@end
