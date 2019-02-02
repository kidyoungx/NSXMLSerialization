//
//  NSXMLSerialization+Convenience.m
//  CinCer
//
//  Created by Kid Young on 7/24/17.
//  Copyright © 2017 Yang XiHong. All rights reserved.
//

#import "NSXMLSerialization+Convenience.h"
#import <Foundation/NSDictionary.h>
#import <Foundation/NSData.h>

@implementation NSXMLSerialization (Convenience)

+ (nullable NSData *)dataWithXMLObject:(id)obj
{
    return [NSXMLSerialization dataWithXMLObject:obj error:nil];
}

+ (nullable id)XMLObjectWithData:(NSData *)data
{
    return [NSXMLSerialization XMLObjectWithData:data error:nil];
}

+ (nullable NSData *)dataWithXMLObject:(id)obj error:(NSError **)error
{
    if (obj == nil) {
        obj = [NSDictionary dictionary];
    }
    return [NSXMLSerialization dataWithXMLObject:obj options:kNilOptions error:error];
}

+ (nullable id)XMLObjectWithData:(NSData *)data error:(NSError **)error
{
    if (data == nil) {
        data = [NSData data];
    }
    return [NSXMLSerialization XMLObjectWithData:data options:kNilOptions error:error];
}

@end

@implementation NSObject (NSXMLSerialization)

- (NSArray *)xmlArray
{
    if ([self isKindOfClass:NSArray.class]) {
        return (NSArray *)self;
    } else {
        return @[self];
    }
}

@end
