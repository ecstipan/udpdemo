//
//  tmlViewController.m
//  Timeflies Lights
//
//  Created by Rayce Stipanovich on 6/1/14.
//  Copyright (c) 2014 Timeflies. All rights reserved.
//

#import "tmlViewController.h"
#import "GCDAsyncUdpSocket.h"

@interface tmlViewController ()
{
	long tag;
	GCDAsyncUdpSocket *udpSocket;
}
@end

@implementation tmlViewController

- (void)setupSocket
{
	udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

	NSError *error = nil;

	if (![udpSocket bindToPort:7135 error:&error])
	{
		return;
	}
	if (![udpSocket beginReceiving:&error])
	{
		return;
	}

}

- (void)viewDidLoad
{
    [super viewDidLoad];

	if (udpSocket == nil)
	{
		[self setupSocket];
	}


}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
	  fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
	NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (msg)
	{
		//parse our UDP data here
		
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


