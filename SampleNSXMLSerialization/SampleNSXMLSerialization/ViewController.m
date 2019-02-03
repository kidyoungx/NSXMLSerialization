//
//  ViewController.m
//  SampleNSXMLSerialization
//
//  Created by Kid Young on 2/3/19.
//  Copyright © 2019 Yang XiHong. All rights reserved.
//

#import "ViewController.h"
#import <NSXMLSerialization.h>

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSData *data = [NSXMLSerialization dataWithXMLObject:@[@"root", @"object"] options:kNilOptions error:nil];
    NSDictionary *dic = [NSXMLSerialization XMLObjectWithData:data options:kNilOptions error:nil];
    NSLog(@"%@", dic);
    // Do any additional setup after loading the view.
    dic;
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
