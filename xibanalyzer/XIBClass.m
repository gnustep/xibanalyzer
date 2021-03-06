//
//  XIBClass.m
//  xibanalyzer
//
//  Created by Gregory Casamento on 1/16/16.
//  Copyright © 2016 GNUstep. All rights reserved.
//

#import "XIBClass.h"
#import "XIBProperty.h"
#import "XIBMethod.h"

@implementation XIBClass

@synthesize attributes, methods;

- (instancetype) init
{
    self = [super init];
    if(self != nil)
    {
        self.attributes = [NSMutableDictionary dictionaryWithCapacity:10];
        self.methods = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return self;
}

- (void) addAttribute: (XIBProperty *)property
{
    XIBProperty *prop = [self.attributes objectForKey:property.name];
    if(prop == nil)
    {
        [self.attributes setObject:property forKey:property.name];
    }
}

- (void) addMethod: (XIBMethod *)method
{
    XIBMethod *meth = [self.methods objectForKey:method.name];
    if(meth == nil)
    {
        [self.methods setObject:method forKey:method.name];
    }
}

- (NSString *)generate
{
    NSString *classString = nil;
    
    classString = [NSString stringWithFormat:@"/* Class Header:%@ */\n#ifndef __%@_H_\n#define __%@_H_\n\n", [self name],[self name],[self name]];
    classString = [classString stringByAppendingString:@"#import <Foundation/Foundation.h>\n\n"];
    
    for(XIBProperty *prop in [[self.attributes allValues] sortedArrayUsingSelector:@selector(compare:)])
    {
        if([prop.type containsString:@"XIB"])
        {
            NSString *headerString = [NSString stringWithFormat: @"@class %@;\n",prop.type];
            classString = [classString stringByAppendingString: headerString];
        }
    }
    
    classString = [classString stringByAppendingFormat:@"\n@interface %@ : NSObject\n{\n", self.name];
    
    for(XIBProperty *prop in [[self.attributes allValues] sortedArrayUsingSelector:@selector(compare:)])
    {
        NSString *propString = [NSString stringWithFormat: @"  %@;\n",[prop generate]];
        classString = [classString stringByAppendingString: propString];
    }
    
    classString = [classString stringByAppendingString:@"}\n\n"];  // end ivar section
    
    for(XIBMethod *method in [[self.methods allValues] sortedArrayUsingSelector:@selector(compare:)])
    {
        NSString *methodString = [NSString stringWithFormat: @"%@;\n",[method generate]];
        classString = [classString stringByAppendingString: methodString];
    }

    classString = [classString stringByAppendingString:@"\n@end\n"];  // end ivar section
    classString = [classString stringByAppendingString:@"\n#endif\n"];

    return classString;
}

- (NSString *)generateInit
{
    NSString *generatedString = @"";

    generatedString = [generatedString stringByAppendingString:@"\n- (instancetype) init\n{\n"];
    generatedString = [generatedString stringByAppendingString:@"   self = [super init];\n"];
    generatedString = [generatedString stringByAppendingString:@"   if(self != nil) {\n"];
    
    for(XIBProperty *prop in [[self.attributes allValues] sortedArrayUsingSelector:@selector(compare:)])
    {
        if([prop.type containsString:@"BOOL"])
        {
            NSString *varString = [NSString stringWithFormat: @"      _%@ = NO;\n",prop.name];
            generatedString = [generatedString stringByAppendingString: varString];
        }
        else
        {
            NSString *varString = [NSString stringWithFormat: @"      _%@ = nil;\n",prop.name];
            generatedString = [generatedString stringByAppendingString: varString];
        }
    }
    
    generatedString = [generatedString stringByAppendingString:@"   }\n"];
    generatedString = [generatedString stringByAppendingString:@"   return self;\n"];
    generatedString = [generatedString stringByAppendingString:@"}\n\n"];
    
    return generatedString;
}

- (NSString *)generateCode
{
    NSString *classString = nil;
    
    classString = [NSString stringWithFormat:@"/* Class Code:%@ */\n\n", [self name]];
    classString = [classString stringByAppendingFormat:@"#import \"%@.h\"\n\n",self.name];
    classString = [classString stringByAppendingString:@"#ifndef GNUSTEP\n"];
    classString = [classString stringByAppendingString:@"#import \"XIBCommon.h\"\n"];
    classString = [classString stringByAppendingString:@"#endif\n\n"];

    for(XIBProperty *prop in [[self.attributes allValues] sortedArrayUsingSelector:@selector(compare:)])
    {
        if([prop.type containsString:@"XIB"])
        {
            NSString *headerString = [NSString stringWithFormat: @"#import \"%@.h\"\n",prop.type];
            classString = [classString stringByAppendingString: headerString];
        }
    }
    
    classString = [classString stringByAppendingFormat:@"\n@implementation %@ \n\n", self.name];
    
    classString = [classString stringByAppendingString:[self generateInit]];
    
    for(XIBMethod *method in [[self.methods allValues] sortedArrayUsingSelector:@selector(compare:)])
    {
        NSString *methodString = [NSString stringWithFormat: @"%@\n",[method generateCode]];
        classString = [classString stringByAppendingString: methodString];
    }
    
    classString = [classString stringByAppendingString:@"- (instancetype) copyWithZone: (NSZone *)zone \n{\n"];
    classString = [classString stringByAppendingFormat:@"   %@* acopy = [[%@ allocWithZone: zone] init];", self.name, self.name];

    for(XIBMethod *method in [[self.methods allValues] sortedArrayUsingSelector:@selector(compare:)])
    {
        NSString *methodString = [NSString stringWithFormat: @"%@\n",[method generateCopy]];
        classString = [classString stringByAppendingString: methodString];
    }
    classString = [classString stringByAppendingString:@"   return acopy;\n"];
    classString = [classString stringByAppendingString:@"}\n"];
    
    classString = [classString stringByAppendingString:@"@end\n"];  // end ivar section
    
    return classString;
}

@end
