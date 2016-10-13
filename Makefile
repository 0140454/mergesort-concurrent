CC = gcc
CFLAGS = -std=gnu99 -Wall -g -pthread
OBJS = list.o threadpool.o main.o merge_sort.o

THREAD_NUM ?= $(shell nproc)

.PHONY: all clean test

GIT_HOOKS := .git/hooks/pre-commit

all: $(GIT_HOOKS) sort

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

deps := $(OBJS:%.o=.%.o.d)
%.o: %.c
	$(CC) $(CFLAGS) -o $@ -MMD -MF .$@.d -c $<

sort: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS) -rdynamic

check: all
	sort -R dictionary/words.txt | ./sort $(THREAD_NUM) $(shell wc -l dictionary/words.txt) > sorted.txt
	diff -u dictionary/words.txt sorted.txt && echo "Verified!" || echo "Failed!"

clean:
	rm -f $(OBJS) sort
	@rm -rf $(deps)

-include $(deps)
