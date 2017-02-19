perl Configure VC-WIN32 --prefix=C:\OpenSSL-x86 no-shared no-ssl2 no-ssl3 no-idea no-srp no-weak-ssl-ciphers no-camellia no-krb5 no-md2 no-md4 no-mdc2 no-whirlpool no-comp no-asm
ms\do_ms
nmake -f ms\nt.mak 
nmake -f ms\nt.mak install
