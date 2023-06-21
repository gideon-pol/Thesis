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

-- firSequential :: (HiddenClockResetEnable dom, Num a, KnownNat (n + 1), KnownNat n, NFDataX a)
--     => Vec (n + 1) a
--     -> Signal dom a
--     -> Signal dom a
-- firSequential taps input = output
--     where
--         output =
--           -- pure lifts a value into a signal
--           mults = map (input *) (fmap pure taps)
--           output = foldl (\x y -> register 0 $ x + y) 0 mults

topEntity ::
    Signal System (Signed 16) ->
    Clock System -> Reset System -> Enable System ->
    Signal System (Signed 16)
topEntity value = exposeClockResetEnable $ firFilter (replicate d32 5) value

main :: IO ()
main = do
  -- let out = basicFir (1 :> 2 :> 3 :> 4 :> 5 :> Nil)
  -- let arr = (1 :> 2 :> 3 :> Nil) :: Vec 4 (Signed 16)
  -- let d =  fmap pure arr :: Vec 4 (Signal System (Signed 16))
  -- let e = (pure 1) + (pure 2) :: Signal System (Signed 16)
  -- print $ e
  print $ sampleN 100 out
    where
      testInput      = stimuliGenerator clk rst (1 :> 2 :> 3 :> Nil)
      expectedOutput = outputVerifier' clk rst (1 :> 4 :> 7 :> 9 :> Nil)
      done           = expectedOutput (topEntity testInput clk rst en)
      out            = topEntity testInput clk rst en
      done'          = withClockResetEnable clk rst en done
      clk            = tbSystemClockGen (not <$> done')
      rst            = systemResetGen
      en             = enableGen

-- testBench :: Signal System Bool
-- testBench = done'
--   where
--     testInput      = stimuliGenerator clk rst (1 :> 2 :> 3 :> Nil)
--     expectedOutput = outputVerifier' clk rst (1 :> 4 :> 7 :> 9 :> Nil)
--     done           = expectedOutput (topEntity testInput clk rst en)
--     done'          = withClockResetEnable clk rst en done
--     clk            = tbSystemClockGen (not <$> done')
--     rst            = systemResetGen
--     en             = enableGen
