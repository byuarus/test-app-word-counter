//
//  LIVTextFile.h
//  TestAppLivit
//
//  Created by Dmitry Malakhov on 27.06.16.
//  Copyright © 2016 Dmytro Malakhov. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LIVTextFile : NSObject

@property (nonatomic, strong) NSString *loadedText;
@property (nonatomic, strong) NSCountedSet *countedWordSet;
@property (nonatomic, strong) NSArray *sortedWordOccurrencesArray;

+ (instancetype)sharedInstance;
- (void)dowloadFileFromURLString:(NSString *)urlString;

@end
