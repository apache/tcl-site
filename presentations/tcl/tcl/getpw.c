#include <tcl.h>
#include <pwd.h>
#include <unistd.h>
#include <sys/types.h>

/* 
 gcc -fPIC -Wall -g -c getpw.c ; gcc -g -fPIC -shared -Wl,-soname,libgetpw.so -o libgetpw.so getpw.o 
 */

int
GetPW(ClientData clientData, Tcl_Interp *interp,
	     int objc, Tcl_Obj *CONST objv[])
{
    struct passwd *passwd;
    passwd = getpwuid(getuid());
    Tcl_SetVar2(interp, passwd->pw_name, "passwd", passwd->pw_passwd, 0);
    Tcl_SetVar2(interp, passwd->pw_name, "name", passwd->pw_gecos, 0);
    Tcl_SetVar2(interp, passwd->pw_name, "home", passwd->pw_dir, 0);
    Tcl_SetVar2(interp, passwd->pw_name, "shell", passwd->pw_shell, 0);
    Tcl_SetResult(interp, passwd->pw_name, NULL);
    return TCL_OK;
}


int Getpw_Init(Tcl_Interp *interp)
{
    Tcl_CreateObjCommand(interp,
			 "getpw",
			 GetPW,
			 NULL,
			 (Tcl_CmdDeleteProc *)NULL);
    return TCL_OK;
}
