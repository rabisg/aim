{-# LANGUAGE TypeFamilies            #-}
{-# LANGUAGE FlexibleInstances       #-}
{-# LANGUAGE MultiParamTypeClasses   #-}

module Aim.Arch.X86.Operands where

import Data.Word                  ( Word32, Word64)
import Aim.Arch.X86.Architecture
import Aim.Machine

data EX typ = EAX | EBX | ECX

-- | Make EAX an operand
instance (Type32Bits typ) => Operand (EX typ) where
  type SupportedOn (EX typ) = X86
  type Type (EX typ) = Word32
-- | Make EAX a register
instance (Type32Bits typ) => Register (EX typ) typ

data XMM typ = XMM0 | XMM1 | XMM2 | XMM3 | XMM4 | XMM5 | XMM6 | XMM7
instance (Type128Bits typ) => Operand (XMM typ) where
  type SupportedOn (XMM typ) = X86
  type Type (XMM typ) = Word128
instance (Type128Bits typ) => Register (XMM typ) typ
