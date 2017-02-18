//
//  ViewController.m
//  XMLAndJson__ZongAng
//
//  Created by mac on 16/7/28.
//  Copyright © 2016年 纵昂. All rights reserved.
//
/**
 *  iOS开发——XML/JSON数据解析
 *
 *  @return Json格式：NSJSONSerialization，官方提供的Json数据格式解析类，iOS5以后支持
                     JSONKit（第三方类库）
                     SBJson
                     TouchJson
    XML格式：NSXMLParse，官方自带
            GDataXML，Google提供的开元XML解析库
 */
#import "ViewController.h"
#import "User.h"

@interface ViewController ()

{
    NSMutableArray * _userArray;
    User * _user;
    NSMutableString * _buffer;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //设置请求路径
    NSURL *url = [NSURL URLWithString:@"http://localhost:8080/Login/NewServlet"];
    //创建请求对象
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:url];
    //设置请求方式
    [postRequest setHTTPMethod:@"POST"];
    //设置请求参数
    [postRequest setHTTPBody:[@"command=3" dataUsingEncoding:NSUTF8StringEncoding]];
    //发送请求，建立连接
    [NSURLConnection sendAsynchronousRequest:postRequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        NSLog(@"data -------> %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        //NSXMLParser:专门解析XML的类  -- sax dom
        //sax
        //创建解析类对象
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        //设置代理
        parser.delegate = self;
        //开始解析
        [parser parse];
    }];
    
}

#pragma mark - NSXMLParserDelegate

//开始解析
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"--------开始解析");
    _userArray = [[NSMutableArray alloc] init];
    _buffer = [[NSMutableString alloc] init];
}

//找到一个开始标签
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict {
    NSLog(@"找到一个开始标签 --------%@", elementName);
    if ([elementName  isEqualToString:@"friend"]) {
        _user = [[User alloc] init];
    }
}

//找到一个值
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSLog(@" 值-------%@", string);
    
    //如果数据过多，分多次返回，我们要拼接数据
    [_buffer appendString:string];
}

//找到一个结束标签
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName {
    NSLog(@"找到一个结束标签 ------->%@", elementName);
    
    if ([elementName isEqualToString:@"name"]) {
        _user.name = _buffer;
    }else if ([elementName isEqualToString:@"pwd"]) {
        _user.pwd = _buffer;
    }else if([elementName isEqualToString:@"trueName"]) {
        _user.trueName = _buffer;
    }else if ([elementName isEqualToString:@"age"]) {
        _user.age = _buffer;
    }else if ([elementName isEqualToString:@"friend"]) {
        [_userArray addObject:_user];
        //用完之后 释放
        _user = nil;
    }
    
    //清空数据，以便后续取值
    [_buffer setString:@""];
}

//结束解析
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"结束解析");
    
    NSLog(@"--------======----->%ld", _userArray.count);
    for (User *user in _userArray) {
        NSLog(@"------------->%@", user.name);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *  NSXMLParse
 关于XML，有两种解析方式，分别是SAX（Simple API for XML，基于事件驱动的解析方式，逐行解析数据，采用协议回调机制）和DOM（Document Object Model ，文档对象模型。解析时需要将XML文件整体读入，并且将XML结构化成树状，使用时再通过树状结构读取相关数据，查找特定节点，然后对节点进行读或写）。苹果官方原生的NSXMLParse类库采用第一种方式，即SAX方式解析XML，它基于事件通知的模式，一边读取文档一边解析数据，不用等待文档全部读入以后再解析，所以如果你正打印解析的数据，而解析过程中间出现了错误，那么在错误节点之间的数据会正常打印，错误后面的数据不会被打印。解析过程由NSXMLParserDelegate协议方法回调。
 */
@end
