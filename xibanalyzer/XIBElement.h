//
//  XIBElement.h
//  xibanalyzer
//
//  Created by Gregory Casamento on 1/17/16.
//  Copyright © 2016 GNUstep. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XIBElement : NSObject
{
    NSString *name;
}

@property (nonatomic, retain) NSString *name;

- (NSString *) generate;
- (NSString *) generateCode;

@end
