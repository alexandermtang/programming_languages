/*
 *********************************************
 *  314 Principles of Programming Languages  *
 *  Spring 2014                              *
 *  Authors: Ulrich Kremer                   *
 *           Hans Christian Woithe           *
 *********************************************
 */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include "InstrUtils.h"
#include "Utils.h"
#include "sorted-list.h"

void deleteInstruction(Instruction *curr_instr)
{
  Instruction *prev_instr = curr_instr->prev;
  Instruction *next_instr = curr_instr->next;

  prev_instr->next = next_instr;
  next_instr->prev = prev_instr;

  free(curr_instr);
}

int compare_ints(void *p1, void *p2)
{
  int i1 = *(int *)p1;
  int i2 = *(int *)p2;

  return i1 - i2;
}

void destroy_int(void *p)
{
  int *i = (int *)p;
  free(i);

  return;
}

int main()
{
  Instruction *head;

  head = ReadInstructionList(stdin);
  if (!head) {
    WARNING("No instructions\n");
    exit(EXIT_FAILURE);
  }

  // start from last instruction
  Instruction *curr_instr = LastInstruction(head);

  SortedList *crit_reg_and_vars = SLCreate(compare_ints, destroy_int);

  while (curr_instr) {
    curr_instr->critical = 'f';  // guilty until proven innocent

    // all READ instructions are critical
    if (curr_instr->opcode == READ) {
      curr_instr->critical = 't';

    // if WRITE instruction, mark as critical and add field1 to crit_reg_and_vars
    } else if (curr_instr->opcode == WRITE) {
      curr_instr->critical = 't';

      int *field1 = malloc(sizeof(int));
      memcpy(field1, &curr_instr->field1, sizeof(int));
      SLInsert(crit_reg_and_vars, field1);

    // if field1 is in crit_reg_and_vars, then mark instruction as critical
    } else if (SLFind(crit_reg_and_vars, &curr_instr->field1)) {
      curr_instr->critical = 't';
      SLRemove(crit_reg_and_vars, &curr_instr->field1);

      // add field2 if not immediate value
      if (curr_instr->opcode != LOADI) {
        int *field2 = malloc(sizeof(int));
        memcpy(field2, &curr_instr->field2, sizeof(int));
        SLInsert(crit_reg_and_vars, field2);
      }
      // add field3 if not NULL
      if (curr_instr->field3) {
        int *field3 = malloc(sizeof(int));
        memcpy(field3, &curr_instr->field3, sizeof(int));
        SLInsert(crit_reg_and_vars, field3);
      }
    }

    curr_instr = curr_instr->prev;
  }

  SLDestroy(crit_reg_and_vars);

  // delete all non-critical instructions
  curr_instr = head;
  while (curr_instr) {
    Instruction *next_instr = curr_instr->next;
    if (curr_instr->critical != 't') {
      deleteInstruction(curr_instr);
    }
    curr_instr = next_instr;
  }

  if (head) {
    PrintInstructionList(stdout, head);
    DestroyInstructionList(head);
  }

  return EXIT_SUCCESS;
}

