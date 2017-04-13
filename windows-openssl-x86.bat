perl Configure VC-WIN32 --prefix=C:\OpenSSL-x86 no-shared no-ssl2 no-ssl3 no-idea no-srp no-weak-ssl-ciphers no-camellia no-krb5 no-md2 no-md4 no-mdc2 no-whirlpool no-comp no-asm
ms\do_ms
nmake -f ms\nt.mak 
nmake -f ms\nt.mak install

set LIB=%LIB%;C:\OpenSSL-x86\lib
set INCLUDE=%INCLUDE%;C:\OpenSSL-x86\include

cd ..\pthreads
nmake clean VC-static

set LIB=%LIB%;C:\pthreads-x86\
set INCLUDE=%INCLUDE%;C:\pthreads-x86
