unameall = $(shell uname -a)
is_mingw = $(or $(findstring MINGW,$(unameall)))
is_darwin = $(or $(findstring Darwin,$(unameall)))
is_linux = $(or $(findstring Linux,$(unameall)))
supports_std_c23 := $(shell echo "" | $(CC) -std=c23 -x c - -fsyntax-only >/dev/null 2>&1 && echo yes)
supports_std_gnu2x := $(shell echo "" | $(CC) -std=gnu2x -x c - -fsyntax-only >/dev/null 2>&1 && echo yes)
supports_std_c17 := $(shell echo "" | $(CC) -std=c17 -x c - -fsyntax-only >/dev/null 2>&1 && echo yes)
supports_std_c11 := $(shell echo "" | $(CC) -std=c11 -x c - -fsyntax-only >/dev/null 2>&1 && echo yes)

ifneq (,$(is_mingw))
CFLAGS += -I/usr/local/include
CFLAGS += -L/usr/local/lib
ifneq (,$(supports_std_c23))
CFLAGS += -std=c23
CFLAGS += -DMCPC_C23PTCH_UCHAR2
else ifneq (,$(supports_std_gnu2x))
CFLAGS += -std=gnu2x
CFLAGS += -DMCPC_C23PTCH_UCHAR2
else ifneq (,$(supports_std_c17))
CFLAGS += -std=c17
CFLAGS += -DMCPC_C23PTCH_KW1
CFLAGS += -DMCPC_C23PTCH_CKD1
CFLAGS += -DMCPC_C23PTCH_UCHAR1
CFLAGS += -DMCPC_C23GIVUP_FIXENUM
else ifneq (,$(supports_std_c11))
CFLAGS += -std=c11
CFLAGS += -DMCPC_C23PTCH_KW1
CFLAGS += -DMCPC_C23PTCH_CKD1
CFLAGS += -DMCPC_C23PTCH_UCHAR1
CFLAGS += -DMCPC_C23GIVUP_FIXENUM
else
$(error code-to-tree: mingw toolchain lacks required C11 support)
endif
endif

ifneq (,$(is_darwin))
ifneq (,$(supports_std_c23))
CFLAGS += -std=c23
else ifneq (,$(supports_std_gnu2x))
CFLAGS += -std=gnu2x
else ifneq (,$(supports_std_c17))
CFLAGS += -std=c17
CFLAGS += -DMCPC_C23PTCH_KW1
CFLAGS += -DMCPC_C23PTCH_CKD1
CFLAGS += -DMCPC_C23PTCH_UCHAR1
CFLAGS += -Dno_c23_n2508
else ifneq (,$(supports_std_c11))
CFLAGS += -std=c11
CFLAGS += -DMCPC_C23PTCH_KW1
CFLAGS += -DMCPC_C23PTCH_CKD1
CFLAGS += -DMCPC_C23PTCH_UCHAR1
CFLAGS += -Dno_c23_n2508
else
$(error code-to-tree: macos toolchain lacks required C11 support)
endif
endif

ifneq (,$(is_linux))
ifneq (,$(supports_std_c23))
CFLAGS += -std=c23
else ifneq (,$(supports_std_gnu2x))
CFLAGS += -std=gnu2x
else ifneq (,$(supports_std_c17))
CFLAGS += -std=c17
CFLAGS += -DMCPC_C23PTCH_KW1
CFLAGS += -DMCPC_C23PTCH_CKD1
CFLAGS += -DMCPC_C23PTCH_UCHAR1
CFLAGS += -DMCPC_C23GIVUP_FIXENUM
else ifneq (,$(supports_std_c11))
CFLAGS += -std=c11
CFLAGS += -DMCPC_C23PTCH_KW1
CFLAGS += -DMCPC_C23PTCH_CKD1
CFLAGS += -DMCPC_C23PTCH_UCHAR1
CFLAGS += -DMCPC_C23GIVUP_FIXENUM
else
$(error code-to-tree: linux toolchain lacks required C11 support)
endif
endif

ifneq (,$(is_mingw))
LDFLAGS += -Wl,-Bstatic
LDFLAGS += -lmcpc
LDFLAGS += -lws2_32
LDFLAGS += -ltree-sitter
LDFLAGS += -ltree-sitter-c
LDFLAGS += -ltree-sitter-cpp
LDFLAGS += -ltree-sitter-rust
LDFLAGS += -ltree-sitter-go
LDFLAGS += -ltree-sitter-python
LDFLAGS += -ltree-sitter-ruby
LDFLAGS += -ltree-sitter-java
LDFLAGS += -Wl,-Bdynamic
endif

ifneq (,$(is_linux))
LDFLAGS += -Wl,-Bstatic
LDFLAGS += -lmcpc
LDFLAGS += -ltree-sitter
LDFLAGS += -ltree-sitter-c
LDFLAGS += -ltree-sitter-cpp
LDFLAGS += -ltree-sitter-rust
LDFLAGS += -ltree-sitter-go
LDFLAGS += -ltree-sitter-python
LDFLAGS += -ltree-sitter-ruby
LDFLAGS += -ltree-sitter-java
LDFLAGS += -Wl,-Bdynamic
endif

ifneq (,$(is_darwin))
LDFLAGS += /usr/local/lib/libmcpc.a
LDFLAGS += /usr/local/lib/libtree-sitter.a
LDFLAGS += /usr/local/lib/libtree-sitter-c.a
LDFLAGS += /usr/local/lib/libtree-sitter-cpp.a
LDFLAGS += /usr/local/lib/libtree-sitter-rust.a
LDFLAGS += /usr/local/lib/libtree-sitter-go.a
LDFLAGS += /usr/local/lib/libtree-sitter-python.a
LDFLAGS += /usr/local/lib/libtree-sitter-ruby.a
LDFLAGS += /usr/local/lib/libtree-sitter-java.a
endif

.PHONY: code-to-tree

all: code-to-tree

code-to-tree:
	$(CC) $(CFLAGS) code-to-tree.c $(LDFLAGS) -o $@
