{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE MultiParamTypeClasses  #-}
{-# LANGUAGE TypeFamilies           #-}
{-# LANGUAGE OverloadedStrings      #-}

module Aim.Arch.X86.Instruction where

import Data.Word                 (Word32, Word64)
import Aim.Instruction
import Aim.Machine
import Aim.Arch.X86.Architecture
import Aim.Arch.X86.Operands

instance ArchOf machine ~ X86
	 => Load machine (EX Word32) (EX Word32) where
  load o1 o2 = Instruction "load $1 $2"

instance ArchOf machine ~ X86
	 => Load machine (XMM Word128) (XMM Word128) where
  load o1 o2 = Instruction "load $1 $2"
