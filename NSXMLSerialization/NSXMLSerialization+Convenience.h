//
//  NSXMLSerialization+Convenience.h
//  CinCer
//
//  Created by Kid Young on 7/24/17.
//  Copyright © 2017 Yang XiHong. All rights reserved.
//

#import "NSXMLSerialization.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSXMLSerialization (Convenience)

+ (nullable NSData *)dataWithXMLObject:(id)obj;

+ (nullable id)XMLObjectWithData:(NSData *)data;

+ (nullable NSData *)dataWithXMLObject:(id)obj error:(NSError **)error;

+ (nullable id)XMLObjectWithData:(NSData *)data error:(NSError **)error;

@end

@interface NSObject (NSXMLSerialization)

- (NSArray *)xmlArray;

@end

NS_ASSUME_NONNULL_END
