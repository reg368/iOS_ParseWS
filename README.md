# iOS_ParseWS

Description :
  Provide two type of  method  fetch json format data from web service. NSURLSession Base API

Usage :
Independent connection e.g. 
  - (void)fetchRequestWithURL:(NSURL*)url Complete:(void(^)(NSDictionary *, NSError *))complete;
  
  Description : each method has own NSURLSessionDataTask instance. Work  with  Block complete handle.  
  
Related connection e.g.

  implements protocol ParseWSDelegate
 
  By call :
  - (void)fetchRequestWithURL:(NSURL*)url;
  
  By get response :
  -(void)parseWS:(ParseWS*)parseWS completeParseWithData:(NSDictionary*)dict error:(NSError*)error;
  
  Description : create global NSURLSessionDataTask instance . when method call , it will cancel another connection data task 
   if it is still running or pending.  Work with delegate method handle
