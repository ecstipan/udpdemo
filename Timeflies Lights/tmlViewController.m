//
//  tmlViewController.m
//  Timeflies Lights
//
//  Created by Rayce Stipanovich on 6/1/14.
//  Copyright (c) 2014 Timeflies. All rights reserved.
//

#import "tmlViewController.h"
#import "GCDAsyncUdpSocket.h"
#import <AVFoundation/AVFoundation.h>

@interface tmlViewController ()
{
	long tag;
	GCDAsyncUdpSocket *udpSocket;
	AVCaptureDevice *device;
	UIView *colorScreen;
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

	device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	[device lockForConfiguration:nil];
	colorScreen = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	[colorScreen setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
	[self.view addSubview:colorScreen];
}

- (void)viewWillUnload
{
	[device unlockForConfiguration];
}

- (void)lightOffDelayed
{
	[device setTorchMode:AVCaptureTorchModeOff];
	[device setFlashMode:AVCaptureFlashModeOff];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
	NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (msg)
	{
		//NSLog(msg);
		//parse our UDP data here
		if ([[msg substringToIndex:1] isEqualToString:@"A"])
		{
			//turn on our flash
			if ([device hasTorch] && [device hasFlash]){
				[device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
			}
		}
		else if ([[msg substringToIndex:1] isEqualToString:@"B"])
		{
			//turn off our flash
			if ([device hasTorch] && [device hasFlash]){
				[device setTorchMode:AVCaptureTorchModeOff];
				[device setFlashMode:AVCaptureFlashModeOff];
			}
		}
		else if ([[msg substringToIndex:1] isEqualToString:@"F"])
		{
			//quick flash
			[device setTorchMode:AVCaptureTorchModeOn];
			[device setFlashMode:AVCaptureFlashModeOn];
			[self performSelector:@selector(lightOffDelayed) withObject:nil afterDelay:0.1];
		}else if ([[msg substringToIndex:1] isEqualToString:@"C"])
		{
			//NSLog(@"Setting Color...");
			//set color

			const unsigned char *cstring = [data bytes];
			int resultr = cstring[1] - 35;
			int resultg = cstring[2] - 35;
			int resultb = cstring[3] - 35;

			float red = resultr/90.0;
			float green = resultg/90.0;
			float blue = resultb/90.0;

			//NSLog(@"%f %f %f", red, green, blue);

			[colorScreen setBackgroundColor:[UIColor colorWithRed:red green:green blue:blue alpha:1.0]];
		}else if ([[msg substringToIndex:1] isEqualToString:@"L"])
		{
			//show logo
			//NSLog(@"Logo");
			[colorScreen setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
		}else if ([[msg substringToIndex:1] isEqualToString:@"E"])
		{
			//blackout screen

			//NSLog(@"Blackout");
			[colorScreen setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
		}else {
			if ([device hasTorch] && [device hasFlash]){
				[device setTorchMode:AVCaptureTorchModeOff];
				[device setFlashMode:AVCaptureFlashModeOff];
			}
		}
	} else {
		//NSLog(@"Bad Packet!");
		if ([device hasTorch] && [device hasFlash]){
			[device setTorchMode:AVCaptureTorchModeOff];
			[device setFlashMode:AVCaptureFlashModeOff];
		}
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


