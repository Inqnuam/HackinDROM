//
//  Authorization.m
//  Authorization
//
//  Created by Inqnuam on 13/08/2021.
//  Copyright © 2021 HackitALL. All rights reserved.
//
#ifndef Authorization_h
#define Authorization_h

#include <Security/Security.h>

typedef void (*AuthorizationGrantedCallback)(AuthorizationRef __nullable authorization, OSErr status, void * __nullable context);

void initAuthorization(AuthorizationGrantedCallback _Nonnull callback, void * __nullable context);
OSErr getAuthorization(AuthorizationRef _Nonnull*_Nonnull authorization);
OSErr requestAdministratorRights(void);
void callAuthorizationGrantedCallback(OSErr status);
OSErr freeAuthorization(void);

#endif /* Authorization_hpp */
