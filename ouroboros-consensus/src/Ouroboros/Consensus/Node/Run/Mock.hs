{-# LANGUAGE FlexibleContexts     #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE UndecidableInstances #-}

{-# OPTIONS_GHC -fno-warn-orphans #-}
module Ouroboros.Consensus.Node.Run.Mock () where

import           Codec.Serialise (Serialise, decode, encode)
import           Data.Typeable (Typeable)

import           Ouroboros.Consensus.Block
import           Ouroboros.Consensus.Ledger.Abstract
import           Ouroboros.Consensus.Ledger.Mock
import           Ouroboros.Consensus.Node.Run.Abstract
import           Ouroboros.Consensus.Protocol.Abstract (ChainState)


{-------------------------------------------------------------------------------
  RunNode instance for the mock ledger
-------------------------------------------------------------------------------}

instance ( ProtocolLedgerView (SimpleBlock SimpleMockCrypto ext)
           -- The below constraint seems redundant but is not! When removed,
           -- some of the tests loop, but only when compiled with @-O2@ ; with
           -- @-O0@ it is perfectly fine. ghc bug?!
         , SupportedBlock (SimpleBlock SimpleMockCrypto ext)
         , Show ext
         , Typeable ext
         , Serialise ext
         , ForgeExt (BlockProtocol (SimpleBlock SimpleMockCrypto ext))
                    SimpleMockCrypto
                    ext
         , Serialise (ChainState (BlockProtocol (SimpleBlock SimpleMockCrypto ext)))
         ) => RunNode (SimpleBlock SimpleMockCrypto ext) where
  nodeForgeBlock         = forgeSimple
  nodeBlockMatchesHeader = matchesSimpleHeader
  nodeBlockFetchSize     = fromIntegral . simpleBlockSize . simpleHeaderStd
  nodeIsEBB              = const False
  nodeEpochSize          = \_ _ -> return 21600

  nodeEncodeBlock        = const encode
  nodeEncodeHeader       = const encode
  nodeEncodeGenTx        =       encode
  nodeEncodeHeaderHash   = const encode
  nodeEncodeLedgerState  = const encode
  nodeEncodeChainState   = const encode

  nodeDecodeBlock        = const decode
  nodeDecodeHeader       = const decode
  nodeDecodeGenTx        =       decode
  nodeDecodeHeaderHash   = const decode
  nodeDecodeLedgerState  = const decode
  nodeDecodeChainState   = const decode