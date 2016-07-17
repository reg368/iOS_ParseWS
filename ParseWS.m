//
//  ParseWS.m
//  BlockPractice
//
//  Created by t00javateam@gmail.com on 2016/7/16.
//  Copyright © 2016年 t00javateam@gmail.com. All rights reserved.
//

#import "ParseWS.h"

@interface ParseWS()
@property (nonatomic,strong) NSURLSession *globalSession;
@property (nonatomic,strong) NSURLSessionDataTask *globaldataTask;
@end

@implementation ParseWS

-(NSURLSession*)globalSession{
    if(!_globalSession){
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _globalSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return _globalSession;
}


- (void)fetchRequestWithURL:(NSURL*)url Complete:(void(^)(NSDictionary *, NSError *))complete{
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^
            (NSData *data, NSURLResponse *response, NSError *error) {
             
            if(data){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                    
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    
                    dispatch_async(dispatch_get_main_queue(),^{
                        complete(json,error);
                    });
                    
                });
            }else
                complete(nil,error);

    }];
    
    [dataTask resume];
    
}

-(void)postRequestWithURL:(NSURL*)url andPostDict:(NSDictionary*)dict Complete:(void(^)(NSDictionary*,NSError*))complete{
    
    NSError *error;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
   
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:@"POST"];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    
    [request setHTTPBody:postData];
    
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(data){
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                dispatch_async(dispatch_get_main_queue(),^{
                    complete(json,error);
                });
                
            });
        
        }else
            complete(nil,error);
        
    }];

    
    [postDataTask resume];
}

- (void)fetchImageWithURL:(NSURL*)url Callback:(void(^)(UIImage * , NSError *))complete{
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^
                                      (NSData *data, NSURLResponse *response, NSError *error) {
                                          if(data){
                                              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                  
                                                  UIImage *image = [UIImage imageWithData:data];
                                                  
                                                  dispatch_async(dispatch_get_main_queue(),^{
                                                      complete(image,error);
                                                  });
                                              
                                              });
                                          }else
                                              complete(nil,error);
                                          
                                      }];
    
    [dataTask resume];
}



- (void)fetchRequestWithURL:(NSURL*)url{
    
   if(self.globaldataTask && (self.globaldataTask.state == NSURLSessionTaskStateRunning || self.globaldataTask.state == NSURLSessionTaskStateSuspended))
        [self.globaldataTask cancel];
    
    
    self.globaldataTask = [self.globalSession dataTaskWithURL:url completionHandler:^(NSData *data,NSURLResponse *response , NSError *error){
        
        
        if(data){
            NSLog(@"data is not nil");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                dispatch_async(dispatch_get_main_queue(),^{
                    if([_delegate respondsToSelector:@selector(parseWS:completeParseWithData:error:)]){
                        [_delegate parseWS:self completeParseWithData:json error:error];
                    }
                });
                
            });
        }else{
            NSLog(@"data is nil");
            if([_delegate respondsToSelector:@selector(parseWS:completeParseWithData:error:)]){
                [_delegate parseWS:self completeParseWithData:nil error:error];
            }
        }
    
    }];
    
    [self.globaldataTask resume];
}


- (void)postRequestWithURL:(NSURL*)url andPostDict:(NSDictionary*)dict{
    
    if(self.globaldataTask && (self.globaldataTask.state == NSURLSessionTaskStateRunning || self.globaldataTask.state == NSURLSessionTaskStateSuspended))
        [self.globaldataTask cancel];
    
    NSError *error;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:@"POST"];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    
    [request setHTTPBody:postData];
    
    self.globaldataTask = [self.globalSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(data){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                dispatch_async(dispatch_get_main_queue(),^{
                    if([_delegate respondsToSelector:@selector(parseWS:completeParseWithData:error:)]){
                        [_delegate parseWS:self completeParseWithData:json error:error];
                    }
                });
                
            });
        }else{
            if([_delegate respondsToSelector:@selector(parseWS:completeParseWithData:error:)]){
                [_delegate parseWS:self completeParseWithData:nil error:error];
            }
        }

    }];

    [self.globaldataTask resume];
}


- (void)fetchImageWithURL:(NSURL*)url{
    
    if(self.globaldataTask && (self.globaldataTask.state == NSURLSessionTaskStateRunning || self.globaldataTask.state == NSURLSessionTaskStateSuspended))
        [self.globaldataTask cancel];
    
    self.globaldataTask = [self.globalSession dataTaskWithURL:url completionHandler:^
                           (NSData *data, NSURLResponse *response, NSError *error) {
                               
                               if(data){
                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                       
                                       UIImage *image = [UIImage imageWithData:data];
                                       
                                       dispatch_async(dispatch_get_main_queue(),^{
                                           if([_delegate respondsToSelector:@selector(parseWS:completeParseWithImage:error:)]){
                                               [_delegate parseWS:self completeParseWithImage:image error:error];
                                           }
                                       });
                                       
                                   });
                               }else
                                   if([_delegate respondsToSelector:@selector(parseWS:completeParseWithImage:error:)]){
                                       [_delegate parseWS:self completeParseWithImage:nil error:error];
                                   }
                           }];
    
    [self.globaldataTask resume];
    
}



@end
