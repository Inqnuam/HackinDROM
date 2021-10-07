//
//  Mounter.m
//  Mounter
//
//  Created by Inqnuam on 13/08/2021.
//  Copyright © 2021 HackitALL. All rights reserved.
//

#ifndef DiskMounter_h
#define DiskMounter_h
#import <Foundation/Foundation.h>

bool launchCommandAsAdmin(NSString *disk, NSString **stdoutString);
bool getStdioOutput(FILE *pipe, NSString **stdoutString, bool waitForExit);
#endif
