//
//  LIVTextFile.m
//  TestAppLivit
//
//  Created by Dmitry Malakhov on 27.06.16.
//  Copyright © 2016 Dmytro Malakhov. All rights reserved.
//

#import "LIVTextFile.h"

@implementation LIVTextFile

+ (void)initialize {
    [self sharedInstance];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LIVTextFile *instanceTextFile = nil;
    dispatch_once(&onceToken, ^{
            instanceTextFile = [[self alloc] init];
    });
    return instanceTextFile;
}

- (instancetype)init {
    if (self = [super init]) {
        [self dowloadFileFromURLString:@"https://lvt.me/textfile.txt"];
    }
    return self;
}

- (void)dowloadFileFromURLString:(NSString *)urlString {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if ([httpResponse statusCode] == 404) {
            //No file found with Url
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noFileByUrl" object:nil userInfo:@{@"url":urlString}];
            });
            return;
        }
        if (data) {
            self.loadedText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self countOccurrences];
        } else {
            NSLog(@"error = %@", error);
        }
    }];
    [task resume];
}

- (void)countOccurrences {
    self.countedWordSet = [NSCountedSet new];
    
    [self.loadedText enumerateSubstringsInRange:NSMakeRange(0, [self.loadedText length])
                               options:NSStringEnumerationByWords | NSStringEnumerationLocalized
                                usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
                                    // This block is called once for each word in the string.
                                    [self.countedWordSet addObject:substring];
                                    
                                    // If you want to ignore case, so that "this" and "This"
                                    // are counted the same, use this line instead to convert
                                    // each word to lowercase first:
                                    // [countedSet addObject:[substring lowercaseString]];
                                }];
    
    NSMutableArray *wordOccurrencesArray = [NSMutableArray array];
    [self.countedWordSet enumerateObjectsUsingBlock: ^(id obj, BOOL *stop) {
        [wordOccurrencesArray addObject:@{@"object": obj, @"count": @([self.countedWordSet countForObject:obj])}];
    }];
    
   self.sortedWordOccurrencesArray = [wordOccurrencesArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO]]];
    // Async post a notification in main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"wordCounterUpdated" object:nil];
    });
}

@end
