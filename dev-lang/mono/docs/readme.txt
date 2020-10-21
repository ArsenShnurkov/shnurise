[ebuild   R    ] dev-lang/mono-6.12.0.102::shnurise  USE="nls -doc -minimal -pax_kernel -xen" ABI_X86="(64) -32 (-x32)" 0 KiB

$ mono -V
Mono JIT compiler version 6.13.0 (master/a2fcf072e8a Ср июл 22 01:23:59 MSK 2020)
Copyright (C) Novell, Inc, Xamarin Inc and Contributors. www.mono-project.com
	TLS:           __thread
	SIGSEGV:       altstack
	Notifications: epoll
	Architecture:  amd64
	Disabled:      none
	Misc:          softdebug 
	Interpreter:   yes
	LLVM:          supported, not enabled.
	Suspend:       hybrid
	GC:            sgen (concurrent by default)

new lines was added:
- Interpreter:   yes
- Suspend:       hybrid

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

[ebuild   R    ] dev-lang/mono-2016.06.15.06::shnurise  USE="nls (-doc) -minimal -pax_kernel -xen" 0 KiB

# mono -V
Mono JIT compiler version 4.5.2 (tarball Mon Jun 20 20:48:26 MSK 2016)
Copyright (C) 2002-2014 Novell, Inc, Xamarin Inc and Contributors. www.mono-project.com
    TLS:           __thread
    SIGSEGV:       altstack
    Notifications: epoll
    Architecture:  amd64
    Disabled:      none
    Misc:          softdebug 
    LLVM:          supported, not enabled.
    GC:            sgen
