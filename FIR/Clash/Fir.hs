module Example.Fir where

import Clash.Prelude
import Clash.Explicit.Testbench

firFilter ::
    (HiddenClockResetEnable dom, Num a, KnownNat n, 1<=n, NFDataX a)
    => Vec n a
    -> Signal dom a
    -> Signal dom a
firFilter taps input = output
    where
          -- pure lifts a value into a signal
          mults = map (input *) (fmap pure taps)
          output = foldr (\x y -> register 0 $ x + y) 0 mults

topEntity ::
    Signal System (Signed 16) ->
    Clock System -> Reset System -> Enable System ->
    Signal System (Signed 16)
topEntity value = exposeClockResetEnable $ firFilter (replicate d32 5) value

testBench :: Signal System Bool
testBench = done'
  where
    testInput      = stimuliGenerator clk rst (1 :> 2 :> 3 :> Nil)
    expectedOutput = outputVerifier' clk rst (0 :> 5 :> 15 :> 30 :> 45 :> Nil)
    done           = expectedOutput (topEntity testInput clk rst en)
    done'          = withClockResetEnable clk rst en done
    clk            = tbSystemClockGen (not <$> done')
    rst            = systemResetGen
    en             = enableGen
