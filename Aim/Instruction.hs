{-# LANGUAGE ConstraintKinds         #-}
{-# LANGUAGE MultiParamTypeClasses   #-}
{-# LANGUAGE FlexibleContexts        #-}
{-# LANGUAGE GADTs                   #-}

module Aim.Instruction where

import Aim.Machine

type InstructionConstraint machine oper =
  ( Machine machine
  , Operand oper
  , Supports machine oper
  , MachineConstraint machine oper
  , SupportedOn oper ~ ArchOf machine)

type InstructionConstraint2 machine oper1 oper2 =
  ( Machine machine
  , Operand oper1, Operand oper2
  , Supports machine (Type oper1)
  , Supports machine (Type oper2)
  , MachineConstraint machine oper1
  , MachineConstraint machine oper2
  , SupportedOn oper1 ~ (ArchOf machine)
  , SupportedOn oper2 ~ (ArchOf machine)
  )

class Load machine oper1 oper2 where
  load :: ( InstructionConstraint2 machine oper1 oper2)
	  => oper1 -> oper2 -> Instruction machine
