//
//  DiskMounter.m
//  DiskMounter
//
//  Created by Inqnuam on 13/08/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

#include "DiskMounter.h"
#import <Foundation/Foundation.h>
#include "Authorization.h"


bool launchCommandAsAdmin(NSString *disk, NSString **stdoutString)
{
    OSStatus status = 0;
    AuthorizationRef authorization = NULL;
    
    if ((status = getAuthorization(&authorization)) != errAuthorizationSuccess)
        return status;
    
    AuthorizationItem adminAuthorization = { "system.privilege.admin", 0, NULL, 0 };
    AuthorizationRights rightSet = { 1, &adminAuthorization };
    
    status = AuthorizationCopyRights(authorization, &rightSet, kAuthorizationEmptyEnvironment, kAuthorizationFlagPreAuthorize | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagExtendRights, NULL);
    
    callAuthorizationGrantedCallback(status);
    
    if (status != errAuthorizationSuccess)
        return false;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSArray *mountingArguments = @[@"mount", disk];
    
    FILE *pipe = NULL;
    NSUInteger count = [mountingArguments count];
    char **args = (char **)calloc(count + 1, sizeof(char *));
    uint32_t i;
    
    for(i = 0; i < count; i++)
        args[i] = (char *)[mountingArguments[i] UTF8String];
    
    args[i] = NULL;
    
    status = AuthorizationExecuteWithPrivileges(authorization, "/usr/sbin/diskutil", kAuthorizationFlagDefaults, args, &pipe);
    
    free(args);
   
    [pool drain];
    
  
    getStdioOutput(pipe, stdoutString, true);
    return (status == errAuthorizationSuccess);
}



bool getStdioOutput(FILE *pipe, NSString **stdoutString, bool waitForExit)
{
    int stat = 0;
    int pipeFD = fileno(pipe);

    if (pipeFD <= 0)
        return false;
    
    if (waitForExit)
    {
        pid_t pid = fcntl(pipeFD, F_GETOWN, 0);
        while ((pid = waitpid(pid, &stat, WNOHANG)) == 0);
    }
    
    NSFileHandle *stdoutHandle = [[NSFileHandle alloc] initWithFileDescriptor:pipeFD closeOnDealloc:YES];
    NSData *stdoutData = [stdoutHandle readDataToEndOfFile];
    NSMutableData *stdoutMutableData = [NSMutableData dataWithData:stdoutData];
    ((char *)[stdoutMutableData mutableBytes])[[stdoutData length] - 1] = '\0';
    *stdoutString = [NSString stringWithCString:(const char *)[stdoutMutableData bytes] encoding:NSASCIIStringEncoding];
    [stdoutHandle release];
    
    return true;
}
