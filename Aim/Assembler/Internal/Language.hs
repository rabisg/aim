{-|

Internal module that captures the abstract syntax of the assembly
language. The assembly language here is mostly type less and hence
users of @aim@ should avoid using it directly.

-}

{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module Aim.Assembler.Internal.Language
       ( Declaration(..), Array(..), Function(..), Stack(..)
       , Statement(..), Arg(..), VarDec(..)
       -- * Helpers to create immediate arguments
       , word8, word16, word32, word64, word128, word256, char8
       , int8, int16, int32, int64, int128, int256
       -- * Constants
       , Constant(..), Signed(..), signed, unsigned
       -- * Stuff with comments
       , Commented(..), (<#>), (<!>)
       -- * Some Monoids
       , ProgramMonoid, BlockMonoid, CommentMonoid

       ) where

import Data.Int              ( Int8, Int16, Int32, Int64     )
import Data.String
import Data.Text             ( Text                          )
import Data.Word             ( Word8, Word16, Word32, Word64 )

import Aim.Machine

-- | A program for a given architecture.
type ProgramMonoid arch  = CommentMonoid (Declaration arch)

-- | A statement block for a given architecture
type BlockMonoid   arch  = CommentMonoid (Statement   arch)

-- | A declaration is either an array or a function definition.
data Declaration arch = Verbatim Text -- ^ copy verbatim.
                      | DArray (Array arch)
                                      -- ^ An integral array
                                      -- declaration
                      | DFun (Function arch)
                                      -- ^ A function definition
                      deriving Show

-- | An array.
data Array arch = Array { arrayName      :: Text
                        , arrayValueSize :: Size
                        , arrayContents  :: [Integer]
                        } deriving Show
-- | A function.
data Function arch = Function { functionName       :: Text
                              , functionStack      :: Stack
                              , functionBody       :: BlockMonoid arch
                              } deriving Show

-- | Argument and local variables of the function determine the
-- contents of the stack of a functional call.
data Stack = Stack { stackParams    :: [VarDec]
                   , stackLocalVars :: [VarDec]
                   } deriving Show

-- | An statement can take 0,1,2 or 3 arguments. The text field is the
-- neumonic of the instruction.
data Statement arch = S0 Text
                    | S1 Text (Arg arch)
                    | S2 Text (Arg arch) (Arg arch)
                    | S3 Text (Arg arch) (Arg arch) (Arg arch)
                    deriving Show

-- | An argument of an assembly statement.
data Arg arch = Immediate Constant -- ^ An immediate value
              | Param     Int      -- ^ A parameter
              | Local     Int      -- ^ A local variable
              | Reg       Text     -- ^ A register
              | Indirect  Text
                          Size
                          Int      -- ^ An indirect address. The text
                                   -- field is the name of the
                                   -- register used for indirection
              deriving Show

-- | A variable declaration.
data VarDec = VarDec (Signed Size) Text deriving Show

------------------- Some helper functions --------------------

-- | An 8-bit unsigned integer.
word8  :: Word8  -> (Arg arch)
word8  = Immediate . I Size8 . unsigned . toInteger

-- | A 16-bit unsigned integer.
word16 :: Word16 -> (Arg arch)
word16 = Immediate . I Size16 . unsigned . toInteger

-- | A 32-bit unsigned integer.
word32 :: Word32 -> (Arg arch)
word32 = Immediate . I Size32 . unsigned . toInteger

-- | A 64-bit unsiged integer.
word64 :: Word64 -> (Arg arch)
word64 = Immediate . I Size64 . unsigned . toInteger

-- | A 128-bit unsigned integer.
word128 :: Integer -> (Arg arch)
word128 = Immediate . I Size128 . unsigned

-- | A 256-bit unsiged integer.
word256 :: Integer -> (Arg arch)
word256 = Immediate . I Size256 . unsigned

-- | Encode a character into its ascii equivalent.
char8 :: Char -> (Arg arch)
char8 = word8 . toEnum . fromEnum

-- | A signed 8-bit integer
int8 :: Int8 -> (Arg arch)
int8 = Immediate . I Size8 . signed . toInteger

-- | A signed 16-bit integer
int16 :: Int16 -> (Arg arch)
int16 = Immediate . I Size16 . signed . toInteger

-- | A signed 32-bit integer
int32 :: Int32 -> (Arg arch)
int32 = Immediate . I Size32 . signed . toInteger

-- | A signed 64-bit integer
int64 :: Int64 -> (Arg arch)
int64 = Immediate . I Size64 . signed . toInteger

-- | A signed 128-bit integer.
int128 :: Integer -> (Arg arch)
int128 = Immediate . I Size128 . signed

-- | A signed 256-bit integer.
int256 :: Integer -> (Arg arch)
int256 = Immediate . I Size256 . signed


--------------------- Constants ----------------------------------------


-- | A constant.
data Constant = I Size (Signed Integer)  -- ^ A signed integer
              | F Double                 -- ^ A floting point constant.
              deriving Show


-- | Tags the value to distinguish between signed and unsigned
-- quantities.
data Signed a = S a
              | U a  deriving Show

-- | Create a signed object.
signed :: a -> Signed a
signed = S

-- | Create an unsigned object.
unsigned :: a -> Signed a
unsigned =  U

------------------ Commenting ------------------------------------------

-- | An element that can be tagged with a comment.
data Commented a = Comment (Maybe a) Text deriving Show

-- | The comments monoid
type CommentMonoid a = [Commented a]

instance Functor Commented where
  fmap f (Comment ma txt) = Comment (fmap f ma) txt

instance IsString (Commented a) where
  fromString = Comment Nothing . fromString

-- | Comment an object.
(<#>) :: a -> Text -> Commented a
(<#>) x = Comment (Just x)

-- | Comments first and then the object.
(<!>) :: Text -> a -> Commented a
(<!>) = flip (<#>)
