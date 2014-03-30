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
#include <string.h>
#include "InstrUtils.h"
#include "Utils.h"

void deleteInstruction(Instruction *curr_instr)
{
  Instruction *prev_instr = curr_instr->prev;
  Instruction *next_instr = curr_instr->next;

  if (prev_instr) {
    prev_instr->next = next_instr;
  }

  if (next_instr) {
    next_instr->prev = prev_instr;
  }

  free(curr_instr);
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

  char crit_reg_and_vars[102];  // r0, r1, ..., r31, ..., 'a', 'b', 'c', 'd', 'e'
  memset(crit_reg_and_vars, 'f', 102);

  while (curr_instr) {
    curr_instr->critical = 'f';  // guilty until proven innocent

    // all READ instructions are critical
    if (curr_instr->opcode == READ) {
      curr_instr->critical = 't';

    // if WRITE instruction, mark as critical and add field1 to crit_reg_and_vars
    } else if (curr_instr->opcode == WRITE) {
      curr_instr->critical = 't';

      crit_reg_and_vars[curr_instr->field1] = 't';

    // if field1 is in crit_reg_and_vars, then mark instruction as critical,
    // and add field2, field3 into crit_reg_and_vars
    } else if (crit_reg_and_vars[curr_instr->field1] == 't') {
      curr_instr->critical = 't';

      crit_reg_and_vars[curr_instr->field1] = 'f';

      // add field2 if not immediate value
      if (curr_instr->opcode != LOADI) {
        crit_reg_and_vars[curr_instr->field2] = 't';
      }
      // add field3 if not NULL
      if (curr_instr->field3) {
        crit_reg_and_vars[curr_instr->field3] = 't';
      }
    }

    curr_instr = curr_instr->prev;
  }

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

