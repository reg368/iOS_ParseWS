//
//  ParseWS.h
//  BlockPractice
//
//  Created by t00javateam@gmail.com on 2016/7/16.
//  Copyright © 2016年 t00javateam@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ParseWSDelegate;

@interface ParseWS : NSObject <NSURLSessionDelegate>
@property (nonatomic,weak) id<ParseWSDelegate> delegate;

/**
 *   GET request with complete block handle call back method
 */
- (void)fetchRequestWithURL:(NSURL*)url Complete:(void(^)(NSDictionary *, NSError *))complete;

/**
 *   post request with complete block handle call back method
 */
- (void)postRequestWithURL:(NSURL*)url andPostDict:(NSDictionary*)dict Complete:(void(^)(NSDictionary*,NSError*))complete;

/**
 *   fetch Image request with complete block handle call back method
 */
- (void)fetchImageWithURL:(NSURL*)url Callback:(void(^)(UIImage * , NSError *))complete;

/**
 *   GET request with ParseWSDelegate - completeParseWithData handle call back method
 *   by call this method will cancel present url connection which if not completed.
 */
- (void)fetchRequestWithURL:(NSURL*)url ;

/**
 *   post request with ParseWSDelegate - completeParseWithData handle call back method
 *   by call this method will cancel present url connection which if not completed.
 */
- (void)postRequestWithURL:(NSURL*)url andPostDict:(NSDictionary*)dict ;

/**
 *   fetch Image request with ParseWSDelegate - completeParseWithImage handle call back method
 *   by call this method will cancel present url connection which if not completed.
 */
- (void)fetchImageWithURL:(NSURL*)url;

@end

@protocol ParseWSDelegate <NSObject>
@optional
-(void)parseWS:(ParseWS*)parseWS completeParseWithData:(NSDictionary*)dict error:(NSError*)error;
-(void)parseWS:(ParseWS*)parseWS completeParseWithImage:(UIImage*)image error:(NSError*)error;
@end