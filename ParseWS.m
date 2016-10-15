//
//  ParseWS.m
//  BlockPractice
//
//  Created by t00javateam@gmail.com on 2016/7/16.
//  Copyright © 2016年 t00javateam@gmail.com. All rights reserved.
//

#import "ParseWS.h"
#import "XMLDictionary.h"

@interface ParseWS()
@property (nonatomic,strong) NSURLSession *globalSession;
@property (nonatomic,strong) NSURLSessionDataTask *globaldataTask;
@property (nonatomic,strong) XMLDictionaryParser *xmlParser;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicatorView;
@end


@implementation ParseWS

-(NSURLSession*)globalSession{
    if(!_globalSession){
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _globalSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return _globalSession;
}

-(UIActivityIndicatorView*)activityIndicatorView{
    if(!_activityIndicatorView){
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _activityIndicatorView;
}

- (void)fetchRequestWithURL:(NSURL*)url WsReturnType:(ParseWSReturnType)type Complete:(void(^)(NSObject *, NSError *))complete{
    
    [self showActivityIndicatorView];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^
            (NSData *data, NSURLResponse *response, NSError *error) {
             
            if(data){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                    
                    switch (type) {
                        case ParseWSReturnJson:{
                            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            dispatch_async(dispatch_get_main_queue(),^{
                                [self stopActivityIndicatorView];
                                complete(json,error);
                            });
                        }
                            break;
                        case ParseWSReturnXml:{
                            self.xmlParser = [XMLDictionaryParser sharedInstance];
                            NSDictionary *xml = [self.xmlParser dictionaryWithData:data];
                            dispatch_async(dispatch_get_main_queue(),^{
                                [self stopActivityIndicatorView];
                                complete(xml,error);
                            });
                        }
                            break;
                        case ParseWSReturnData:{
                            dispatch_async(dispatch_get_main_queue(),^{
                                [self stopActivityIndicatorView];
                                complete(data,error);
                            });
                        }
                            break;
                        default:
                            break;
                    }
                    
                    
                });
            }else{
                [self stopActivityIndicatorView];
                complete(nil,error);
            }

    }];
    
    [dataTask resume];
    
}

-(void)postRequestWithURL:(NSURL*)url andPostDict:(NSDictionary*)dict Complete:(void(^)(NSDictionary*,NSError*))complete{
    
    [self showActivityIndicatorView];
    
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
                    [self stopActivityIndicatorView];
                    complete(json,error);
                });
                
            });
        
        }else{
            [self stopActivityIndicatorView];
            complete(nil,error);
        }
        
    }];

    
    [postDataTask resume];
}


-(void)postRequestWithURL:(NSURL *)url WithParameterName:(NSString*)parameter andXmlString:(NSString *)xmlDoc WsReturnType:(ParseWSReturnType)type Complete:(postRequestWithURLCompelteData)complete{

    [self showActivityIndicatorView];
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
   
    
    xmlDoc = [xmlDoc stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSMutableData *postBody = [NSMutableData data];
    
    NSString *xmlString;
    
    if(parameter != nil && parameter.length > 0){
        xmlString = [NSString stringWithFormat:@"%@=%@",parameter,xmlDoc];
        xmlString = [xmlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    }else{
        xmlString = xmlDoc;
    }
    
    [postBody appendData:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postBody];
    
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(data){
            
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                
                switch (type) {
                    case ParseWSReturnJson:{
                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        dispatch_async(dispatch_get_main_queue(),^{
                            [self stopActivityIndicatorView];
                            complete(json,error);
                        });
                    }
                        break;
                    case ParseWSReturnXml:{
                        self.xmlParser = [XMLDictionaryParser sharedInstance];
                        NSDictionary *xml = [self.xmlParser dictionaryWithData:data];
                        
                        dispatch_async(dispatch_get_main_queue(),^{
                            [self stopActivityIndicatorView];
                            complete(xml,error);
                        });
                    }
                        break;
                    case ParseWSReturnData:{
                        dispatch_async(dispatch_get_main_queue(),^{
                            [self stopActivityIndicatorView];
                            complete(data,error);
                        });
                    }
                        break;
                    default:
                        break;
                }
                
                
            });
            
        }else{
            [self stopActivityIndicatorView];
            complete(nil,error);
        }
        
    }];
    
    
    [postDataTask resume];
    
}



