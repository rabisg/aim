{-# LANGUAGE TypeFamilies            #-}
{-# LANGUAGE FlexibleInstances       #-}
{-# LANGUAGE MultiParamTypeClasses   #-}

module Aim.Operands where

import Data.Int                  ( Int32, Int64)
import Aim.Arch.X86.Architecture
import Aim.Machine

data Stack32 typ = Stack32 Int32
instance (Type32Bits typ) => Operand (Stack32 typ) where
  type SupportedOn (Stack32 typ) = X86
  type Type (Stack32 typ) = Int32
instance (Type32Bits typ) => Stack (Stack32 typ) typ

data Stack64 typ = Stack64 Int64
instance (Type64Bits typ) => Operand (Stack64 typ) where
  type SupportedOn (Stack64 typ) = X86
  type Type (Stack64 typ) = Int64
instance (Type64Bits typ) => Stack (Stack64 typ) typ
