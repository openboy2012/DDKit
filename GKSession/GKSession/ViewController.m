//
//  ViewController.m
//  GKSession
//
//  Created by Diaoshu on 15-1-12.
//  Copyright (c) 2015年 MBaoBao Inc. All rights reserved.
//

#import "ViewController.h"
#import <GameKit/GameKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ViewController ()<GKSessionDelegate>

@property (nonatomic, strong) GKSession *sessionServer;
@property (nonatomic, strong) GKSession *sessionClient;
@property (weak, nonatomic) IBOutlet UIButton *btnServer;
@property (weak, nonatomic) IBOutlet UIButton *btnClient;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GKSession Delegate Methods

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error{
    if(session == self.sessionClient){
        NSLog(@"Client Session");
    }else if(session == self.sessionServer){
        NSLog(@"Server Session");
    }
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error{
    if(session == self.sessionClient){
        NSLog(@"Client Session");
    }else if(session == self.sessionServer){
        NSLog(@"Server Session");
    }
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID{
    if(session == self.sessionClient){
        NSLog(@"Client Session");
    }else if(session == self.sessionServer){
        NSLog(@"Server Session");
    }
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state{
    if(session == self.sessionClient){
        NSLog(@"Client Session");
        [self.sessionClient connectToPeer:peerID withTimeout:20.0f];
    }else if(session == self.sessionServer){
        NSLog(@"Server Session");
    }
}


#pragma mark - GKSession Button Clicked Handler
- (IBAction)startAsServer:(id)sender{
    self.sessionServer = [[GKSession alloc] initWithSessionID:@"ddkit" displayName:@"I'm Server" sessionMode:GKSessionModeServer];
    self.sessionServer.delegate = self;
    self.sessionServer.available = YES;
    
    self.btnClient.enabled = NO;
    [self.btnServer setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
}

- (IBAction)startAsClient:(id)sender{
    self.sessionClient = [[GKSession alloc] initWithSessionID:@"ddkit" displayName:@"I'm Client" sessionMode:GKSessionModeClient];
    self.sessionClient.delegate = self;
    self.sessionClient.available = YES;
    
    self.btnServer.enabled = NO;
    [self.btnClient setTitleColor:[UIColor redColor] forState:UIControlStateNormal];

}



@end