-(void)postRequestWithURL:(NSURL *)url andParameterNameAndValueDict:(NSDictionary*)dict andContentType:(NSString*)contentType isURLEnCode:(BOOL)urlEncode WsReturnType:(ParseWSReturnType)type Complete:(postRequestWithURLCompelteData)complete{
    
    [self showActivityIndicatorView];
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    
    NSString *parameters = @"";
    for(NSString *key in dict){
        
        NSString *parameter = [NSString stringWithFormat:@"%@=%@",key,[dict objectForKey:key]];
        
        [parameters stringByAppendingString:[NSString stringWithFormat:@"%@%@",parameter,@"&"]];
        
    }
    
    if(urlEncode){
        parameters = [parameters stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    }
    
    
    NSMutableData *postBody = [NSMutableData data];
    
    [postBody appendData:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postBody];
    
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(data){
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                
                switch (type) {
                    case ParseWSReturnJson:{
                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        dispatch_async(dispatch_get_main_queue(),^{
                            [self stopActivityIndicatorView];
                            complete(json,error);
                        });
                    }
                        break;
                    case ParseWSReturnXml:{
                        self.xmlParser = [XMLDictionaryParser sharedInstance];
                        NSDictionary *xml = [self.xmlParser dictionaryWithData:data];
                        
                        dispatch_async(dispatch_get_main_queue(),^{
                            [self stopActivityIndicatorView];
                            complete(xml,error);
                        });
                    }
                        break;
                    case ParseWSReturnData:{
                        dispatch_async(dispatch_get_main_queue(),^{
                            [self stopActivityIndicatorView];
                            complete(data,error);
                        });
                    }
                        break;
                    default:
                        break;
                }
                
                
            });
            
        }else{
            [self stopActivityIndicatorView];
            complete(nil,error);
        }
        
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



- (void)fetchRequestWithURL:(NSURL*)url {
    
   if(self.globaldataTask && (self.globaldataTask.state == NSURLSessionTaskStateRunning || self.globaldataTask.state == NSURLSessionTaskStateSuspended))
        [self.globaldataTask cancel];
    
    
    self.globaldataTask = [self.globalSession dataTaskWithURL:url completionHandler:^(NSData *data,NSURLResponse *response , NSError *error){
        
        
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


- (void)fetchImageWithURL:(NSURL*)url {
    
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

-(void)showActivityIndicatorView{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.activityIndicatorView.frame = [[window subviews] objectAtIndex:0].frame;
    [[[window subviews] objectAtIndex:0] addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
}

-(void)stopActivityIndicatorView{
    [self.activityIndicatorView stopAnimating];
    [self.activityIndicatorView removeFromSuperview];
}

-(NSString*)genRootNodeStartTagWithNodeName:(NSString*)name {
    NSString *node = [NSString stringWithFormat:@"%@%@%@",@"<",name,@">"];
    return node;
}



/*
-(NSString*)genRootNodeEndTagWithNodeName:(NSString*)name {
    NSString *node = [NSString stringWithFormat:@"%@%@%@",@"</",name,@">"];
    return node;
}

-(NSString*)genNodeTagWithNodeName:(NSString*)name andNodeValue:(NSString*)value {
    NSString *node = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",@"<",name,@">",value,@"</",name,@">"];
    return node;
}

-(NSMutableData*)generentXmlBodyDataWithDict:(NSMutableDictionary*)dict{
    
    NSMutableData *postBody = [NSMutableData data];
    
    if(dict != nil){
        
        NSMutableDictionary* rootDict = [dict objectForKey:ParseWSXmlRootNode];
        if(rootDict != nil){
          [postBody appendData:[[self genRootNodeStartTagWithNodeName:[rootDict objectForKey:ParseWSXmlNodeName]] dataUsingEncoding:NSUTF8StringEncoding]];
          
          [postBody appendData:[[self genRootNodeEndTagWithNodeName:[rootDict objectForKey:ParseWSXmlNodeName]] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
    }
    
    return postBody;
}

-(void)generentChildNodeWithBody:(NSMutableData*)postBody andDict:(NSMutableDictionary*)dict{
    
    if(dict != nil){
        NSMutableDictionary* childDict = [dict objectForKey:ParseWSXmlChildNode];
    
    }
}

*/


@end
